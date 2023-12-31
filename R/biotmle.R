utils::globalVariables(c("assay<-"))

#' Biomarker Evaluation with Targeted Minimum Loss Estimation of the ATE
#'
#' Computes the causal target parameter defined as the difference between the
#' biomarker expression values under treatment and those same values under no
#' treatment, using Targeted Minimum Loss Estimation.
#'
#' @param se A \code{SummarizedExperiment} containing microarray expression
#'  or next-generation sequencing data in the \code{assays} slot and a matrix
#'  of phenotype-level data in the \code{colData} slot.
#' @param varInt A \code{numeric} indicating the column of the design matrix
#'  corresponding to the treatment or outcome of interest (in the
#'  \code{colData} slot of the \code{SummarizedExperiment} argument "se").
#' @param normalized A \code{logical} indicating whether the data included in
#'  the \code{assay} slot of the input \code{SummarizedExperiment} object has
#'  been normalized externally. The default is set to \code{TRUE} with the
#'  expectation that an appropriate normalization method has been applied. If
#'  set to \code{FALSE}, median normalization is performed for microarray data.
#' @param ngscounts A \code{logical} indicating whether the data are counts
#'  generated from a next-generation sequencing experiment (e.g., RNA-seq). The
#'  default setting assumes continuous expression measures as generated by
#'  microarray platforms.
#' @param bppar_type A parallelization option specified by \code{BiocParallel}.
#'  Consult the manual page for \code{\link[BiocParallel]{BiocParallelParam}}
#'  for possible types and their descriptions. The default for this argument is
#'  \code{\link[BiocParallel]{MulticoreParam}}, for multicore evaluation.
#' @param bppar_debug A \code{logical} indicating whether or not to rely upon
#'  pkg{BiocParallel}. Setting this argument to \code{TRUE}, replaces the call
#'  to \code{\link[BiocParallel]{bplapply}} by a call to \code{lapply}, which
#'  significantly reduces the overhead of debugging. Note that invoking this
#'  option overrides all other parallelization arguments.
#' @param cv_folds A \code{numeric} scalar indicating how many folds to use in
#'  performing targeted minimum loss estimation. Cross-validated estimates have
#'  been demonstrated to allow relaxation of certain theoretical conditions and
#'  and accommodate the construction of more conservative variance estimates.
#' @param g_lib A \code{character} vector specifying the library of machine
#'  learning algorithms for use in fitting the propensity score P(A = a | W).
#' @param Q_lib A \code{character} vector specifying the library of machine
#'  learning algorithms for use in fitting the outcome regression E[Y | A,W].
#' @param ... Additional arguments to be passed to \code{\link[drtmle]{drtmle}}
#'  in computing the targeted minimum loss estimator of the average treatment
#'  effect.
#'
#' @importFrom SummarizedExperiment assay colData rowData SummarizedExperiment
#' @importFrom BiocParallel register bplapply bpprogressbar MulticoreParam
#' @importFrom tibble as_tibble
#'
#' @return S4 object of class \code{biotmle}, inheriting from
#'  \code{SummarizedExperiment}, with additional slots \code{tmleOut} and
#'  \code{call}, among others, containing TML estimates of the ATE of exposure
#'  on biomarker expression.
#'
#' @export biomarkertmle
#'
#' @examples
#' library(dplyr)
#' library(biotmleData)
#' library(SuperLearner)
#' library(SummarizedExperiment)
#' data(illuminaData)
#'
#' colData(illuminaData) <- colData(illuminaData) %>%
#'   data.frame() %>%
#'   mutate(age = as.numeric(age > median(age))) %>%
#'   DataFrame()
#' benz_idx <- which(names(colData(illuminaData)) %in% "benzene")
#'
#' biomarkerTMLEout <- biomarkertmle(
#'   se = illuminaData[1:2, ],
#'   varInt = benz_idx,
#'   bppar_type = BiocParallel::SerialParam(),
#'   g_lib = c("SL.mean", "SL.glm"),
#'   Q_lib = c("SL.mean", "SL.glm")
#' )
biomarkertmle <- function(se,
                          varInt,
                          normalized = TRUE,
                          ngscounts = FALSE,
                          bppar_type = BiocParallel::MulticoreParam(),
                          bppar_debug = FALSE,
                          cv_folds = 1,
                          g_lib = c(
                            "SL.mean", "SL.glm", "SL.bayesglm"
                          ),
                          Q_lib = c(
                            "SL.mean", "SL.bayesglm", "SL.earth", "SL.ranger"
                          ),
                          ...) {

  # catch input and invoke S4 class constructor for "bioTMLE" object
  call <- match.call(expand.dots = TRUE)
  biotmle <- .biotmle(
    SummarizedExperiment(
      assays = list(expMeasures = assay(se)),
      rowData = rowData(se),
      colData = colData(se)
    ),
    call = call,
    tmleOut = tibble::as_tibble(matrix(NA, 10, 10), .name_repair = "minimal"),
    topTable = tibble::as_tibble(matrix(NA, 10, 10), .name_repair = "minimal")
  )

  # invoke the voom transform from LIMMA if next-generation sequencing data)
  if (ngscounts) {
    voom_out <- rnaseq_ic(biotmle)
    voom_exp <- 2^(voom_out$E)
    assay(se) <- voom_exp
  }

  # set up parallelization based on input
  BiocParallel::bpprogressbar(bppar_type) <- TRUE
  BiocParallel::register(bppar_type, default = TRUE)

  # TMLE procedure to identify biomarkers based on an EXPOSURE
  if (!ngscounts && !normalized) {
    # median normalization
    exp_normed <- limma::normalizeBetweenArrays(as.matrix(assay(se)),
      method = "scale"
    )
    Y <- tibble::as_tibble(t(exp_normed), .name_repair = "minimal")
  } else {
    Y <- tibble::as_tibble(t(as.matrix(assay(se))), .name_repair = "minimal")
  }
  # simple sanity check of whether Y includes array values
  if (!all(apply(Y, 2, class) == "numeric")) {
    stop("Warning - values in Y do not appear to be numeric.")
  }

  # exposure / treatment
  A <- as.numeric(SummarizedExperiment::colData(se)[, varInt])

  # baseline covariates
  W <- tibble::as_tibble(SummarizedExperiment::colData(se)[, -varInt],
                         .name_repair = "minimal")
  if (is.null(dim(W)[2])) {
    W <- as.numeric(rep(1, length(A)))
  }

  # coerce matrix of baseline covariates to numeric
  if (!all(is.numeric(apply(W, 2, class)))) {
    W <- tibble::as_tibble(apply(W, 2, as.numeric), .name_repair = "minimal")
  }

  # perform multi-level TMLE (of the ATE) for genes as Y
  if (!bppar_debug) {
    biomarkertmle_out <- BiocParallel::bplapply(Y[, seq_along(Y)],
      exp_biomarkertmle,
      W = W,
      A = A,
      g_lib = g_lib,
      Q_lib = Q_lib,
      cv_folds = cv_folds,
      ...
    )
  } else {
    biomarkertmle_out <- lapply(Y[, seq_along(Y)],
      exp_biomarkertmle,
      W = W,
      A = A,
      g_lib = g_lib,
      Q_lib = Q_lib,
      cv_folds = cv_folds,
      ...
    )
  }
  biomarkertmle_params <- do.call(c, lapply(biomarkertmle_out, `[[`, "param"))
  biomarkertmle_eifs <- do.call(
    cbind.data.frame,
    lapply(biomarkertmle_out, `[[`, "eif")
  )

  biotmle@ateOut <- as.numeric(biomarkertmle_params)
  if (!ngscounts) {
    biomarker_eifs <- t(as.matrix(biomarkertmle_eifs))
    colnames(biomarker_eifs) <- colnames(se)
    biotmle@tmleOut <- tibble::as_tibble(
      biomarker_eifs,
      .name_repair = "minimal"
    )
  } else {
    voom_out$E <- t(as.matrix(biomarkertmle_eifs))
    biotmle@tmleOut <- voom_out
  }
  return(biotmle)
}

###############################################################################

#' TMLE procedure using ATE for Biomarker Identication from Exposure
#'
#' This function performs influence curve-based estimation of the effect of an
#' exposure on biological expression values associated with a given biomarker,
#' controlling for a user-specified set of baseline covariates.
#'
#' @param Y A \code{numeric} vector of expression values for a given biomarker.
#' @param A A \code{numeric} vector of discretized exposure vector (e.g., from
#'  a design matrix whose effect on expression values is of interest.
#' @param W A \code{Matrix} of \code{numeric} values corresponding to baseline
#'  covariates to be marginalized over in the estimation process.
#' @param g_lib A \code{character} vector identifying the library of learning
#'  algorithms to be used in fitting the propensity score P[A = a | W].
#' @param Q_lib A \code{character} vector identifying the library of learning
#'  algorithms to be used in fitting the outcome regression E[Y | A, W].
#' @param cv_folds A \code{numeric} scalar indicating how many folds to use in
#'  performing targeted minimum loss estimation. Cross-validated estimates are
#'  more robust, allowing relaxing of theoretical conditions and construction
#'  of conservative variance estimates.
#' @param ... Additional arguments passed to \code{\link[drtmle]{drtmle}} in
#'  computing the targeted minimum loss estimator of the average treatment
#'  effect.
#'
#' @importFrom assertthat assert_that
#' @importFrom drtmle drtmle
#'
#' @return TMLE-based estimate of the relationship between biomarker expression
#'  and changes in an exposure variable, computed iteratively and saved in the
#'  \code{tmleOut} slot in a \code{biotmle} object.
exp_biomarkertmle <- function(Y,
                              A,
                              W,
                              g_lib,
                              Q_lib,
                              cv_folds,
                              ...) {
  # check the case that Y is passed in as a column of a data.frame
  if (any(class(Y) == "data.frame")) Y <- as.numeric(unlist(Y[, 1]))
  if (any(class(A) == "data.frame")) A <- as.numeric(unlist(A[, 1]))
  assertthat::assert_that(length(unique(A)) > 1)

  # fit standard (possibly CV) TML estimator (n.b., guard = NULL)
  a_0 <- sort(unique(A[!is.na(A)]))
  suppressWarnings(
    tmle_fit <- drtmle::drtmle(
      Y = Y,
      A = A,
      W = W,
      a_0 = a_0,
      SL_g = g_lib,
      SL_Q = Q_lib,
      cvFolds = cv_folds,
      stratify = TRUE,
      guard = NULL,
      parallel = FALSE,
      use_future = FALSE,
      ...
    )
  )

  # compute ATE and estimated EIF by delta method
  ate_tmle <- tmle_fit$tmle$est[seq_along(a_0)[-1]] - tmle_fit$tmle$est[1]
  eif_tmle_delta <- tmle_fit$ic$ic[, seq_along(a_0)[-1]] - tmle_fit$ic$ic[, 1]

  # return only highest contrast (e.g., a[1] v a[5]) if many contrasts
  if (!is.vector(eif_tmle_delta)) {
    param_out <- ate_tmle[length(ate_tmle)]
    eif_out <- eif_tmle_delta[, ncol(eif_tmle_delta)] +
      ate_tmle[length(ate_tmle)]
  } else {
    param_out <- ate_tmle
    eif_out <- eif_tmle_delta + ate_tmle
  }
  assertthat::assert_that(is.vector(eif_out))

  # output
  out <- list(param = param_out, eif = eif_out)
  return(out)
}

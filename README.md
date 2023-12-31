
<!-- README.md is generated from README.Rmd. Please edit that file -->

# R/`biotmle`

[![R-CMD-check](https://github.com/nhejazi/biotmle/workflows/R-CMD-check/badge.svg)](https://github.com/nhejazi/biotmle/actions)
[![Coverage
Status](https://img.shields.io/codecov/c/github/nhejazi/biotmle/master.svg)](https://codecov.io/github/nhejazi/biotmle?branch=master)
[![Project Status: Active – The project has reached a stable, usable
state and is being actively
developed.](http://www.repostatus.org/badges/latest/active.svg)](http://www.repostatus.org/#active)
[![BioC
status](http://www.bioconductor.org/shields/build/release/bioc/biotmle.svg)](https://bioconductor.org/checkResults/release/bioc-LATEST/biotmle)
[![Bioc
Time](http://bioconductor.org/shields/years-in-bioc/biotmle.svg)](https://bioconductor.org/packages/release/bioc/html/biotmle.html)
[![Bioc
Downloads](http://bioconductor.org/shields/downloads/biotmle.svg)](https://bioconductor.org/packages/release/bioc/html/biotmle.html)
[![MIT
license](http://img.shields.io/badge/license-MIT-brightgreen.svg)](http://opensource.org/licenses/MIT)
[![DOI](https://zenodo.org/badge/65854775.svg)](https://zenodo.org/badge/latestdoi/65854775)
[![JOSS
Status](http://joss.theoj.org/papers/02be843d9bab1b598187bfbb08ce3949/status.svg)](http://joss.theoj.org/papers/02be843d9bab1b598187bfbb08ce3949)

> Targeted Learning with Moderated Statistics for Biomarker Discovery

**Authors:** [Nima Hejazi](https://nimahejazi.org), [Mark van der
Laan](https://vanderlaan-lab.org/about), and [Alan
Hubbard](https://hubbard.berkeley.edu)

-----

## What’s `biotmle`?

The `biotmle` R package facilitates biomarker discovery through a
generalization of the moderated t-statistic (Smyth 2004) that extends
the procedure to locally efficient estimators of asymptotically linear
target parameters (Tsiatis 2007). The set of methods implemented modify
targeted maximum likelihood (TML) estimators of statistical (or causal)
target parameters (e.g., average treatment effect) to apply variance
moderation to the standard variance estimator based on the efficient
influence function (EIF) of the target parameter (van der Laan and Rose
2011, 2018). By performing a moderated hypothesis test that pools the
individual probe-specific EIF-based variance estimates, a robust
variance estimator is constructed, which stabilizes the standard error
estimates and improves the performance of such estimators both in
smaller samples and in settings where the EIF is poorly estimated. The
resultant procedure allows for the construction of conservative
hypothesis tests that reduce the false discovery rate and/or the
family-wise error rate (Hejazi, van der Laan, and Hubbard 2021).
Improvements upon prior TML-based approaches to biomarker discovery
(e.g., Bembom et al. (2009)) include both the moderated variance
estimator as well as the use of conservative reference distributions for
the corresponding moderated test statistics (e.g., logistic
distribution), inspired by tail bounds based on concentration
inequalities (Rosenblum and van der Laan 2009); the latter prove
critical for obtaining robust inference when the finite-sample
distribution of the estimator deviates from normality.

-----

## Installation

For standard use, install from
[Bioconductor](https://bioconductor.org/packages/biotmle) using
[`BiocManager`](https://CRAN.R-project.org/package=BiocManager):

``` r
if (!requireNamespace("BiocManager", quietly=TRUE)) {
  install.packages("BiocManager")
}
BiocManager::install("biotmle")
```

To contribute, install the bleeding-edge *development version* from
GitHub via [`remotes`](https://CRAN.R-project.org/package=remotes):

``` r
remotes::install_github("nhejazi/biotmle")
```

Current and prior [Bioconductor](https://bioconductor.org) releases are
available under branches with numbers prefixed by “RELEASE\_”. For
example, to install the version of this package available via
Bioconductor 3.6, use

``` r
remotes::install_github("nhejazi/biotmle", ref = "RELEASE_3_6")
```

-----

## Example

For details on how to best use the `biotmle` R package, please consult
the most recent [package
vignette](https://bioconductor.org/packages/release/bioc/vignettes/biotmle/inst/doc/exposureBiomarkers.html)
available through the [Bioconductor
project](https://bioconductor.org/packages/biotmle).

-----

## Issues

If you encounter any bugs or have any specific feature requests, please
[file an issue](https://github.com/nhejazi/biotmle/issues).

-----

## Contributions

Contributions are very welcome. Interested contributors should consult
our [contribution
guidelines](https://github.com/nhejazi/biotmle/blob/master/CONTRIBUTING.md)
prior to submitting a pull request.

-----

## Citation

After using the `biotmle` R package, please cite both of the following:

``` 
    @article{hejazi2017biotmle,
      author = {Hejazi, Nima S and Cai, Weixin and Hubbard, Alan E},
      title = {biotmle: Targeted Learning for Biomarker Discovery},
      journal = {The Journal of Open Source Software},
      volume = {2},
      number = {15},
      month = {July},
      year  = {2017},
      publisher = {The Open Journal},
      doi = {10.21105/joss.00295},
      url = {https://doi.org/10.21105/joss.00295}
    }

    @article{hejazi2021generalization,
      author = {Hejazi, Nima S and Boileau, Philippe and {van der Laan},
        Mark J and Hubbard, Alan E},
      title = {A generalization of moderated statistics to data adaptive
        semiparametric estimation in high-dimensional biology},
      journal={under review},
      volume={},
      number={},
      pages={},
      year = {2021+},
      publisher={},
      doi = {},
      url = {https://arxiv.org/abs/1710.05451}
    }

    @manual{hejazi2019biotmlebioc,
      author = {Hejazi, Nima S and {van der Laan}, Mark J and Hubbard, Alan
        E},
      title = {{biotmle}: {Targeted Learning} with moderated statistics for
        biomarker discovery},
      doi = {10.18129/B9.bioc.biotmle},
      url = {https://bioconductor.org/packages/biotmle},
      note = {R package version 1.10.0}
    }
```

-----

## Related

  - [R/`biotmleData`](https://github.com/nhejazi/biotmleData) - R
    package with example experimental data for use with this analysis
    package.

-----

## Funding

The development of this software was supported in part through grants
from the National Institutes of Health: [P42
ES004705-29](https://projectreporter.nih.gov/project_info_details.cfm?aid=9260357&map=y)
and [R01
ES021369-05](https://projectreporter.nih.gov/project_info_description.cfm?aid=9210551&icde=37849782&ddparam=&ddvalue=&ddsub=&cr=1&csb=default&cs=ASC&pball=).

-----

## License

© 2016-2021 [Nima S. Hejazi](https://nimahejazi.org)

The contents of this repository are distributed under the MIT license.
See file `LICENSE` for details.

-----

## References

<div id="refs" class="references">

<div id="ref-bembom2009biomarker">

Bembom, Oliver, Maya L Petersen, Soo-Yon Rhee, W Jeffrey Fessel, Sandra
E Sinisi, Robert W Shafer, and Mark J van der Laan. 2009. “Biomarker
Discovery Using Targeted Maximum-Likelihood Estimation: Application to
the Treatment of Antiretroviral-Resistant Hiv Infection.” *Statistics in
Medicine* 28 (1): 152–72.

</div>

<div id="ref-hejazi2021generalization">

Hejazi, Nima S, Mark J van der Laan, and Alan E Hubbard. 2021. “A
Generalization of Moderated Statistics to Data Adaptive Semiparametric
Estimation in High-Dimensional Biology.” *Under Review*.
<https://arxiv.org/abs/1710.05451>.

</div>

<div id="ref-rosenblum2009confidence">

Rosenblum, Michael A, and Mark J van der Laan. 2009. “Confidence
Intervals for the Population Mean Tailored to Small Sample Sizes, with
Applications to Survey Sampling.” *The International Journal of
Biostatistics* 5 (1).

</div>

<div id="ref-smyth2004linear">

Smyth, Gordon K. 2004. “Linear Models and Empirical Bayes Methods for
Assessing Differential Expression in Microarray Experiments.”
*Statistical Applications in Genetics and Molecular Biology* 3 (1):
1–25. <https://doi.org/10.2202/1544-6115.1027>.

</div>

<div id="ref-tsiatis2007semiparametric">

Tsiatis, Anastasios. 2007. *Semiparametric Theory and Missing Data*.
Springer Science & Business Media.

</div>

<div id="ref-vdl2011targeted">

van der Laan, Mark J., and Sherri Rose. 2011. *Targeted Learning: Causal
Inference for Observational and Experimental Data*. Springer Science &
Business Media.

</div>

<div id="ref-vdl2018targeted">

van der Laan, Mark J, and Sherri Rose. 2018. *Targeted Learning in Data
Science: Causal Inference for Complex Longitudinal Studies*. Springer
Science & Business Media.

</div>

</div>

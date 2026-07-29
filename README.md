
<!-- README.md is generated from README.Rmd. Please edit that file -->

# antable

<!-- badges: start -->

<!-- badges: end -->

The goal of antable is to simplify the process of performing contingency
table-based analyses when starting from a data.frame or tibble object.

## Installation

You can install the development version of antable from
[GitHub](https://github.com/) with:

``` r
# install.packages("pak")
pak::pak("dobengjhu/antable")
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
set.seed(100)
data <- tibble::tibble(
  sex = c("Male", "Female")[rbinom(100, 1, 0.52) + 1],
  disease = c("Sick", "Cured")[rbinom(100, 1, 0.2) + 1]
)

library(antable)
result <- twobytwo(study_tbl = data,
                   exposure = "sex",
                   outcome = "disease")
summary(result)
#> ═══════════════ 
#> ANTABLE SUMMARY
#> ═══════════════ 
#> Exposure : sex (n = 100)
#> Outcome  : disease (n = 100)
#> 
#> CONTINGENCY TABLE───────────────────────────────────── 
#> 
#>         disease
#> sex      Cured    Sick  Total
#> --------------------------- 
#> Female       6      45     51
#>         11.76%  88.24%       
#>         27.27%  57.69%       
#>          6.00%  45.00%       
#> --------------------------- 
#> Male        16      33     49
#>         32.65%  67.35%       
#>         72.73%  42.31%       
#>         16.00%  33.00%       
#> --------------------------- 
#> Total       22      78    100
#> --------------------------- 
#> Key: count / row % / col % / cell %
#> 
#> PREVALENCE──────────────────────────────────────────── 
#> 
#>                   Estimate      Wald 95% CI
#> P(sex = Male)         0.49 [0.3920, 0.5880]
#> P(disease = Sick)     0.78 [0.6988, 0.8612]
#> 
#> EXPOSURE-OUTCOME ASSOCIATION────────────────────────── 
#> 
#>                 Estimate             95% CI
#> Risk Difference  -0.2089 [-0.3672, -0.0506]
#> Risk Ratio        0.7633   [0.6130, 0.9503]
#> Odds Ratio        0.2750   [0.0972, 0.7782]
#> 
#> TWO-PROPORTION Z TEST───────────────────────────────── 
#> 
#> Z = 6.354,  df = 1, p = 0.0117
```

Sometimes variable values are not ordered in a manner that aligns with
the research question of interest. For example, in the scenario above, R
will automatically treat `Male` as the exposed group and `Sick` as the
outcome of interest because they are each the “highest” value of the
respective variables. If we were actually interested in treat females as
the exposed group and patients who were cured as cases, we change the
manner in which we define `exposure` and `outcome` and provide explicit
definition using the general form `"var_name == var_level"`:

``` r
result <- twobytwo(study_tbl = data,
                   exposure = "sex == 'Female'",
                   outcome = "disease == 'Cured'")
summary(result)
#> ═══════════════ 
#> ANTABLE SUMMARY
#> ═══════════════ 
#> Exposure : sex (n = 100)
#> Outcome  : disease (n = 100)
#> 
#> CONTINGENCY TABLE───────────────────────────────────── 
#> 
#>         disease
#> sex       Sick   Cured  Total
#> --------------------------- 
#> Male        33      16     49
#>         67.35%  32.65%       
#>         42.31%  72.73%       
#>         33.00%  16.00%       
#> --------------------------- 
#> Female      45       6     51
#>         88.24%  11.76%       
#>         57.69%  27.27%       
#>         45.00%   6.00%       
#> --------------------------- 
#> Total       78      22    100
#> --------------------------- 
#> Key: count / row % / col % / cell %
#> 
#> PREVALENCE──────────────────────────────────────────── 
#> 
#>                    Estimate      Wald 95% CI
#> P(sex = Female)        0.51 [0.4120, 0.6080]
#> P(disease = Cured)     0.22 [0.1388, 0.3012]
#> 
#> EXPOSURE-OUTCOME ASSOCIATION────────────────────────── 
#> 
#>                 Estimate             95% CI
#> Risk Difference  -0.2089 [-0.3672, -0.0506]
#> Risk Ratio        0.3603   [0.1536, 0.8450]
#> Odds Ratio        0.2750   [0.0972, 0.7782]
#> 
#> TWO-PROPORTION Z TEST───────────────────────────────── 
#> 
#> Z = 6.354,  df = 1, p = 0.0117
```

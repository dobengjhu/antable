
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

This is a basic example which shows how to use the `twobytwo()` function
to generate a collection of summary statistics related to both the
marginal proportions as well as association between the `exposure` and
`outcome` variables defined by the user:

``` r
library(antable)
result <- twobytwo(study_tbl = data,
                   outcome = "disease",
                   exposure = "sex")
summary(result)
#> ═══════════════ 
#> ANTABLE SUMMARY
#> ═══════════════ 
#> Outcome  : disease (n = 100)
#> Exposure : sex (n = 100)
#> 
#> CONTINGENCY TABLE───────────────────────────────────── 
#> 
#>         disease
#> sex      Cured    Sick  Total
#> ----------------------------- 
#> Female      10      41     51
#>         19.61%  80.39%       
#>         58.82%  49.40%       
#>         10.00%  41.00%       
#> ----------------------------- 
#> Male         7      42     49
#>         14.29%  85.71%       
#>         41.18%  50.60%       
#>          7.00%  42.00%       
#> ----------------------------- 
#> Total       17      83    100
#> ----------------------------- 
#> Key: count / row % / col % / cell %
#> 
#> PREVALENCE──────────────────────────────────────────── 
#> 
#>                    Estimate      Wald 95% CI
#> P(disease = Cured)     0.83 [0.7564, 0.9036]
#> P(sex = Female)        0.49 [0.3920, 0.5880]
#> 
#> EXPOSURE-OUTCOME ASSOCIATION────────────────────────── 
#> 
#>                 Estimate            95% CI
#> Risk Difference   0.0532 [-0.0933, 0.1998]
#> Risk Ratio        1.0662  [0.8930, 1.2730]
#> Odds Ratio        1.4634  [0.5083, 4.2130]
#> 
#> TWO-PROPORTION Z TEST───────────────────────────────── 
#> 
#> Z = 0.5017,  df = 1, p = 0.479
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
                   outcome = "disease == 'Cured'",
                   exposure = "sex == 'Female'")
summary(result)
#> ═══════════════ 
#> ANTABLE SUMMARY
#> ═══════════════ 
#> Outcome  : disease (n = 100)
#> Exposure : sex (n = 100)
#> 
#> CONTINGENCY TABLE───────────────────────────────────── 
#> 
#>         disease
#> sex       Sick   Cured  Total
#> ----------------------------- 
#> Male        42       7     49
#>         85.71%  14.29%       
#>         50.60%  41.18%       
#>         42.00%   7.00%       
#> ----------------------------- 
#> Female      41      10     51
#>         80.39%  19.61%       
#>         49.40%  58.82%       
#>         41.00%  10.00%       
#> ----------------------------- 
#> Total       83      17    100
#> ----------------------------- 
#> Key: count / row % / col % / cell %
#> 
#> PREVALENCE──────────────────────────────────────────── 
#> 
#>                    Estimate      Wald 95% CI
#> P(disease = Cured)     0.17 [0.0964, 0.2436]
#> P(sex = Female)        0.51 [0.4120, 0.6080]
#> 
#> EXPOSURE-OUTCOME ASSOCIATION────────────────────────── 
#> 
#>                 Estimate            95% CI
#> Risk Difference   0.0532 [-0.0933, 0.1998]
#> Risk Ratio        1.3725  [0.5678, 3.3181]
#> Odds Ratio        1.4634  [0.5083, 4.2130]
#> 
#> TWO-PROPORTION Z TEST───────────────────────────────── 
#> 
#> Z = 0.5017,  df = 1, p = 0.479
```

In cases where the user is solely interested in cross-tabulation of
`exposure` and `outcome`, the `crosstab()` function allows for this more
targeted investigation. Furthermore, unlike `twobytwo()` which presumes
both `exposure` and `outcome` are binary, `crosstab()` only requires
that they are categorical:

``` r
result_disease <- crosstab(study_tbl = data,
                           outcome = "disease",
                           exposure = "sex")
summary(result_disease)
#>         disease
#> sex      Cured    Sick  Total
#> ----------------------------- 
#> Female      10      41     51
#>         19.61%  80.39%       
#>         58.82%  49.40%       
#>         10.00%  41.00%       
#> ----------------------------- 
#> Male         7      42     49
#>         14.29%  85.71%       
#>         41.18%  50.60%       
#>          7.00%  42.00%       
#> ----------------------------- 
#> Total       17      83    100
#> ----------------------------- 
#> Key: count / row % / col % / cell %

result_smoking <- crosstab(study_tbl = data,
                           outcome = "smoking_status",
                           exposure = "sex")
summary(result_smoking)
#>         smoking_status
#> sex     Current  Former   Never  Total
#> -------------------------------------- 
#> Female       20       3      28     51
#>          39.22%   5.88%  54.90%       
#>          47.62%  21.43%  63.64%       
#>          20.00%   3.00%  28.00%       
#> -------------------------------------- 
#> Male         22      11      16     49
#>          44.90%  22.45%  32.65%       
#>          52.38%  78.57%  36.36%       
#>          22.00%  11.00%  16.00%       
#> -------------------------------------- 
#> Total        42      14      44    100
#> -------------------------------------- 
#> Key: count / row % / col % / cell %
```

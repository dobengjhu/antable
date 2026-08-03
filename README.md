
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

Both `twobytwo()` and `crosstab()` can also be used to evaluate a single
variable of interest by assigning it to the `outcome` with
`exposure = NULL`. Note that `twobytwo()` requires the variable to be
binary and will not return any statistics related to measuring
association or hypothesis testing, while `crosstab()` can accommodate
categorical variables with more than two categories.

``` r
result_disease_only <- twobytwo(study_tbl = data,
                                outcome = "disease",
                                exposure = NULL)
summary(result_disease_only)
#> ═══════════════ 
#> ANTABLE SUMMARY
#> ═══════════════ 
#> Outcome  : disease (n = 100)
#> 
#> CONTINGENCY TABLE───────────────────────────────────── 
#> 
#> disease
#>     Cured    Sick    Total
#> -------------------------- 
#> n      17      83      100
#> %  17.00%  83.00%  100.00%
#> -------------------------- 
#> Key: count / %
#> 
#> PREVALENCE──────────────────────────────────────────── 
#> 
#>                    Estimate      Wald 95% CI
#> P(disease = Cured)     0.83 [0.7564, 0.9036]

result_smoking_status_only <- crosstab(study_tbl = data,
                                       outcome = "smoking_status",
                                       exposure = NULL)
summary(result_smoking_status_only)
#> smoking_status
#>    Current  Former   Never    Total
#> ----------------------------------- 
#> n       42      14      44      100
#> %   42.00%  14.00%  44.00%  100.00%
#> ----------------------------------- 
#> Key: count / %
```

Options for dealing with missing values differ between the two
functions:

- `twobytwo()` excludes all observations that are missing a value for
  `outcome` or `exposure`
- `crosstab()` gives users the option of excluding observations that are
  missing a value for `outcome` or `exposure`, or treating the
  missingness as an additional category for both variables.

``` r
data_na <- data
data_na$sex[sample(1:100, 10)] <- NA
data_na$disease[sample(1:100, 10)] <- NA
```

``` r
dplyr::summarise(data_na, 
                 across(c(sex, disease), ~ sum(is.na(.))))
#> # A tibble: 1 × 2
#>     sex disease
#>   <int>   <int>
#> 1    10      10

dplyr::filter(data_na,
              is.na(sex) | is.na(disease))
#> # A tibble: 19 × 3
#>    sex    smoking_status disease
#>    <chr>  <chr>          <chr>  
#>  1 <NA>   Never          Cured  
#>  2 Male   Former         <NA>   
#>  3 <NA>   Current        Sick   
#>  4 Female Never          <NA>   
#>  5 <NA>   Current        Sick   
#>  6 Female Never          <NA>   
#>  7 Male   Current        <NA>   
#>  8 Female Current        <NA>   
#>  9 Male   Never          <NA>   
#> 10 <NA>   Never          Sick   
#> 11 Male   Never          <NA>   
#> 12 <NA>   Current        Cured  
#> 13 <NA>   Current        Sick   
#> 14 Male   Current        <NA>   
#> 15 <NA>   Never          Sick   
#> 16 <NA>   Never          Sick   
#> 17 <NA>   Never          <NA>   
#> 18 Female Never          <NA>   
#> 19 <NA>   Current        Sick
```

Each variable is missing 10 observations, respectively, but only one
observation is missing information for *both* sex and disease status.

``` r
result_disease_twobytwo <- twobytwo(study_tbl = data_na,
                                    outcome = "disease",
                                    exposure = "sex")
summary(result_disease_twobytwo)
#> ═══════════════ 
#> ANTABLE SUMMARY
#> ═══════════════ 
#> Outcome  : disease (n = 81)
#> Exposure : sex (n = 81)
#> 
#> CONTINGENCY TABLE───────────────────────────────────── 
#> 
#>         disease
#> sex      Cured    Sick  Total
#> ----------------------------- 
#> Female      10      33     43
#>         23.26%  76.74%       
#>         76.92%  48.53%       
#>         12.35%  40.74%       
#> ----------------------------- 
#> Male         3      35     38
#>          7.89%  92.11%       
#>         23.08%  51.47%       
#>          3.70%  43.21%       
#> ----------------------------- 
#> Total       13      68     81
#> ----------------------------- 
#> Key: count / row % / col % / cell %
#> 
#> PREVALENCE──────────────────────────────────────────── 
#> 
#>                    Estimate      Wald 95% CI
#> P(disease = Cured)   0.8395 [0.7596, 0.9194]
#> P(sex = Female)      0.4691 [0.3605, 0.5778]
#> 
#> EXPOSURE-OUTCOME ASSOCIATION────────────────────────── 
#> 
#>                 Estimate            95% CI
#> Risk Difference   0.1536  [0.0010, 0.3062]
#> Risk Ratio        1.2002  [0.9934, 1.4499]
#> Odds Ratio        3.5354 [0.8938, 13.9835]
#> 
#> TWO-PROPORTION Z TEST───────────────────────────────── 
#> 
#> Z = 3.533,  df = 1, p = 0.0602

result_disease_crosstab <- crosstab(study_tbl = data_na,
                                    outcome = "disease")
summary(result_disease_crosstab)
#> disease
#>     Cured    Sick    Total
#> -------------------------- 
#> n      15      75       90
#> %  16.67%  83.33%  100.00%
#> -------------------------- 
#> Key: count / %

result_disease_crosstab_missing <- crosstab(study_tbl = data_na,
                                    outcome = "disease",
                                    include_missing = TRUE)
summary(result_disease_crosstab_missing)
#> disease
#>     Cured    Sick  Missing    Total
#> ----------------------------------- 
#> n      15      75       10      100
#> %  15.00%  75.00%   10.00%  100.00%
#> ----------------------------------- 
#> Key: count / %
```

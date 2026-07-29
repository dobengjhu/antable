
<!-- README.md is generated from README.Rmd. Please edit that file -->

# antable

<!-- badges: start -->

<!-- badges: end -->

The goal of antable is to …

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
data <- tibble::tibble(
  sex = c("Male", "Female")[rbinom(100, 1, 0.52) + 1],
  disease = c("Sick", "Cured")[rbinom(100, 1, 0.2) + 1]
)

library(antable)
result <- twobytwo(study_tbl = data,
                   exposure = "sex == 'Female'",
                   outcome = "disease == 'Cured'",
                   test_method = "chisq")
#> Called from: twobytwo(study_tbl = data, exposure = "sex == 'Female'", outcome = "disease == 'Cured'", 
#>     test_method = "chisq")
#> debug at /Users/danielobeng/code/antable/antable/R/twobytwo.R#114: p_exposure_list <- onesample_ci(exp_bin, ci_method, alpha)
#> debug at /Users/danielobeng/code/antable/antable/R/twobytwo.R#120: p_outcome_list <- onesample_ci(out_bin, ci_method, alpha)
#> debug at /Users/danielobeng/code/antable/antable/R/twobytwo.R#126: moa_table <- moa_ci(cont_table, alpha)
#> debug at /Users/danielobeng/code/antable/antable/R/twobytwo.R#131: p_test <- test_result <- NA
#> debug at /Users/danielobeng/code/antable/antable/R/twobytwo.R#132: if (test_method == "fisher_exact") {
#>     test_result <- fisher.test(cont_table, ...)
#>     p_test <- data.frame(or_estimate = test_result$estimate, 
#>         p_value = test_result$p.value)
#> } else {
#>     extra_args <- list(...)
#>     relevant_args <- extra_args[names(extra_args) %in% names(formals(chisq.test))]
#>     if (is.null(relevant_args[["correct"]])) {
#>         relevant_args[["correct"]] <- FALSE
#>     }
#>     if (test_method == "chisq") {
#>         test_result <- do.call(chisq.test, c(list(x = cont_table), 
#>             relevant_args))
#>         p_test <- data.frame(statistic = test_result$statistic, 
#>             df = test_result$parameter, p_value = test_result$p.value)
#>     }
#>     else if (test_method == "z") {
#>         test_result <- do.call(prop.test, c(list(x = cont_table), 
#>             relevant_args))
#>         p_test <- data.frame(statistic = test_result$statistic, 
#>             df = test_result$parameter, p_value = test_result$p.value)
#>     }
#> }
#> debug at /Users/danielobeng/code/antable/antable/R/twobytwo.R#139: extra_args <- list(...)
#> debug at /Users/danielobeng/code/antable/antable/R/twobytwo.R#140: relevant_args <- extra_args[names(extra_args) %in% names(formals(chisq.test))]
#> debug at /Users/danielobeng/code/antable/antable/R/twobytwo.R#141: if (is.null(relevant_args[["correct"]])) {
#>     relevant_args[["correct"]] <- FALSE
#> }
#> debug at /Users/danielobeng/code/antable/antable/R/twobytwo.R#142: relevant_args[["correct"]] <- FALSE
#> debug at /Users/danielobeng/code/antable/antable/R/twobytwo.R#145: if (test_method == "chisq") {
#>     test_result <- do.call(chisq.test, c(list(x = cont_table), 
#>         relevant_args))
#>     p_test <- data.frame(statistic = test_result$statistic, df = test_result$parameter, 
#>         p_value = test_result$p.value)
#> } else if (test_method == "z") {
#>     test_result <- do.call(prop.test, c(list(x = cont_table), 
#>         relevant_args))
#>     p_test <- data.frame(statistic = test_result$statistic, df = test_result$parameter, 
#>         p_value = test_result$p.value)
#> }
#> debug at /Users/danielobeng/code/antable/antable/R/twobytwo.R#146: test_result <- do.call(chisq.test, c(list(x = cont_table), relevant_args))
#> debug at /Users/danielobeng/code/antable/antable/R/twobytwo.R#150: p_test <- data.frame(statistic = test_result$statistic, df = test_result$parameter, 
#>     p_value = test_result$p.value)
#> debug at /Users/danielobeng/code/antable/antable/R/twobytwo.R#169: object <- list(exposure_name = exposure_name, exposure = exp_var, 
#>     outcome_name = outcome_name, outcome = out_var, contingency_table = cont_table_list, 
#>     ci_method = ci_method, p_exposure = p_exposure_list[["p_hat"]], 
#>     p_exposure_ci = p_exposure_list[["p_hat_ci"]], p_outcome = p_outcome_list[["p_hat"]], 
#>     p_outcome_ci = p_outcome_list[["p_hat_ci"]], compare_ci = moa_table, 
#>     compare_test = list(test_method = test_method, test_summary = p_test, 
#>         test_object = test_result), alpha = alpha)
#> debug at /Users/danielobeng/code/antable/antable/R/twobytwo.R#184: class(object) <- "anthill"
#> debug at /Users/danielobeng/code/antable/antable/R/twobytwo.R#186: return(object)
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
#> Male        32      11     43
#>         74.42%  25.58%       
#>         40.00%  55.00%       
#>         32.00%  11.00%       
#> --------------------------- 
#> Female      48       9     57
#>         84.21%  15.79%       
#>         60.00%  45.00%       
#>         48.00%   9.00%       
#> --------------------------- 
#> Total       80      20    100
#> --------------------------- 
#> Key: count / row % / col % / cell %
#> 
#> PREVALENCE──────────────────────────────────────────── 
#> 
#>                    Estimate      Wald 95% CI
#> P(sex = Female)        0.57 [0.4730, 0.6670]
#> P(disease = Cured)     0.20 [0.1216, 0.2784]
#> 
#> EXPOSURE-OUTCOME ASSOCIATION────────────────────────── 
#> 
#>                 Estimate            95% CI
#> Risk Difference  -0.0979 [-0.2591, 0.0632]
#> Risk Ratio        0.6172  [0.2810, 1.3559]
#> Odds Ratio        0.5455  [0.2031, 1.4650]
#> 
#> CHI-SQUARED TEST────────────────────────────────────── 
#> 
#> χ²(1) = 1.469,  p = 0.226
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
                   outcome = "disease == 'Cured'",
                   test_method = "chisq")
#> Called from: twobytwo(study_tbl = data, exposure = "sex == 'Female'", outcome = "disease == 'Cured'", 
#>     test_method = "chisq")
#> debug at /Users/danielobeng/code/antable/antable/R/twobytwo.R#114: p_exposure_list <- onesample_ci(exp_bin, ci_method, alpha)
#> debug at /Users/danielobeng/code/antable/antable/R/twobytwo.R#120: p_outcome_list <- onesample_ci(out_bin, ci_method, alpha)
#> debug at /Users/danielobeng/code/antable/antable/R/twobytwo.R#126: moa_table <- moa_ci(cont_table, alpha)
#> debug at /Users/danielobeng/code/antable/antable/R/twobytwo.R#131: p_test <- test_result <- NA
#> debug at /Users/danielobeng/code/antable/antable/R/twobytwo.R#132: if (test_method == "fisher_exact") {
#>     test_result <- fisher.test(cont_table, ...)
#>     p_test <- data.frame(or_estimate = test_result$estimate, 
#>         p_value = test_result$p.value)
#> } else {
#>     extra_args <- list(...)
#>     relevant_args <- extra_args[names(extra_args) %in% names(formals(chisq.test))]
#>     if (is.null(relevant_args[["correct"]])) {
#>         relevant_args[["correct"]] <- FALSE
#>     }
#>     if (test_method == "chisq") {
#>         test_result <- do.call(chisq.test, c(list(x = cont_table), 
#>             relevant_args))
#>         p_test <- data.frame(statistic = test_result$statistic, 
#>             df = test_result$parameter, p_value = test_result$p.value)
#>     }
#>     else if (test_method == "z") {
#>         test_result <- do.call(prop.test, c(list(x = cont_table), 
#>             relevant_args))
#>         p_test <- data.frame(statistic = test_result$statistic, 
#>             df = test_result$parameter, p_value = test_result$p.value)
#>     }
#> }
#> debug at /Users/danielobeng/code/antable/antable/R/twobytwo.R#139: extra_args <- list(...)
#> debug at /Users/danielobeng/code/antable/antable/R/twobytwo.R#140: relevant_args <- extra_args[names(extra_args) %in% names(formals(chisq.test))]
#> debug at /Users/danielobeng/code/antable/antable/R/twobytwo.R#141: if (is.null(relevant_args[["correct"]])) {
#>     relevant_args[["correct"]] <- FALSE
#> }
#> debug at /Users/danielobeng/code/antable/antable/R/twobytwo.R#142: relevant_args[["correct"]] <- FALSE
#> debug at /Users/danielobeng/code/antable/antable/R/twobytwo.R#145: if (test_method == "chisq") {
#>     test_result <- do.call(chisq.test, c(list(x = cont_table), 
#>         relevant_args))
#>     p_test <- data.frame(statistic = test_result$statistic, df = test_result$parameter, 
#>         p_value = test_result$p.value)
#> } else if (test_method == "z") {
#>     test_result <- do.call(prop.test, c(list(x = cont_table), 
#>         relevant_args))
#>     p_test <- data.frame(statistic = test_result$statistic, df = test_result$parameter, 
#>         p_value = test_result$p.value)
#> }
#> debug at /Users/danielobeng/code/antable/antable/R/twobytwo.R#146: test_result <- do.call(chisq.test, c(list(x = cont_table), relevant_args))
#> debug at /Users/danielobeng/code/antable/antable/R/twobytwo.R#150: p_test <- data.frame(statistic = test_result$statistic, df = test_result$parameter, 
#>     p_value = test_result$p.value)
#> debug at /Users/danielobeng/code/antable/antable/R/twobytwo.R#169: object <- list(exposure_name = exposure_name, exposure = exp_var, 
#>     outcome_name = outcome_name, outcome = out_var, contingency_table = cont_table_list, 
#>     ci_method = ci_method, p_exposure = p_exposure_list[["p_hat"]], 
#>     p_exposure_ci = p_exposure_list[["p_hat_ci"]], p_outcome = p_outcome_list[["p_hat"]], 
#>     p_outcome_ci = p_outcome_list[["p_hat_ci"]], compare_ci = moa_table, 
#>     compare_test = list(test_method = test_method, test_summary = p_test, 
#>         test_object = test_result), alpha = alpha)
#> debug at /Users/danielobeng/code/antable/antable/R/twobytwo.R#184: class(object) <- "anthill"
#> debug at /Users/danielobeng/code/antable/antable/R/twobytwo.R#186: return(object)
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
#> Male        32      11     43
#>         74.42%  25.58%       
#>         40.00%  55.00%       
#>         32.00%  11.00%       
#> --------------------------- 
#> Female      48       9     57
#>         84.21%  15.79%       
#>         60.00%  45.00%       
#>         48.00%   9.00%       
#> --------------------------- 
#> Total       80      20    100
#> --------------------------- 
#> Key: count / row % / col % / cell %
#> 
#> PREVALENCE──────────────────────────────────────────── 
#> 
#>                    Estimate      Wald 95% CI
#> P(sex = Female)        0.57 [0.4730, 0.6670]
#> P(disease = Cured)     0.20 [0.1216, 0.2784]
#> 
#> EXPOSURE-OUTCOME ASSOCIATION────────────────────────── 
#> 
#>                 Estimate            95% CI
#> Risk Difference  -0.0979 [-0.2591, 0.0632]
#> Risk Ratio        0.6172  [0.2810, 1.3559]
#> Odds Ratio        0.5455  [0.2031, 1.4650]
#> 
#> CHI-SQUARED TEST────────────────────────────────────── 
#> 
#> χ²(1) = 1.469,  p = 0.226
```

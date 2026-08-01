#' Create a contingency table and calculate summary statistics
#'
#' Converts binary variables in a data.frame or tibble into a contingency table,
#' then calculates relevant one-sample and two-sample summary statistics and
#' inference artifacts.
#'
#' @importFrom stats qnorm qbeta fisher.test chisq.test prop.test
#' @param study_tbl A data.frame or tbl containing the exposure and outcome variables to be analyzed, as specified in the `exposure` and `outcome` arguments.
#' @param exposure A string specifying the binary exposure variable in `study_tbl`. By default, the variable's highest level is treated as "exposed". To specify a different level as "exposed," use the form `"var_name == var_level"`.
#' @param outcome A string specifying the binary outcome variable in `study_tbl`. By default, the variable's highest level is treated as the "event". To specify a different level as the "event," use the form `"var_name == var_level"`.
#' @param ci_method A string specifying the method used to calculate the marginal proportion confidence intervals. Defaults to `"clopper-pearson"`. One of:
#'   - `"wald"`: normal approximation interval.
#'   - `"clopper-pearson"`: exact interval based on the binomial
#'     distribution.
#'   - `"agresti-coull"`: adjusted Wald interval with improved coverage.
#'   - `"wilson"`: score interval based on inverting the score test.
#' @param test_method A string specifying the hypothesis test used to test the difference in conditional proportions. Defaults to `"z"`. One of:
#'    - `"z"`: two-sample Z-test using normal approximation.
#'    - `"chisq"`: Chi-squared test.
#'    - `"fisher_exact"`: Fisher's exact test.
#'    - `"none"`: No hypothesis test will be performed.
#' @param alpha A numeric value strictly between 0 and 1 specifying the significance level for confidence interval calculation and hypothesis tests. Defaults to `0.05`.
#' @param ... Additional arguments passed to internal calculation functions, including:
#'   - `correct`: continuity correction, used when `test_method` is `"z"` or `"chisq"`.
#'   - `digits`: number of decimal places to display, used in [print.summary.anthill()].
#'
#' @returns An object of class `anthill`, which is a list containing:
#'    - `exposure_name`: The name of the exposure column in the original `study_tbl`.
#'    - `exposure_var`: The values of the exposure column expressed as a factor.
#'    - `outcome_name`: The name of the outcome column in the original `study_tbl`.
#'    - `outcome_var`: The values of the outcome column expressed as a factor.
#'    - `contingency_table`: A list containing:
#'        - `data`: The 2 x 2 `table` of counts, cross-tabulating the `exposure` and `outcome` columns.
#'        - `row_prop`: A matrix of row-wise proportions of `data`.
#'        - `col_prop`: A matrix of column-wise proportions of `data`.
#'        - `cell_prop`: A matrix of cell-wise proportions of `data`.
#'    - `ci_method`: The value of `ci_method`.
#'    - `p_exposure`: The marginal proportion of exposed observations in `data`.
#'    - `p_exposure_ci`: A numeric vector of length 2 (`lower`, `upper`) giving the 100 * (1 - `alpha`)% confidence interval for `p_exposure`, calculated using the method specified in `ci_method`
#'    - `p_outcome`: The marginal proportion of observations with the event of interest in `data`.
#'    - `p_outcome_ci`: A numeric vector of length 2 (`lower`, `upper`) giving the 100 * (1 - `alpha`)% confidence interval for `p_outcome`, calculated using the method specified in `ci_method`
#'    - `compare_ci`: A data.frame summarizing the risk difference, risk ratio, and odds ratio comparing the conditional proportions of events across the exposed and unexposed groups. Contains columns `measure` (the measure name), `estimate` (the point estimate), `lower_ci`, and `upper_ci` (the 100 * (1 - `alpha`)% confidence bounds).
#'    - `compare_test`: A list containing:
#'        - `test_method`: The value of `test_method`.
#'        - `test_summary`: A data.frame summarizing the key findings from `test_method`.
#'            - When `test_method` is `"z"` or `"chisq"`, contains columns `statistic` (the test statistic), `df` (the degrees of freedom for the test), and `p-value` (the two-sided p-value for the test).
#'            - When `test_method` is `"fisher_exact"`, contains columns `or_estimate` (the estimated odds ratio) and `p_value` (the two-sided p-value for the test).
#'        - `test_result`: The underlying test object returned by the function corresponding to `test_method` (e.g., an `htest` object from [stats::prop.test()]).
#'    - `alpha`: The value of `alpha`.
#'
#' @export
#'
#' @example inst/examples/examples-twobytwo.R
twobytwo <- function(study_tbl,
                     outcome,
                     exposure = NULL,
                     ci_method = c("wald",
                                   "clopper-pearson",
                                   "agresti-coull",
                                   "wilson"),
                     test_method = c("z",
                                     "chisq",
                                     "fisher_exact",
                                     "none"),
                     alpha = 0.05,
                     ...) {

  ci_method <- match.arg(ci_method)
  test_method <- match.arg(test_method)



  original_study_tbl <- study_tbl

  tabulate_list <- crosstab(study_tbl,
                            outcome,
                            exposure,
                            TRUE)

  list2env(tabulate_list,
           envir = environment())

  object <- list(outcome_name = outcome_name,
                 outcome = out_var)

  if (!is.null(exposure)) {
    object$exposure_name <- exposure_name
    object$exposure <- exp_var
  }

  object$contingency_table <- contingency_table

  p_outcome_list <- onesample_ci(
    out_bin,
    ci_method,
    alpha
  )

  object$ci_method <- ci_method
  object$alpha <- alpha
  object$p_outcome <- p_outcome_list$p_hat
  object$p_outcome_ci <- p_outcome_list$p_hat_ci

  if (!is.null(exposure)) {
    p_exposure_list <- onesample_ci(
      exp_bin,
      ci_method,
      alpha
    )

    object$p_exposure <- p_exposure_list$p_hat
    object$p_exposure_ci <- p_exposure_list$p_hat_ci

    moa_table <- moa_ci(
      contingency_table$data,
      alpha
    )

    object$compare_ci = moa_table

    p_test <- test_result <- NA
    if (test_method == "fisher_exact") {
      test_result <- fisher.test(contingency_table$data, ...)
      p_test <- data.frame(
        or_estimate = test_result$estimate,
        p_value = test_result$p.value
      )
    } else {
      extra_args <- list(...)
      relevant_args <- extra_args[names(extra_args) %in% names(formals(chisq.test))]
      if (is.null(relevant_args[["correct"]])) {
        relevant_args[["correct"]] <- FALSE
      }

      if (test_method == "chisq") {
        test_result <- do.call(chisq.test,
                               c(list(x = contingency_table$data),
                                 relevant_args))

        p_test <- data.frame(
          statistic = test_result$statistic,
          df = test_result$parameter,
          p_value = test_result$p.value
        )
      } else if (test_method == "z") {
        test_result <- do.call(prop.test,
                               c(list(x = contingency_table$data),
                                 relevant_args))

        p_test <- data.frame(
          statistic = test_result$statistic,
          df = test_result$parameter,
          p_value = test_result$p.value
        )
      }
    }

    object$compare_test <- list(test_method = test_method,
                                test_summary = p_test,
                                test_object = test_result)
  }

  class(object) <- "anthill"
  return(object)
}

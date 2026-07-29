twobytwo <- function(study_tbl,
                     exposure,
                     outcome,
                     ci_method = c("clopper-pearson",
                                   "wald",
                                   "agresti-coull",
                                   "wilson",
                                   "none"),
                     test_method = c("chisq",
                                     "fisher_exact",
                                     "none"),
                     alpha = 0.05,
                     ...) {

  # assertions on arguments
  ci_method <- match.arg(ci_method)
  test_method <- match.arg(test_method)

  original_study_tbl <- study_tbl

  exposure_list <- prepare_var(
    study_tbl,
    exposure
  )

    outcome_list <- prepare_var(
    study_tbl,
    outcome
  )

  vars_list <- remove_attr_na(
    exposure_list,
    outcome_list
  )

  list2env(vars_list,
           envir = environment())

  exposure_name <- exposure_list[["attr_name"]]
  exp_var <- exposure_list[["attr_var"]]
  exp_bin <- exposure_list[["attr_bin"]]

  outcome_name <- outcome_list[["attr_name"]]
  out_var <- outcome_list[["attr_var"]]
  out_bin <- outcome_list[["attr_bin"]]

  cont_table <- tibble::tibble(
    !!rlang::sym(exposure_name) := exp_var,
    !!rlang::sym(outcome_name) := out_var
  ) %>%
    table()

  if (ci_method != "none") {
    p_exposure_list <- onesample_ci(
      exp_bin,
      ci_method,
      alpha
    )

    p_outcome_list <- onesample_ci(
      out_bin,
      ci_method,
      alpha
    )
  }

  moa_table <- moa_ci(
    cont_table,
    alpha
  )

  p_test <- test_result <- NA
  if (test_method == "fisher_exact") {
    test_result <- fisher.test(cont_table, ...)
    p_test <- tibble::tibble(
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
                        c(list(x = cont_table),
                          relevant_args))

      p_test <- tibble::tibble(
        statistic = test_result$statistic,
        df = test_result$parameter,
        p_value = test_result$p.value
      )
    } else if (test_method != "none") {
      test_result <- do.call(prop.test,
                        c(list(x = cont_table),
                          relevant_args))

      p_test <- tibble::tibble(
        statistic = test_result$statistic,
        df = test_result$parameter,
        p_value = test_result$p.value
      )
    }
  }

  object <- list(exposure_name = exposure_name,
                 exposure = exp_var,
                 outcome_name = outcome_name,
                 outcome = out_var,
                 contingency_table = cont_table,
                 ci_method = ci_method,
                 p_exposure = p_exposure_list[["p_hat"]],
                 p_exposure_ci = p_exposure_list[["p_hat_ci"]],
                 p_outcome = p_outcome_list[["p_hat"]],
                 p_outcome_ci = p_outcome_list[["p_hat_ci"]],
                 compare_ci = moa_table,
                 compare_test = list(test_method = test_method,
                                     test_summary = p_test,
                                     test_object = test_result))
  class(object) <- "anthill"

  return(object)
}

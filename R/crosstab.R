#' Generate contingency table with relevant counts and percentages
#'
#' @inheritParams twobytwo study_tbl outcome exposure
#' @param include_missing A logical flag. If `TRUE`, then analysis will treat missing values as a distinct category and tabulate accordingly. Default value is `FALSE`.
#'
#' @returns An object of class `antcon`, which is a list containing:
#'        - `data`: The 1 x 2 `table` of counts tabulating the `outcome` column (if `exposure` is `NULL`) or the 2 x 2 `table` of counts, cross-tabulating the `exposure` and `outcome` columns.
#'        - `row_prop`: A matrix of row-wise proportions of `data` (if `exposure` is not `NULL`).
#'        - `col_prop`: A matrix of column-wise proportions of `data` (if `exposure` is not `NULL`).
#'        - `cell_prop`: A matrix of cell-wise proportions of `data`.
#'
#' @export
#'
#' @example inst/examples/examples-crosstab.R
crosstab <- function(study_tbl,
                     outcome,
                     exposure = NULL,
                     include_missing = FALSE) {

  TBT_FLAG <- FALSE

  if (grepl("==", outcome)) {
    loc_equal <- regexpr("==", outcome, fixed = TRUE)
    outcome <- trimws(substr(outcome, 1, loc_equal - 1))
  }

  if (!is.null(exposure)) {
    if (grepl("==", exposure)) {
      loc_equal <- regexpr("==", exposure, fixed = TRUE)
      exposure <- trimws(substr(exposure, 1, loc_equal - 1))
    }
  }

  outcome_list <- prepare_var(
    study_tbl,
    outcome,
    TBT_FLAG
  )

  if (!is.null(exposure)) {
    exposure_list <- prepare_var(
      study_tbl,
      exposure,
      TBT_FLAG
    )
  } else {
    exposure_list <- NULL
  }

  if (include_missing) {
    vars_list <- add_missing(
      exposure_list,
      outcome_list
    )
  } else {
    vars_list <- remove_attr_na(
      exposure_list,
      outcome_list
    )
  }

  list2env(vars_list,
           envir = environment())

  outcome_name <- outcome_list[["attr_name"]]
  out_var <- outcome_list[["attr_var"]]
  out_bin <- outcome_list[["attr_bin"]]

  if (!is.null(exposure)) {
    exposure_name <- exposure_list[["attr_name"]]
    exp_var <- exposure_list[["attr_var"]]
    exp_bin <- exposure_list[["attr_bin"]]
  } else {
    exp_var <- exposure_name <- NULL
  }

  get_contingency(out_var,
                  outcome_name,
                  exp_var,
                  exposure_name)
}



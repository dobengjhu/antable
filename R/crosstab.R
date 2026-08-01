#' Generate contingency table with relevant counts and percentages
#'
#' @inheritParams twobytwo study_tbl outcome exposure
#' @param tbt_flag A logical flag. If `TRUE`, then output will be supplied to [`twobytwo()`]; otherwise, output returned to user.
#'
#' @returns
#' @export
#'
#' @examples
crosstab <- function(study_tbl,
                     outcome,
                     exposure = NULL,
                     tbt_flag = FALSE) {

  if (!tbt_flag) {
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
  }

  outcome_list <- prepare_var(
    study_tbl,
    outcome
  )

  if (!is.null(exposure)) {
    exposure_list <- prepare_var(
      study_tbl,
      exposure
    )
  } else {
    exposure_list <- NULL
  }

  vars_list <- remove_attr_na(
    exposure_list,
    outcome_list
  )

  list2env(vars_list,
           envir = environment())

  outcome_name <- outcome_list[["attr_name"]]
  out_var <- outcome_list[["attr_var"]]
  out_bin <- outcome_list[["attr_bin"]]

  if (!is.null(exposure)) {
    exposure_name <- exposure_list[["attr_name"]]
    exp_var <- exposure_list[["attr_var"]]
    exp_bin <- exposure_list[["attr_bin"]]

    # generate summary statistics and estimates
    cont_table <- data.frame(
      exposure_col = exp_var,
      outcome_col = out_var
    )
    colnames(cont_table) <- c(exposure_name, outcome_name)
    cont_table <- table(cont_table)

    cont_table_list <- list(data = cont_table)
    cont_table_list$row_prop <- prop.table(cont_table, margin = 1)
    cont_table_list$col_prop <- prop.table(cont_table, margin = 2)
    cont_table_list$cell_prop <- prop.table(cont_table)

    if (tbt_flag) {
      list(exposure_name = exposure_name,
           outcome_name = outcome_name,
           exp_var = exp_var,
           out_var = out_var,
           exp_bin = exp_bin,
           out_bin = out_bin,
           contingency_table = cont_table_list)
    } else {
      class(cont_table_list) <- "antcon"
      cont_table_list
    }
  } else {
    cont_table <- data.frame(
      outcome_col = out_var
    )
    colnames(cont_table) <- outcome_name
    cont_table <- table(cont_table)

    cont_table_list <- list(data = cont_table)
    cont_table_list$cell_prop <- prop.table(cont_table)

    if (tbt_flag) {
      list(outcome_name = outcome_name,
           out_var = out_var,
           out_bin = out_bin,
           contingency_table = cont_table_list)
    } else {
      class(cont_table_list) <- "antcon"
      cont_table_list
    }
  }
}

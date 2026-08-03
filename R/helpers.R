#' Prepare variables for contingency table analysis
#'
#' @param tbl A data.frame or tbl containing the variable of interest, as specified in the `attr` argument.
#' @param attr A string specifying either a binary variable in `tbl`, or the variable and associated level of interest useing the form `"var_name == var_level"`.
#' @param tbt_flag A logical flag. If `TRUE`, output will be returned to [twobytwo()]; If `FALSE`, output will be returned to [crosstab()].
#'
#' @returns A list containing:
#'    - `attr_name`: The name of the `attr` variable.
#'    - `attr_val`: A vector of the values of the `attr` variable as captured in `tbl`.
#'    - `attr_var`: A vector of the values of the `attr` variable expressed as an ordered factor.
#'    - `attr_bin`: A logical vector indicating whether or not a value of `attr` is equal to the value of interest.
prepare_var <- function(tbl,
                        attr,
                        tbt_flag) {

  if (grepl("==", attr, fixed = TRUE)) {
    attr_list <- parse_var(attr)
    attr_name <- attr_list[["name"]]

    assert_column_names_exist(tbl, attr_name)
    if (tbt_flag) assert_binary(tbl, attr_name)

    attr_val <- attr_list[["val"]]
    attr_var <- as.factor(tbl[[attr_name]])

    if (!(levels(attr_var)[2] == attr_val)) {
      attr_var <- factor(attr_var,
                         levels = rev(levels(attr_var)))
    }
  } else {
    attr_name <- attr

    assert_column_names_exist(tbl, attr_name)
    if (tbt_flag) assert_binary(tbl, attr_name)

    attr_var <- as.factor(tbl[[attr]])
    attr_val <- levels(attr_var)[2]
  }

  attr_bin <- attr_var == attr_val

  list(
    attr_name = attr_name,
    attr_val = attr_val,
    attr_var = attr_var,
    attr_bin = attr_bin
  )
}

#' Parse a string to define value of interest for a given variable
#'
#' @inheritParams prepare_var attr
#'
#' @returns A list containing:
#'    - `name`: The name of `attr`.
#'    - `val`: The value of `attr` that is the value of interest.
parse_var <- function(attr) {

  loc_equal <- regexpr("==", attr, fixed = TRUE)
  attr_name <- trimws(substr(attr, 1, loc_equal - 1))

  match_end <- loc_equal + attr(loc_equal, "match.length") - 1
  attr_val <- substr(attr, match_end + 1, nchar(attr))
  attr_val <- trimws(attr_val)
  attr_val <- gsub("['\"]", "", attr_val)

  check_attr_val <- suppressWarnings(as.numeric(attr_val))
  if (!is.na(check_attr_val)) {
    attr_val <- as.numeric(attr_val)
  }

  list(name = attr_name,
       val = attr_val)
}

#' Remove observations with missing exposure or outcome from analysis
#'
#' @param exp_list A list containing two versions of the exposure variable:
#'    - A factor version
#'    - A logical version
#' @param out_list A list containing two versions of the outcome variable:
#'    - A factor version
#'    - A logical version
#'
#' @returns A list containing:
#'    - `exposure_list`: `exp_list` with all entries that are missing either exposure or outcome information removed
#'    - `outcome_list`: `out_list` with all entries that are missing either exposure or outcome information removed
remove_attr_na <- function(exp_list,
                           out_list) {

  exp_na_id <- which(is.na(exp_list[["attr_var"]]))
  out_na_id <- which(is.na(out_list[["attr_var"]]))

  if (sum(length(exp_na_id), length(out_na_id)) > 0) {
    na_id <- unique(c(exp_na_id, out_na_id))

    exp_list[["attr_var"]] <- exp_list[["attr_var"]][-na_id]
    exp_list[["attr_bin"]] <- exp_list[["attr_bin"]][-na_id]
    out_list[["attr_var"]] <- out_list[["attr_var"]][-na_id]
    out_list[["attr_bin"]] <- out_list[["attr_bin"]][-na_id]
  }

  list(
    exposure_list = exp_list,
    outcome_list = out_list
  )
}

#' Define missing values as separate and distinct category
#'
#' @param exp_list A list containing two versions of the exposure variable:
#'    - A factor version
#'    - A logical version
#' @param out_list A list containing two versions of the outcome variable:
#'    - A factor version
#'    - A logical version
#'
#' @returns A list containing:
#'    - `exposure_list`: `exp_list` with all entries that are missing their value recoded as "Missing"
#'    - `outcome_list`: `out_list` with all entries that are missing their value recoded as "Missing"
add_missing <- function(exp_list,
                        out_list) {

  exp_list$attr_var <- factor(exp_list$attr_var, exclude = NULL)
  levels(exp_list$attr_var)[is.na(levels(exp_list$attr_var))] <- "Missing"
  out_list$attr_var <- factor(out_list$attr_var, exclude = NULL)
  levels(out_list$attr_var)[is.na(levels(out_list$attr_var))] <- "Missing"

  list(
    exposure_list = exp_list,
    outcome_list = out_list
  )
}

#' Create contingency tables
#'
#' @param out_var Factor version of `outcome` variable.
#' @param outcome_name Name of `outcome` variable.
#' @param exp_var Factor version of `exposure` variable. Defaults to `NULL`.
#' @param exposure_name Name of `exposure` variable. Defaulte to `NULL`.
#'
#' @returns An object of class `antcon`, which is a list containing:
#'        - `data`: The 1 x 2 `table` of counts tabulating the `outcome` column (if `exp_var` and `exposure_name` are not `NULL`) or the 2 x 2 `table` of counts, cross-tabulating the `exposure` and `outcome` columns.
#'        - `row_prop`: A matrix of row-wise proportions of `data` (if `exp_var` and `exposure_name` are not `NULL`).
#'        - `col_prop`: A matrix of column-wise proportions of `data` (if `exp_var` and `exposure_name` are not `NULL`).
#'        - `cell_prop`: A matrix of cell-wise proportions of `data`.
get_contingency <- function(out_var,
                            outcome_name,
                            exp_var = NULL,
                            exposure_name = NULL) {

  if (!any(is.null(exp_var), is.null(exposure_name))) {
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
  } else {
    cont_table <- data.frame(
      outcome_col = out_var
    )
    colnames(cont_table) <- outcome_name
    cont_table <- table(cont_table)

    cont_table_list <- list(data = cont_table)
    cont_table_list$cell_prop <- prop.table(cont_table)
  }

  class(cont_table_list) <- "antcon"
  cont_table_list
}

#' Assert tbl Object Contains Specified Column(s)
#'
#' @param table_object tbl. A tbl in which to check for supplied column name(s).
#' @param ... One or more column names (as strings).
#'
#' @return Invisibly returns TRUE when all checks pass; otherwise throws an error.
assert_column_names_exist <- function(table_object, ...) {
  dots <- list(...)

  if (!all(vapply(dots, is.character, logical(1)))) {
    stop("At least one of the supplied values is not a string.", call. = FALSE)
  }

  column_names <- unlist(dots, use.names = FALSE)

  missing_cols <- setdiff(column_names, colnames(table_object))
  if (length(missing_cols) > 0) {
    stop(
      paste0(
        "At least one of the following columns does not exist in the supplied table object:\n",
        paste(missing_cols, collapse = " | ")
      ),
      call. = FALSE
    )
  }

  invisible(TRUE)
}

#' Assert that a column in a data frame is binary
#'
#' @param table_object data.frame, tibble, or matrix.  An object containing the column to check.
#' @param ... One or more column names (as strings).
#'
#' @return Invisibly returns TRUE when all checks pass; otherwise throws an error.
assert_binary <- function(table_object, ...) {

  dots <- unlist(list(...))

  for (column_name in dots) {
    col_val <- setdiff(unique(table_object[[column_name]]), NA)
    if (length(col_val) != 2) {
      stop(paste0("`", column_name, "` values must be binary."),
           call. = FALSE)
    }
  }

  invisible(TRUE)
}

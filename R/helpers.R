#' Prepare variables for contingency table analysis
#'
#' @param tbl A data.frame or tbl containing the variable of interest, as specified in the `attr` argument.
#' @param attr A string specifying either a binary variable in `tbl`, or the variable and associated level of interest useing the form `"var_name == var_level"`.
#'
#' @returns A list containing:
#'    - `attr_name`: The name of the `attr` variable.
#'    - `attr_val`: A vector of the values of the `attr` variable as captured in `tbl`.
#'    - `attr_var`: A vector of the values of the `attr` variable expressed as an ordered factor.
#'    - `attr_bin`: A logical vector indicating whether or not a value of `attr` is equal to the value of interest.
prepare_var <- function(tbl,
                        attr) {

  if (grepl("==", attr, fixed = TRUE)) {
    attr_list <- parse_var(attr)
    attr_name <- attr_list[["name"]]
    attr_val <- attr_list[["val"]]

    attr_var <- as.factor(tbl[[attr_name]])

    if (!(levels(attr_var)[2] == attr_val)) {
      attr_var <- factor(attr_var,
                         levels = rev(levels(attr_var)))
    }
  } else {
    attr_name <- attr
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

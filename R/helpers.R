prepare_var <- function(tbl,
                        attr) {

  if (stringr::str_detect(attr, "==")) {
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
  }

  attr_bin <- attr_var == levels(attr_var)[2]

  list(
    attr_name = attr_name,
    attr_val = attr_val,
    attr_var = attr_var,
    attr_bin = attr_bin
  )
}

parse_var <- function(attr) {
  loc_equal <- stringr::str_locate(attr, "==")
  attr_name <- attr %>%
    stringr::str_sub(
      start = 1,
      end = loc_equal[1, 1] - 1
    ) %>%
    stringr::str_trim()

  attr_val <- attr %>%
    stringr::str_sub(
      start = loc_equal[1, 2] + 1
    ) %>%
    stringr::str_trim() %>%
    stringr::str_replace_all("['\"]", "")

  check_attr_val <- suppressWarnings(as.numeric(attr_val))
  if (!is.na(check_attr_val)) {
    attr_val <- as.numeric(attr_val)
  }

  list(name = attr_name,
       val = attr_val)
}

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

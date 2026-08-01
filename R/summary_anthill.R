#' Summarizing contingency table analysis results
#'
#' @param object An object of class "anthill", usually a result of a call to [twobytwo()].
#' @param ... Further arguments passed to or from other methods.
#'
#' @returns The function summary.anthill returns the list of summary statistics given in `object` (refer to [twobytwo()] for more details)
#'
#' @exportS3Method
summary.anthill <- function(object,
                            ...) {

  if (!inherits(object, "anthill")) {
    stop("Object must be of class anthill", call. = FALSE)
  }

  summary_list <- object
  class(summary_list) <- "summary.anthill"
  print(summary_list, ...)
}

#' @describeIn summary.anthill Print the summary of contingency table analysis
#'
#' @param x An object of class "summary.anthill", usually, a result of a call to `summary.anthill`.
#' @param ... Further arguments passed to or from other methods.
#'
#' @exportS3Method
print.summary.anthill <- function(x,
                                  ...) {

  dots <- list(...)

  if ("digits" %in% names(dots)) {
    digits = dots$digits
  } else {
    digits = max(3L, getOption("digits") - 3L)
  }

  ci_method <- tools::toTitleCase(x$ci_method)

  # ── helpers ────────────────────────────────────────────────────────────────

  rule  <- function(char = "\u2550", width = 15) cat(strrep(char, width), "\n")
  hrule <- function(char = "\u2500", width) cat(strrep(char, width), "\n")

  fmt <- function(x, d = digits) formatC(x, digits = d, format = "g")

  section <- function(section_text) {
    cat(section_text)
    hrule(width = 54 - nchar(section_text))
    cat("\n")
  }

  # ── banner ─────────────────────────────────────────────────────────────────

  rule()
  cat("ANTABLE SUMMARY\n")
  rule()

  cat(sprintf("Outcome  : %s (n = %d)\n",
              x$outcome_name,  length(x$outcome)))
  if ("exposure" %in% names(x)) cat(sprintf("Exposure : %s (n = %d)\n",
                                            x$exposure_name, length(x$exposure)))
  cat("\n")

  # ── contingency table ──────────────────────────────────────────────────────
  if ("contingency_table" %in% names(x)) {
    section("CONTINGENCY TABLE")

    print.summary.antcon(x$contingency_table)
    cat("\n")
  }

  # ── prevalences ───────────────────────────────────────────────────────────
  section("PREVALENCE")

  var_list <- list(x$outcome)
  varname_list <- list(x$outcome_name)
  p_vec <- c(x$p_outcome)
  ci_list <- list(x$p_outcome_ci)

  if ("exposure" %in% names(x)) {
    var_list <- c(var_list, list(x$exposure))
    varname_list <- c(varname_list, list(x$exposure_name))
    p_vec <- c(p_vec, x$p_exposure)
    ci_list <- c(ci_list, list(x$p_exposure_ci))
  }

  of_interest <- lapply(var_list, function(x) x[2L])

  prev_rowname <- mapply(function(x, y) paste0("P(", x, " = ", y, ")"),
                         varname_list,
                         of_interest,
                         SIMPLIFY = TRUE)

  prev_ci <- sapply(ci_list, function(x, digits) sprintf(paste0("[%.", digits,
                                                                "f, %.", digits,
                                                                "f]"),
                                                         x[1],
                                                         x[2]),
                    digits = digits)

  prev_df <- data.frame(
    est = round(p_vec, digits),
    ci = prev_ci
  )

  rownames(prev_df) <- prev_rowname
  colnames(prev_df) <- c("Estimate",
                         paste0(ci_method, " ",
                                round(100 * (1 - x$alpha)), "% CI"))

  print(prev_df)
  cat("\n")

# ── association measures ──────────────────────────────────────────────────

if ("compare_ci" %in% names(x)) {
  section("EXPOSURE-OUTCOME ASSOCIATION")

  moa_ci <- sprintf(paste0("[%.", digits,
                           "f, %.", digits,
                           "f]"),
                    x$compare_ci$lower_ci,
                    x$compare_ci$upper_ci)

  moa_df <- data.frame(
    est = round(x$compare_ci$estimate, digits),
    ci = moa_ci
  )

  rownames(moa_df) <- x$compare_ci$measure
  colnames(moa_df) <- c("Estimate",
                        paste0(round(100 * (1 - x$alpha)),
                               "% CI"))

  print(moa_df)
  cat("\n")
}

# ── test of association ───────────────────────────────────────────────────
if ("compare_test" %in% names(x)) {
  test_method <- x$compare_test$test_method

  if (test_method == "fisher_exact") {

    section("FISHER'S EXACT TEST")
    or_f <- fmt(x$compare_test$test_summary$or_estimate)
    p_f  <- if (x$compare_test$test_summary$p_value < 0.001) "< 0.001" else fmt(x$compare_test$test_summary$p_value, 3)
    cat(sprintf("OR = %s  (Fisher MLE),  p = %s\n",
                or_f, p_f))

  } else if (test_method == "chisq") {

    section("CHI-SQUARED TEST")
    stat <- x$compare_test$test_summary$statistic
    df   <- x$compare_test$test_summary$df
    pval <- x$compare_test$test_summary$p_value
    p_str <- if (pval < 0.001) "< 0.001" else fmt(pval, 3)
    cat(sprintf("\u03c7\u00b2(%d) = %s,  p = %s\n",
                df, fmt(stat), p_str))

  } else if (test_method == "z") {
    section("TWO-PROPORTION Z TEST")
    stat <- x$compare_test$test_summary$statistic
    df   <- x$compare_test$test_summary$df
    pval <- x$compare_test$test_summary$p_value
    p_str <- if (pval < 0.001) "< 0.001" else fmt(pval, 3)
    cat(sprintf("Z = %s,  df = %d, p = %s\n",
                fmt(stat), df, p_str))
  }
}

invisible(x)
}

#' Summarizing cross-tabulation results
#'
#' @param object An object of class "antcon", usually a result of a call to [antable::tabulate()].
#' @param ... Further arguments passed to or from other methods.
#'
#' @returns The function summary.antcon returns the list of summary statistics given in `object` (refer to [antable::tabulate()] for more details)
#'
#' @exportS3Method
summary.antcon <- function(object,
                           ...) {

  if (!inherits(object, "antcon")) {
    stop("Object must be of class antcon", call. = FALSE)
  }

  summary_list <- object
  class(summary_list) <- "summary.antcon"
  summary_list
}

#' @describeIn summary.antcon Print the summary of contingency table
#'
#' @param x An object of class "summary.antcon", usually, a result of a call to `summary.antcon`.
#' @param ... Further arguments passed to or from other methods.
#'
#' @exportS3Method
print.summary.antcon <- function(x) {
  data <- x$data

  if (length(dim(data)) == 2) {
    print_two_way(x)
  } else {
    print_one_way(x)
  }
  invisible(x)
}

#' Print two variable crosstabulation
#'
#' @inheritParams print.summary.antcon x
print_two_way <- function(x) {
  data      <- x$data
  row_prop  <- x$row_prop
  col_prop  <- x$col_prop
  cell_prop <- x$cell_prop
  row_var   <- names(dimnames(data))[1]
  col_var   <- names(dimnames(data))[2]
  row_names <- rownames(data)
  col_names <- colnames(data)
  nr <- nrow(data)
  nc <- ncol(data)
  row_totals  <- rowSums(data)
  col_totals  <- colSums(data)
  grand_total <- sum(data)

  fmt_n   <- function(n) format(n, big.mark = ",")
  fmt_pct <- function(p) sprintf("%.2f%%", p * 100)

  cell_block <- function(i, j) {
    c(fmt_n(data[i, j]),
      fmt_pct(row_prop[i, j]),
      fmt_pct(col_prop[i, j]),
      fmt_pct(cell_prop[i, j]))
  }
  row_total_block <- function(i) c(fmt_n(row_totals[i]), "", "", "")
  col_total_block <- function(j) c(fmt_n(col_totals[j]), "", "", "")
  grand_block <- c(fmt_n(grand_total), "", "", "")

  blocks <- vector("list", (nr + 1) * (nc + 1))
  dim(blocks) <- c(nr + 1, nc + 1)
  for (i in seq_len(nr)) for (j in seq_len(nc)) blocks[[i, j]] <- cell_block(i, j)
  for (i in seq_len(nr)) blocks[[i, nc + 1]] <- row_total_block(i)
  for (j in seq_len(nc)) blocks[[nr + 1, j]] <- col_total_block(j)
  blocks[[nr + 1, nc + 1]] <- grand_block

  col_labels <- c(col_names, "Total")
  row_labels <- c(row_names, "Total")

  col_width <- sapply(seq_len(nc + 1), function(j) {
    w <- max(sapply(seq_len(nr + 1), function(i) max(nchar(blocks[[i, j]]))))
    max(w, nchar(col_labels[j]))
  })
  row_label_width <- max(nchar(row_labels), nchar(row_var))

  pad_label <- function(s, w) formatC(s, width = -w)
  pad_val   <- function(s, w) formatC(s, width = w)

  # width = label + gap + columns + gaps between columns (ncol_total - 1 gaps)
  total_width <- row_label_width + 2 + sum(col_width) + 2 * nc

  cat(strrep(" ", row_label_width), "  ", col_var, "\n", sep = "")
  cat(pad_label(row_var, row_label_width), "  ",
      paste(mapply(pad_val, col_labels, col_width), collapse = "  "),
      "\n", sep = "")
  cat(strrep("-", total_width), "\n")

  for (i in seq_len(nr + 1)) {
    n_lines <- if (i <= nr) 4 else 1
    for (line in seq_len(n_lines)) {
      label <- if (line == 1) row_labels[i] else ""
      vals  <- sapply(seq_len(nc + 1), function(j) pad_val(blocks[[i, j]][line], col_width[j]))
      cat(pad_label(label, row_label_width), "  ", paste(vals, collapse = "  "), "\n", sep = "")
    }
    cat(strrep("-", total_width), "\n")
  }

  cat("Key: count / row % / col % / cell %\n")
}

#' Print single variable tabulation
#'
#' @inheritParams print.summary.antcon x
print_one_way <- function(x) {
  data      <- x$data
  cell_prop <- x$cell_prop
  var_name  <- names(dimnames(data))[1]
  val_names <- names(data)

  grand_total <- sum(data)

  fmt_n   <- function(n) format(n, big.mark = ",")
  fmt_pct <- function(p) sprintf("%.2f%%", p * 100)

  col_labels <- c(val_names, "Total")
  n_line     <- c(fmt_n(as.numeric(data)), fmt_n(grand_total))
  pct_line   <- c(fmt_pct(as.numeric(cell_prop)), fmt_pct(1))

  row_labels <- c("n", "%")
  row_label_width <- max(nchar(row_labels))

  col_width <- sapply(seq_along(col_labels), function(j) {
    max(nchar(n_line[j]), nchar(pct_line[j]), nchar(col_labels[j]))
  })

  pad_label <- function(s, w) formatC(s, width = -w)
  pad_val   <- function(s, w) formatC(s, width = w)

  total_width <- row_label_width + 2 + sum(col_width) + 2 * (length(col_labels) - 1)

  cat(var_name, "\n", sep = "")
  cat(pad_label("", row_label_width), "  ",
      paste(mapply(pad_val, col_labels, col_width), collapse = "  "),
      "\n", sep = "")
  cat(strrep("-", total_width), "\n")

  cat(pad_label("n", row_label_width), "  ",
      paste(mapply(pad_val, n_line, col_width), collapse = "  "),
      "\n", sep = "")
  cat(pad_label("%", row_label_width), "  ",
      paste(mapply(pad_val, pct_line, col_width), collapse = "  "),
      "\n", sep = "")
  cat(strrep("-", total_width), "\n")

  cat("Key: count / %\n")
}

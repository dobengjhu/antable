#' Title
#'
#' @param object
#' @param ...
#'
#' @returns
#' @export
#'
#' @examples
summary.anthill <- function(object,
                            ...) {

  if (!inherits(object, "anthill")) {
    stop("Object must be of class anthill", call. = FALSE)
  }

  summary_list <- object
  class(summary_list) <- "summary.anthill"
  summary_list
}

#' @describeIn summary.anthill Print the summary of two by two analysis
#'
#' @param x
#' @param ...
#'
#' @export
print.summary.anthill <- function(x,
                                  ...) {
  dots <- list(...)

  if ("digits" %in% names(dots)) {
    digits = dots$digits
  } else {
    digits = max(3L, getOption("digits") - 3L)
  }

  ci_method <- stringr::str_to_title(x$ci_method)

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
  cat(sprintf("Exposure : %s (n = %d)\n",
              x$exposure_name, length(x$exposure)))
  cat(sprintf("Outcome  : %s (n = %d)\n",
              x$outcome_name,  length(x$outcome)))
  cat("\n")

  # ── contingency table ──────────────────────────────────────────────────────
  section("CONTINGENCY TABLE")

  data      <- x$contingency_table$data
  row_prop  <- x$contingency_table$row_prop
  col_prop  <- x$contingency_table$col_prop
  cell_prop <- x$contingency_table$cell_prop

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
  fmt_pct <- function(p) sprintf(paste0("%.", 2, "f%%"), p * 100)

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
  for (i in seq_len(nr)) {
    for (j in seq_len(nc)) {
      blocks[[i, j]] <- cell_block(i, j)
    }
  }

  for (i in seq_len(nr)) {
    blocks[[i, nc + 1]] <- row_total_block(i)
  }

  for (j in seq_len(nc)) {
    blocks[[nr + 1, j]] <- col_total_block(j)
  }

  blocks[[nr + 1, nc + 1]] <- grand_block

  col_labels <- c(col_names, "Total")
  row_labels <- c(row_names, "Total")

  col_width <- sapply(seq_len(nc + 1), function(j) {
    w <- max(sapply(seq_len(nr + 1), function(i) max(nchar(blocks[[i, j]]))))
    max(w, nchar(col_labels[j]))
  })
  row_label_width <- max(nchar(row_labels), nchar(row_var))

  pad_label <- function(s, w) formatC(s, width = -w)  # left align
  pad_val   <- function(s, w) formatC(s, width = w)   # right align
  total_width <- row_label_width + sum(col_width) + length(col_width)

  cat(strrep(" ", row_label_width), "  ", col_var, "\n", sep = "")
  cat(pad_label(row_var, row_label_width), "  ",
      paste(mapply(pad_val, col_labels, col_width), collapse = "  "),
      "\n", sep = "")
  cat(strrep("-", total_width + 1), "\n")

  for (i in seq_len(nr + 1)) {
    n_lines <- if (i <= nr) 4 else 1   # body rows get 4 lines, total row gets 1
    for (line in seq_len(n_lines)) {
      label <- if (line == 1) row_labels[i] else ""
      vals  <- sapply(seq_len(nc + 1), function(j) pad_val(blocks[[i, j]][line], col_width[j]))
      cat(pad_label(label, row_label_width), "  ", paste(vals, collapse = "  "), "\n", sep = "")
    }
    cat(strrep("-", total_width + 1), "\n")
  }

  cat("Key: count / row % / col % / cell %\n")
  cat("\n")

  # ── prevalences ───────────────────────────────────────────────────────────
  section("PREVALENCE")
  exposed <- levels(x$exposure)[2L]
  event <- levels(x$outcome)[2L]

  prev_rowname <- paste0("P(",
                         c(x$exposure_name, x$outcome_name),
                         " = ",
                         c(exposed, event),
                         ")")

  p_exp_ci <- x$p_exposure_ci
  p_out_ci <- x$p_outcome_ci

  prev_ci <- sprintf(paste0("[%.", digits,
                            "f, %.", digits,
                            "f]"),
                     c(p_exp_ci[1], p_out_ci[1]),
                     c(p_exp_ci[2], p_out_ci[2]))

  prev_df <- data.frame(
    est = round(c(x$p_exposure, x$p_outcome), digits),
    ci = prev_ci
  )

  rownames(prev_df) <- prev_rowname
  colnames(prev_df) <- c("Estimate",
                         paste0(ci_method, " ",
                                round(100 * (1 - x$alpha)), "% CI"))

print(prev_df)
cat("\n")

# ── association measures ──────────────────────────────────────────────────

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

# ── test of association ───────────────────────────────────────────────────
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

invisible(x)
}

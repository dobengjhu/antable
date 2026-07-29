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

  assertthat::assert_that(
    "anthill" %in% class(object),
    msg = "Object must be of class anthill"
  )

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
  browser()
  dots <- list(...)

  if ("digits" %in% names(dots)) {
    digits = dots$digits
  } else {
    digits = max(3L, getOption("digits") - 3L)
  }

  ci_method <- stringr::str_to_title(x$ci_method)

  # ── helpers ────────────────────────────────────────────────────────────────

  rule  <- function(char = "\u2550", width = 54) cat(strrep(char, width), "\n")
  hrule <- function(char = "\u2500", width = 54) cat(strrep(char, width), "\n")

  section <- function(title) {
    hrule()
    cat(" ", title, "\n")
    hrule()
  }

  # sig_label <- function(p) {
  #   if (p < 0.001) "***"
  #   else if (p < 0.01)  "**"
  #   else if (p < 0.05)  "*"
  #   else                "not significant"
  # }

  fmt <- function(x, d = digits) formatC(x, digits = d, format = "g")

  # ── banner ─────────────────────────────────────────────────────────────────

  rule()
  cat("  ANTABLE SUMMARY\n")
  rule()
  cat(sprintf("  Exposure : %-12s (n = %d)\n",
              x$exposure_name, length(x$exposure)))
  cat(sprintf("  Outcome  : %-12s (n = %d)\n",
              x$outcome_name,  length(x$outcome)))
  cat("\n")

  # ── contingency table ──────────────────────────────────────────────────────

  section(" Contingency Table")

  ct       <- x$contingency_table          # matrix / table object
  r_levels <- rownames(ct)                 # exposure levels
  c_levels <- colnames(ct)                 # outcome levels
  row_tots <- rowSums(ct)
  col_tots <- colSums(ct)
  grand    <- sum(ct)

  # column widths: max of header label vs cell values (including totals)
  col_w <- pmax(
    nchar(c_levels),
    apply(ct, 2L, function(v) max(nchar(as.character(v)))),
    nchar(as.character(col_tots))
  )
  tot_w    <- max(nchar("Total"), nchar(as.character(grand)), nchar(as.character(row_tots)))
  row_w    <- max(nchar(r_levels), nchar("Total"), nchar(x$exposure_name))
  out_name <- x$outcome_name

  # outcome variable name spans outcome columns (not the Total column)
  outcome_span_w <- sum(col_w) + (length(col_w) - 1L) * 2L   # cells + gaps
  out_name_trunc <- substr(out_name, 1L, outcome_span_w)
  out_name_pad   <- formatC(out_name_trunc,
                            width  = outcome_span_w,
                            flag   = "-")   # left-align within span

  # header line 1: exposure var label | outcome var name (spanned) | (Total blank)
  cat(sprintf("  %-*s  %s\n",
              row_w, x$exposure_name,
              paste0("\u2500\u2500 ", out_name_pad, " \u2500\u2500")))

  # header line 2: blank row stub | column labels | Total
  col_heads <- paste(mapply(formatC, c_levels,
                            width = col_w, MoreArgs = list(flag = " ")),
                     collapse = "  ")
  cat(sprintf("  %-*s  %s  %s\n",
              row_w, "",
              col_heads,
              formatC("Total", width = tot_w, flag = "-")))

  hrule()

  # data rows
  for (i in seq_along(r_levels)) {
    cells <- paste(mapply(formatC, as.integer(ct[i, ]),
                          width = col_w, MoreArgs = list(flag = " ")),
                   collapse = "  ")
    cat(sprintf("  %-*s  %s  %s\n",
                row_w, r_levels[i],
                cells,
                formatC(as.integer(row_tots[i]), width = tot_w)))
  }

  # total row
  hrule()
  tot_cells <- paste(mapply(formatC, as.integer(col_tots),
                            width = col_w, MoreArgs = list(flag = " ")),
                     collapse = "  ")
  cat(sprintf("  %-*s  %s  %s\n",
              row_w, "Total",
              tot_cells,
              formatC(as.integer(grand), width = tot_w)))
  cat("\n")

  # ── prevalences ───────────────────────────────────────────────────────────

  section(sprintf(" Prevalences                              Est.    [95%% CI] (%s)", ci_method))

  p_exp_ci <- get_ci(x$p_exposure_ci)
  p_out_ci <- get_ci(x$p_outcome_ci)

  # reference levels (first level of each factor = reference used in table)
  exp_ref <- levels(x$exposure)[2L]   # "Female" (second level per Levels: Male Female)
  out_ref <- levels(x$outcome)[1L]    # "Sick"

  cat(sprintf("  P(%-10s = %-8s)   %5.1f%%  [%5.1f, %5.1f]\n",
              x$exposure_name, exp_ref,
              x$p_exposure * 100,
              p_exp_ci$lower_95 * 100,
              p_exp_ci$upper_95 * 100))

  cat(sprintf("  P(%-10s = %-8s)   %5.1f%%  [%5.1f, %5.1f]\n",
              x$outcome_name,  out_ref,
              x$p_outcome * 100,
              p_out_ci$lower_95 * 100,
              p_out_ci$upper_95 * 100))
  cat("\n")

  # ── association measures ──────────────────────────────────────────────────

  section(" Exposure-Outcome Association         Est.      [95% CI]")

  for (i in seq_len(nrow(x$compare_ci))) {
    row <- x$compare_ci[i, ]
    cat(sprintf("  %-18s  %8s  [%8s, %8s]\n",
                row$measure,
                fmt(row$estimate),
                fmt(row$lower_95),
                fmt(row$upper_95)))
  }
  cat("\n")

  # ── test of association ───────────────────────────────────────────────────

  test_method <- if (!is.null(x$test_method)) x$test_method else "chi2"

  if (test_method == "fisher") {

    section(" Fisher's Exact Test")
    or_f <- fmt(x$fisher_or)
    p_f  <- if (x$fisher_p < 0.001) "< 0.001" else fmt(x$fisher_p, 3)
    cat(sprintf("  OR = %s  (Fisher MLE),  p = %s   [%s]\n",
                or_f, p_f, sig_label(x$fisher_p)))

  } else {

    section(" Chi-Squared Test")
    stat <- x$compare_test$statistic
    df   <- x$compare_test$df
    pval <- x$compare_test$p_value
    p_str <- if (pval < 0.001) "< 0.001" else fmt(pval, 3)
    cat(sprintf("  \u03c7\u00b2(%d) = %s,  p = %s   [%s]\n",
                df, fmt(stat), p_str, sig_label(pval)))

  }

  rule()
  invisible(x)
}

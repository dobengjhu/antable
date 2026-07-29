#' Calculate estimate and confidence interval for single proportion
#'
#' @inheritParams twobytwo ci_method alpha
#' @param attr_bin A logical vector
#'
#' @returns A list containing:
#'    - `p_hat`: The estimated proportion of `attr_bin` that is `TRUE`
#'    - `p_hat_ci`: The 100 * (1 - `alpha`)% confidence interval for `p_hat` using `ci_method`
onesample_ci <- function(attr_bin,
                         ci_method,
                         alpha) {

  x <- sum(attr_bin)
  n <- length(attr_bin)

  z <- qnorm(1 - alpha / 2)
  p_hat <- x / n

  if (ci_method == "clopper-pearson") {
    # Clopper-Pearson
    lo <- qbeta(alpha / 2, x, n - x + 1)
    hi <- qbeta(1 - alpha / 2, x + 1, n - x)
  } else if (ci_method == "wald") {
    # Wald
    lo <- p_hat - z * sqrt(p_hat * (1 - p_hat) / n)
    hi <- p_hat + z * sqrt(p_hat * (1 - p_hat) / n)
  } else if (ci_method == "agresti-coull") {
    # Agresti-Coull
    n_tilde <- n + z^2
    p_tilde <- (x + z^2 / 2) / n_tilde
    lo <- p_tilde - z * sqrt(p_tilde * (1 - p_tilde) / n_tilde)
    hi <- p_tilde + z * sqrt(p_tilde * (1 - p_tilde) / n_tilde)
  } else {
    # Wilson
    lo <- (2*x + z^2 - z * sqrt(z^2 + 4*x*(1 - p_hat))) / (2 * (n + z^2))
    hi <- (2*x + z^2 + z * sqrt(z^2 + 4*x*(1 - p_hat))) / (2 * (n + z^2))
  }

  list(
    p_hat = p_hat,
    p_hat_ci = c(lo, hi)
  )
}

#' Calculate estimates and confidence interval for risk difference, risk ratio, and odds ratio
#'
#' @inheritParams twobytwo alpha
#' @param ctable A 2 x 2 `table` of counts.
#'
#' @returns A data.frame summarizing the risk difference, risk ratio, and odds ratio comparing the conditional proportions of events across the exposed and unexposed groups. Contains columns `measure` (the measure name), `estimate` (the point estimate), `lower_ci`, and `upper_ci` (the 100 * (1 - `alpha`)% confidence bounds).
moa_ci <- function(ctable,
                   alpha) {

  a <- ctable[1,1]
  b <- ctable[1,2]
  c <- ctable[2,1]
  d <- ctable[2,2]

  n2 <- c + d
  n1 <- a + b
  n  <- n1 + n2

  p2 <- d / n2
  p1 <- b / n1

  z <- qnorm(1 - alpha / 2)

  # Risk Difference (p2 - p1), Wald interval
  rd <- p2 - p1
  rd_se <- sqrt(p1 * (1 - p1) / n1 + p2 * (1 - p2) / n2)
  rd_lo <- rd - z * rd_se
  rd_hi <- rd + z * rd_se

  # Risk Ratio (p2 / p1), log-transformed interval
  rr <- p2 / p1
  rr_se <- sqrt((1 - p2) / d + (1 - p1) / b)
  rr_lo <- exp(log(rr) - z * rr_se)
  rr_hi <- exp(log(rr) + z * rr_se)

  # Odds Ratio (odds2 / odds1), log-transformed interval
  odds2 <- p2 / (1 - p2)
  odds1 <- p1 / (1 - p1)
  or <- odds2 / odds1
  or_se <- sqrt(1 / a + 1 / b + 1 / c + 1 / d)
  or_lo <- exp(log(or) - z * or_se)
  or_hi <- exp(log(or) + z * or_se)

  data.frame(
    measure  = c("Risk Difference", "Risk Ratio", "Odds Ratio"),
    estimate = c(rd, rr, or),
    lower_ci = c(rd_lo, rr_lo, or_lo),
    upper_ci = c(rd_hi, rr_hi, or_hi)
  )
}

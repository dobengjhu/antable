#' Two-sample z test for proportions
#'
#' Tests H0: p_exposed = p_unexposed using a z statistic, with a Wald
#' confidence interval for the risk difference (exposed - unexposed).
#'
#' @importFrom stats pnorm
#' @param x Either a 2x2 table/matrix with rows = (unexposed, exposed) and
#'   columns = (no event, event), or a length-2 vector of event counts
#'   ordered (exposed, unexposed).
#' @param n Length-2 vector of group sizes ordered (exposed, unexposed).
#'   Ignored when `x` is a table.
#' @param alternative "two.sided", "less", or "greater" (for exposed - unexposed).
#' @param conf.level Confidence level for the interval.
#' @return An object of class "htest".
two_prop_z <- function(x,
                       n = NULL,
                       alternative = c("two.sided", "less", "greater"),
                       conf.level = 0.95) {
  alternative <- match.arg(alternative)

  if (is.matrix(x) || is.table(x)) {
    DNAME <- deparse1(substitute(x))
    if (!identical(dim(x), c(2L, 2L)))
      stop("'x' must be a 2x2 table: rows = unexposed, exposed; ",
           "columns = no event, event.",
           call. = FALSE)

    n <- unname(rowSums(x))[c(2, 1)]
    x <- unname(x[, 2])[c(2, 1)]
  } else {
    if (is.null(n))
      stop("Supply 'n' when 'x' is a vector of counts.",
           call. = FALSE)
    DNAME <- paste(deparse1(substitute(x)),
                   "out of",
                   deparse1(substitute(n)))
  }

  if (length(x) != 2 || length(n) != 2)
    stop("'x' and 'n' must each have length 2.",
         call. = FALSE)
  if (!is.numeric(x) || !is.numeric(n) || anyNA(x) || anyNA(n))
    stop("'x' and 'n' must be numeric with no missing values.",
         call. = FALSE)
  if (any(n <= 0) || any(x < 0) || any(x > n))
    stop("Need 0 <= x <= n and n > 0.",
         call. = FALSE)
  if (!is.numeric(conf.level) || length(conf.level) != 1 ||
      conf.level <= 0 || conf.level >= 1)
    stop("'conf.level' must be a single number between 0 and 1.",
         call. = FALSE)

  p <- x / n
  d <- p[1] - p[2]
  se <- sqrt(sum(p * (1 - p) / n))

  if (se == 0)
    stop("Standard error is zero (observed proportions are all 0 or 1); ",
         "the z test is undefined. Consider fisher.test().",
         call. = FALSE)

  z <- d / se
  p_value <- switch(alternative,
    two.sided = 2 * pnorm(-abs(z)),
    less      = pnorm(z),
    greater   = pnorm(z, lower.tail = FALSE)
  )

  cint <- switch(alternative,
    two.sided = d + c(-1, 1) * qnorm((1 + conf.level) / 2) * se,
    less = c(-1, d + qnorm(conf.level) * se),
    greater = c(d - qnorm(conf.level) * se, 1)
  )
  cint <- pmin(pmax(cint, -1), 1)
  attr(cint, "conf.level") <- conf.level

  structure(
    list(statistic   = c(z = z),
         p.value     = p_value,
         estimate    = c("prop exposed" = p[1], "prop unexposed" = p[2]),
         null.value  = c("risk difference" = 0),
         conf.int    = cint,
         alternative = alternative,
         data.name   = DNAME,
         method = "Two-sample z test for proportions (unpooled SE)"),
    class = "htest"
  )
}

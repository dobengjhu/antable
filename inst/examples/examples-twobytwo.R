set.seed(42)
data <- data.frame(
  sex = c("Male", "Female")[rbinom(100, 1, 0.52) + 1],
  disease = c("Sick", "Cured")[rbinom(100, 1, 0.2) + 1]
)

# Basic usage with default exposure/outcome levels
result <- twobytwo(study_tbl = data,
                   exposure = "sex",
                   outcome = "disease")
summary(result)

# Explicitly specify which level represents "exposed"/"event"
twobytwo(study_tbl = data,
         exposure = "sex == 'Female'",
         outcome = "disease == 'Cured'")

# Specify confidence interval and/or hypothesis test method
twobytwo(study_tbl = data,
         exposure = "sex",
         outcome = "disease",
         ci_method = "clopper-pearson",
         test_method = "fisher_exact")

# Skip hypothesis testing entirely
twobytwo(study_tbl = data,
         exposure = "sex",
         outcome = "disease",
         test_method = "none")

set.seed(42)
dat <- data.frame(
  sex = c("Male", "Female")[rbinom(100, 1, 0.52) + 1],
  disease = c("Sick", "Cured")[rbinom(100, 1, 0.2) + 1],
  smoking_status = sample(c("Current", "Former", "Never"),
                          100,
                          replace = TRUE,
                          prob = c(0.4, 0.15, 0.45))
)

# Use crosstab() for standalone cross-tabulation
result_disease <- crosstab(study_tbl = dat,
                           outcome = "disease",
                           exposure = "sex")
summary(result_disease)

result_smoking <- crosstab(study_tbl = dat,
                           outcome = "smoking_status",
                           exposure = "sex")
summary(result_smoking)

# Also works for tabulation of a single variable
result_sex <- crosstab(study_tbl = dat,
                       outcome = "sex",
                       exposure = NULL)
summary(result_sex)

# Option to include missing values as separate category
dat$disease[sample(1:100, 10)] <- NA
result_smoking_missing <- crosstab(study_tbl = dat,
                                   outcome = "smoking_status",
                                   exposure = "sex",
                                   include_missing = TRUE)
summary(result_smoking_missing)

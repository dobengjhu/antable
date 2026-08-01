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
                   exposure = "sex",
                   outcome = "disease")
summary(result_disease)

result_smoking <- crosstab(study_tbl = dat,
                   exposure = "sex",
                   outcome = "smoking_status")
summary(result_smoking)

result_sex <- crosstab(study_tbl = dat,
                       exposure = NULL,
                       outcome = "sex")
summary(result_sex)

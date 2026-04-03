# --- Common test data ---
make_test_data <- function() {
  adsl <- data.frame(
    USUBJID = c("S001", "S002", "S003"),
    TRT01A  = c("Drug", "Drug", "Placebo"),
    stringsAsFactors = FALSE
  )

  adae <- data.frame(
    USUBJID = c("S001", "S001", "S002", "S003"),
    AEDECOD = c("Headache", "Nausea", "Headache", "Fatigue"),
    AEREL   = c("Y", "N", "Y", "N"),
    AESER   = c("N", "N", "Y", "N"),
    TRT01A  = c("Drug", "Drug", "Drug", "Placebo"),
    stringsAsFactors = FALSE
  )

  ae_types <- list(
    make_ae_type("all_ae", "All AEs"),
    make_ae_type("rel_ae", "Related AEs", AEREL == "Y")
  )

  list(adsl = adsl, adae = adae, ae_types = ae_types)
}

# =============================================================================
# jpn_query_base
# =============================================================================

test_that("jpn_query_base returns ARD object without by", {
  td <- make_test_data()

  adae_bound <- bind_by_aetype(td$adae, td$ae_types)

  result <- jpn_query_base(
    data        = adae_bound,
    denominator = td$adsl,
    by          = NULL
  )

  expect_s3_class(result, "card")
  expect_true(nrow(result) > 0)
})

test_that("jpn_query_base returns ARD object with by", {
  td <- make_test_data()

  adae_bound <- bind_by_aetype(td$adae, td$ae_types)

  result <- jpn_query_base(
    data        = adae_bound,
    denominator = td$adsl,
    by          = TRT01A
  )

  expect_s3_class(result, "card")
  expect_true(nrow(result) > 0)
})

test_that("jpn_query_base returns ARD with additional variables", {
  td <- make_test_data()

  adae_bound <- bind_by_aetype(td$adae, td$ae_types)

  result <- jpn_query_base(
    data        = adae_bound,
    denominator = td$adsl,
    by          = TRT01A,
    variables   = AEDECOD
  )

  expect_s3_class(result, "card")
  expect_true(nrow(result) > 0)
})

test_that("jpn_query_base errors when data is not a data.frame", {
  td <- make_test_data()
  expect_error(jpn_query_base(data = "not_df", denominator = td$adsl))
})

test_that("jpn_query_base errors when denominator is not a data.frame", {
  td <- make_test_data()
  adae_bound <- bind_by_aetype(td$adae, td$ae_types)
  expect_error(jpn_query_base(data = adae_bound, denominator = "not_df"))
})

test_that("jpn_query_base errors when required columns are missing in data", {
  td <- make_test_data()
  adae_bound <- bind_by_aetype(td$adae, td$ae_types)
  bad_data <- adae_bound[, setdiff(names(adae_bound), "USUBJID")]

  expect_error(
    jpn_query_base(data = bad_data, denominator = td$adsl),
    "missing column"
  )
})

test_that("jpn_query_base errors when by column is missing in denominator", {
  td <- make_test_data()
  adae_bound <- bind_by_aetype(td$adae, td$ae_types)
  bad_denom <- td$adsl[, "USUBJID", drop = FALSE]

  expect_error(
    jpn_query_base(data = adae_bound, denominator = bad_denom, by = TRT01A),
    "missing.*column"
  )
})

# =============================================================================
# jpn_query_aggregate
# =============================================================================

test_that("jpn_query_aggregate returns ARD object without by", {
  td <- make_test_data()

  result <- jpn_query_aggregate(
    data        = td$adae,
    denominator = td$adsl,
    ae_types    = td$ae_types,
    by          = NULL
  )

  expect_s3_class(result, "card")
  expect_true(nrow(result) > 0)
})

test_that("jpn_query_aggregate returns ARD object with by", {
  td <- make_test_data()

  result <- jpn_query_aggregate(
    data        = td$adae,
    denominator = td$adsl,
    ae_types    = td$ae_types,
    by          = TRT01A
  )

  expect_s3_class(result, "card")
  expect_true(nrow(result) > 0)
})

test_that("jpn_query_aggregate returns ARD with additional variables", {
  td <- make_test_data()

  result <- jpn_query_aggregate(
    data        = td$adae,
    denominator = td$adsl,
    ae_types    = td$ae_types,
    by          = TRT01A,
    variables   = AEDECOD
  )

  expect_s3_class(result, "card")
  expect_true(nrow(result) > 0)
})

test_that("jpn_query_aggregate errors when data is not a data.frame", {
  td <- make_test_data()
  expect_error(
    jpn_query_aggregate(
      data = "not_df", denominator = td$adsl, ae_types = td$ae_types
    )
  )
})

# =============================================================================
# jpn_query_overview
# =============================================================================

test_that("jpn_query_overview returns ARD object without by", {
  td <- make_test_data()

  result <- jpn_query_overview(
    data        = td$adae,
    denominator = td$adsl,
    ae_types    = td$ae_types,
    by          = NULL
  )

  expect_s3_class(result, "card")
  expect_true(nrow(result) > 0)
})

test_that("jpn_query_overview returns ARD object with by", {
  td <- make_test_data()

  result <- jpn_query_overview(
    data        = td$adae,
    denominator = td$adsl,
    ae_types    = td$ae_types,
    by          = TRT01A
  )

  expect_s3_class(result, "card")
  expect_true(nrow(result) > 0)
})

test_that("jpn_query_overview errors when data is not a data.frame", {
  td <- make_test_data()
  expect_error(
    jpn_query_overview(
      data = "not_df", denominator = td$adsl, ae_types = td$ae_types
    )
  )
})

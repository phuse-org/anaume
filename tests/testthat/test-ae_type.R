# =============================================================================
# make_ae_type
# =============================================================================

test_that("make_ae_type creates ae_type object without condition", {
  obj <- make_ae_type("all_ae", "All AEs")
  expect_s3_class(obj, "ae_type")
  expect_equal(obj$id, "all_ae")
  expect_equal(obj$label, "All AEs")
  expect_true(rlang::quo_is_null(obj$condition))
})

test_that("make_ae_type creates ae_type object with condition", {
  obj <- make_ae_type("rel_ae", "Related AEs", AEREL == "Y")
  expect_s3_class(obj, "ae_type")
  expect_equal(obj$id, "rel_ae")
  expect_equal(obj$label, "Related AEs")
  expect_false(rlang::quo_is_null(obj$condition))
})

test_that("make_ae_type errors when id is not a string", {
  expect_error(make_ae_type(123, "label"))
  expect_error(make_ae_type(c("a", "b"), "label"))
})

test_that("make_ae_type errors when label is not a string", {
  expect_error(make_ae_type("id", 123))
  expect_error(make_ae_type("id", c("a", "b")))
})

# =============================================================================
# ae_id / ae_label / ae_condition
# =============================================================================

test_that("ae_id returns the id", {
  obj <- make_ae_type("my_id", "My Label")
  expect_equal(ae_id(obj), "my_id")
})

test_that("ae_label returns the label", {
  obj <- make_ae_type("my_id", "My Label")
  expect_equal(ae_label(obj), "My Label")
})

test_that("ae_condition returns quo(TRUE) when condition is NULL", {
  obj <- make_ae_type("all_ae", "All AEs")
  cond <- ae_condition(obj)
  expect_true(rlang::is_quosure(cond))
  expect_equal(rlang::eval_tidy(cond), TRUE)
})

test_that("ae_condition returns the stored condition when present", {
  obj <- make_ae_type("rel_ae", "Related AEs", AEREL == "Y")
  cond <- ae_condition(obj)
  expect_true(rlang::is_quosure(cond))
  # Evaluate in a context where AEREL exists

  expect_true(rlang::eval_tidy(cond, data = list(AEREL = "Y")))
  expect_false(rlang::eval_tidy(cond, data = list(AEREL = "N")))
})

test_that("ae_id errors for non-ae_type object", {
  expect_error(ae_id("not_ae_type"))
})

test_that("ae_label errors for non-ae_type object", {
  expect_error(ae_label(list(id = "x", label = "y")))
})

test_that("ae_condition errors for non-ae_type object", {
  expect_error(ae_condition(42))
})

# =============================================================================
# format.ae_type / print.ae_type
# =============================================================================

test_that("format.ae_type returns expected character vector", {
  obj <- make_ae_type("rel_ae", "Related AEs", AEREL == "Y")
  fmt <- format(obj)
  expect_type(fmt, "character")
  expect_true(any(grepl("ae_type", fmt)))
  expect_true(any(grepl("rel_ae", fmt)))
  expect_true(any(grepl("Related AEs", fmt)))
})

test_that("format.ae_type works for condition-less ae_type", {
  obj <- make_ae_type("all_ae", "All AEs")
  fmt <- format(obj)
  expect_true(any(grepl("TRUE", fmt)))
})

test_that("print.ae_type returns invisible and prints output", {
  obj <- make_ae_type("all_ae", "All AEs")
  expect_output(ret <- print(obj), "ae_type")
  expect_identical(ret, obj)
})

# =============================================================================
# merge_ae_types
# =============================================================================

test_that("merge_ae_types combines two ae_types with & by default", {
  rel <- make_ae_type("rel_ae", "Related AEs", AEREL == "Y")
  ser <- make_ae_type("ser_ae", "Serious AEs", AESER == "Y")

  merged <- merge_ae_types(
    list(rel, ser),
    id = "rel_ser",
    label = "Serious Related AEs"
  )

  expect_s3_class(merged, "ae_type")
  expect_equal(ae_id(merged), "rel_ser")
  expect_equal(ae_label(merged), "Serious Related AEs")

  # Evaluate the merged condition
  cond <- ae_condition(merged)
  expect_true(rlang::eval_tidy(cond, data = list(AEREL = "Y", AESER = "Y")))
  expect_false(rlang::eval_tidy(cond, data = list(AEREL = "Y", AESER = "N")))
  expect_false(rlang::eval_tidy(cond, data = list(AEREL = "N", AESER = "Y")))
})

test_that("merge_ae_types combines two ae_types with |", {
  rel <- make_ae_type("rel_ae", "Related AEs", AEREL == "Y")
  ser <- make_ae_type("ser_ae", "Serious AEs", AESER == "Y")

  merged <- merge_ae_types(
    list(rel, ser),
    id = "rel_or_ser",
    label = "Related or Serious AEs",
    op = "|"
  )

  cond <- ae_condition(merged)
  expect_true(rlang::eval_tidy(cond, data = list(AEREL = "Y", AESER = "N")))
  expect_true(rlang::eval_tidy(cond, data = list(AEREL = "N", AESER = "Y")))
  expect_false(rlang::eval_tidy(cond, data = list(AEREL = "N", AESER = "N")))
})

test_that("merge_ae_types errors when ae_types is empty", {
  expect_error(merge_ae_types(list(), id = "x", label = "y"))
})

test_that("merge_ae_types errors when ae_types contains non-ae_type", {
  expect_error(merge_ae_types(list("not_ae_type"), id = "x", label = "y"))
})

test_that("merge_ae_types errors when id is not a string", {
  rel <- make_ae_type("rel_ae", "Related AEs", AEREL == "Y")
  expect_error(merge_ae_types(list(rel), id = 123, label = "y"))
})

test_that("merge_ae_types errors when label is not a string", {
  rel <- make_ae_type("rel_ae", "Related AEs", AEREL == "Y")
  expect_error(merge_ae_types(list(rel), id = "x", label = 123))
})

test_that("merge_ae_types errors when op is invalid", {
  rel <- make_ae_type("rel_ae", "Related AEs", AEREL == "Y")
  ser <- make_ae_type("ser_ae", "Serious AEs", AESER == "Y")
  expect_error(merge_ae_types(list(rel, ser), id = "x", label = "y", op = "+"))
})

# =============================================================================
# apply_ae_type
# =============================================================================

test_that("apply_ae_type filters data and adds id and label columns", {
  df <- data.frame(
    USUBJID = c("S001", "S002", "S003"),
    AEREL   = c("Y", "N", "Y"),
    stringsAsFactors = FALSE
  )
  at <- make_ae_type("rel_ae", "Related AEs", AEREL == "Y")

  result <- apply_ae_type(df, at, label_col = "AETYPE")

  expect_true(is.data.frame(result))
  expect_equal(nrow(result), 2)
  expect_true("id" %in% names(result))
  expect_true("AETYPE" %in% names(result))
  expect_true(all(result$id == "rel_ae"))
  expect_true(all(result$AETYPE == "Related AEs"))
})

test_that("apply_ae_type returns all rows when condition is NULL", {
  df <- data.frame(
    USUBJID = c("S001", "S002"),
    stringsAsFactors = FALSE
  )
  at <- make_ae_type("all_ae", "All AEs")

  result <- apply_ae_type(df, at, label_col = "label")

  expect_equal(nrow(result), 2)
  expect_true(all(result$id == "all_ae"))
  expect_true(all(result$label == "All AEs"))
})

test_that("apply_ae_type uses default label_col = 'label'", {
  df <- data.frame(USUBJID = "S001", stringsAsFactors = FALSE)
  at <- make_ae_type("all_ae", "All AEs")

  result <- apply_ae_type(df, at)

  expect_true("label" %in% names(result))
})

test_that("apply_ae_type errors when ae_type is invalid", {
  df <- data.frame(USUBJID = "S001", stringsAsFactors = FALSE)
  expect_error(apply_ae_type(df, "not_ae_type"))
})

# =============================================================================
# bind_by_aetype
# =============================================================================

test_that("bind_by_aetype binds rows for multiple ae_types", {
  df <- data.frame(
    USUBJID = c("S001", "S002", "S003"),
    AEREL   = c("Y", "N", "Y"),
    AESER   = c("N", "Y", "N"),
    stringsAsFactors = FALSE
  )
  ae_types <- list(
    make_ae_type("all_ae", "All AEs"),
    make_ae_type("rel_ae", "Related AEs", AEREL == "Y")
  )

  result <- bind_by_aetype(df, ae_types)

  expect_true(is.data.frame(result))
  # all_ae: 3 rows + rel_ae: 2 rows = 5 rows

  expect_equal(nrow(result), 5)
  expect_true("AETYPE" %in% names(result))
  expect_true("id" %in% names(result))
  expect_equal(sum(result$AETYPE == "All AEs"), 3)
  expect_equal(sum(result$AETYPE == "Related AEs"), 2)
})

test_that("bind_by_aetype accepts a single ae_type (not wrapped in list)", {
  df <- data.frame(
    USUBJID = c("S001", "S002"),
    stringsAsFactors = FALSE
  )
  at <- make_ae_type("all_ae", "All AEs")

  result <- bind_by_aetype(df, at)

  expect_equal(nrow(result), 2)
  expect_true(all(result$AETYPE == "All AEs"))
})

test_that("bind_by_aetype errors when data is not a data.frame", {
  at <- make_ae_type("all_ae", "All AEs")
  expect_error(bind_by_aetype("not_df", list(at)))
})

test_that("bind_by_aetype errors when ae_types contains non-ae_type", {
  df <- data.frame(USUBJID = "S001", stringsAsFactors = FALSE)
  expect_error(bind_by_aetype(df, list("not_ae_type")))
})

test_that("bind_by_aetype prints messages when verbose = TRUE", {
  df <- data.frame(
    USUBJID = c("S001", "S002"),
    AEREL   = c("Y", "N"),
    stringsAsFactors = FALSE
  )
  ae_types <- list(
    make_ae_type("all_ae", "All AEs"),
    make_ae_type("rel_ae", "Related AEs", AEREL == "Y")
  )

  expect_message(
    bind_by_aetype(df, ae_types, verbose = TRUE),
    "bind_by_aetype"
  )
})

test_that("bind_by_aetype returns zero rows when all conditions match nothing", {
  df <- data.frame(
    USUBJID = c("S001", "S002"),
    AEREL   = c("N", "N"),
    stringsAsFactors = FALSE
  )
  ae_types <- list(
    make_ae_type("rel_ae", "Related AEs", AEREL == "Y")
  )

  result <- bind_by_aetype(df, ae_types)

  expect_equal(nrow(result), 0)
})

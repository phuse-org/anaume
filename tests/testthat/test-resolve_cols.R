test_that("resolve_cols works", {
  expect_no_error(resolve_cols)
})

test_that("resolve_cols returns character vector when given character input", {
  df <- data.frame(A = 1, B = 2, C = 3)
  cols <- c("A", "B")
  result <- resolve_cols(!!cols, df)
  expect_equal(result, c("A", "B"))
})

test_that("resolve_cols resolves bare column name", {
  df <- data.frame(A = 1, B = 2, C = 3)
  result <- resolve_cols(A, df)
  expect_equal(result, "A")
})

test_that("resolve_cols resolves tidyselect expression", {
  df <- data.frame(AA = 1, AB = 2, BC = 3)
  result <- resolve_cols(starts_with("A"), df)
  expect_equal(result, c("AA", "AB"))
})

test_that("resolve_cols resolves everything()", {
  df <- data.frame(X = 1, Y = 2, Z = 3)
  result <- resolve_cols(everything(), df)
  expect_equal(result, c("X", "Y", "Z"))
})

test_that("resolve_cols returns character(0) when NULL is passed", {
  df <- data.frame(A = 1, B = 2)
  result <- resolve_cols(NULL, df)
  expect_equal(result, character(0))
})

test_that("resolve_cols works with multiple column selection via c()", {
  df <- data.frame(A = 1, B = 2, C = 3)
  result <- resolve_cols(c(A, C), df)
  expect_equal(result, c("A", "C"))
})

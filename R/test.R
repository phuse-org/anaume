# パッケージ
library(haven)
library(dplyr)
library(purrr)
library(rlang)
library(tidyselect)
library(cards)

# main の worktree から XPT を読み込み
adae <- haven::read_xpt("C:/Users/c7671/R/proj-main/data/adae.xpt")
adsl <- haven::read_xpt("C:/Users/c7671/R/proj-main/data/adsl.xpt")

# Helper function call
source("C:/Users/c7671/R/proj-main/R/bind_by_aetype.R")
source("C:/Users/c7671/R/proj-main/R/jpn_query_base.R")
source("C:/Users/c7671/R/proj-main/R/resolve_cols.R")
source("C:/Users/c7671/R/proj-main/R/func1.R")

# AEカテゴリの定義
ae_types <- list(
  func1("any_ae",   "Any AE",                       TRUE),
  func1("aeg3",     "AE >= Grade 3",                AEGRD == "Y"),
  func1("sae",      "Any SAE",                      AESER == "Y"),
  func1("fatal",    "Fatal SAEs",                   AESER == "Y" & AEFAT == "Y"),
  func1("disc",     "AE leads drug withdraw",       AEDISCON == "Y"),
  func1("itrr",     "AE leads drug interrupt",      AEITRR == "Y"),
  func1("redu",     "AE leads to dose reduction",   AEREDUCE == "Y")
)

make_ae_type <- function(id, label, condition = NULL) {
  if (!rlang::is_string(id)) {
    cli::cli_abort("{.arg id} must be a string.")
  }

  if (!rlang::is_string(label)) {
    cli::cli_abort("{.arg label} must be a string.")
  }

  cond <- rlang::enquo(condition)

  new_ae_type(id, label, cond)
}

# low level constructor
new_ae_type <- function(id, label, condition) {
  structure(
    list(
      id = id,
      label = label,
      condition = condition
    ),
    class = "ae_type"
  )
}

# validator
validate_ae_type <- function(x) {
  if (!inherits(x, "ae_type")) {
    cli::cli_abort("{.arg x} must be an {.cls ae_type} object.")
  }

  x
}

ae_id <- function(ae_type) {
  validate_ae_type(ae_type)

  ae_type$id
}

ae_label <- function(ae_type) {
  validate_ae_type(ae_type)

  ae_type$label
}

ae_condition <- function(ae_type) {
  validate_ae_type(ae_type)

  cond <- ae_type$condition

  if (rlang::quo_is_null(cond)) {
    rlang::quo(TRUE)
  } else {
    cond
  }
}

format.ae_type <- function(x, ...) {
  validate_ae_type(x)

  id <- ae_id(x)
  label <- ae_label(x)
  cond <- rlang::as_label(ae_condition(x))

  c(
    "<ae_type>",
    paste0("id: ", id),
    paste0("label: ", label),
    paste0("condition: ", cond)
  )
}

print.ae_type <- function(x, ...) {
  cat(format(x), sep = "\n")
  invisible(x)
}

merge_ae_types <- function(ae_types, id, label, op = c("&", "|")) {
  if (!is.list(ae_types) || length(ae_types) == 0) {
    cli::cli_abort("{.arg ae_types} must be a non-empty list.")
  }
  if (!all(purrr::map_lgl(ae_types, \(x) inherits(x, "ae_type")))) {
    cli::cli_abort("All elements of {.arg ae_types} must be {.cls ae_type} objects.")
  }
  if (!rlang::is_string(id)) {
    cli::cli_abort("{.arg id} must be a string.")
  }
  if (!rlang::is_string(label)) {
    cli::cli_abort("{.arg label} must be a string.")
  }

  op <- rlang::arg_match(op)

  cond <- ae_types |>
    purrr::map(\(x) ae_condition(x)) |>
    purrr::reduce(\(x, y) rlang::call2(op, x, y))

  make_ae_type(id, label, !!cond)
}

# AEカテゴリの定義
make_ae_type("rel_ae", "Related AEs", AEREL == "Y")

jpn_query_aggregate <- function(
    data,
    denominator,
    ae_types,
    variables = NULL,
    by = NULL
) {
  stopifnot(is.data.frame(data), is.data.frame(denominator))

  binded_data <- bind_by_aetype(
    data = data,
    ae_types = ae_types
  )

  by_vars  <- resolve_cols({{ by }}, binded_data)
  vars_nm  <- resolve_cols({{ variables }}, binded_data)

  jpn_query_base(
    data        = binded_data,
    denominator = denominator,
    variables   = vars_nm,
    by          = by_vars
  )
}

jpn_query_overview <- function(
    data,
    denominator,
    ae_types,
    by = NULL
) {
  by_vars <- resolve_cols({{ by }}, data)

  jpn_query_aggregate(
    data        = data,
    denominator = denominator,
    ae_types    = ae_types,
    variables   = NULL,
    by          = by_vars
  )
}

# AETYPE × PT（AEDECOD）
jpn_query_ptsummary <- function(
    data,
    denominator,
    ae_types,
    by = NULL
) {
  by_vars <- resolve_cols({{ by }}, data)

  jpn_query_aggregate(
    data        = data,
    denominator = denominator,
    ae_types    = ae_types,
    variables   = AEDECOD,
    by          = by_vars
  )
}

ard <- jpn_query_ptsummary(
  data=adae,
  denominator=adsl,
  ae_types=ae_types,
  by=TRT01A
)



#' Create an `ae_type` object
#'
#' @param id ID value for the object.
#' @param label Label for the AE type.
#' @param condition Expression for subsetting the dataset.
#'
#' @returns An `ae_type` object.
#' @export
#'
#' @examples
#' make_ae_type("all_ae", "All AEs")
#' make_ae_type("rel_ae", "Related AEs", AEREL == "Y")
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

#' Get properties of an `ae_type` object
#'
#' @description
#' `ae_id()` and `ae_label()` return the `id` and `label`
#' properties of an `ae_type` object.
#'
#' `ae_condition()` returns the stored condition. If the
#' condition is `NULL`, it returns `quo(TRUE)` so it can
#' be safely used inside `dplyr::filter()`.
#'
#' @param ae_type An `ae_type` object.
#'
#' @export
#'
#' @examples
#' rel_ae <- make_ae_type("rel_ae", "Related AEs", AEREL == "Y")
#'
#' ae_id(rel_ae)
#' ae_label(rel_ae)
#' ae_condition(rel_ae)
#'
#' all_ae <- make_ae_type("all_ae", "All AEs")
#' ae_condition(all_ae)
ae_id <- function(ae_type) {
  validate_ae_type(ae_type)

  ae_type$id
}

#' @rdname ae_id
#' @export
ae_label <- function(ae_type) {
  validate_ae_type(ae_type)

  ae_type$label
}

#' @rdname ae_id
#' @export
ae_condition <- function(ae_type) {
  validate_ae_type(ae_type)

  cond <- ae_type$condition

  if (rlang::quo_is_null(cond)) {
    rlang::quo(TRUE)
  } else {
    cond
  }
}

#' @export
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

#' @export
print.ae_type <- function(x, ...) {
  cat(format(x), sep = "\n")
  invisible(x)
}

#' Combine multiple `ae_type` objects
#'
#' @param ae_types List of `ae_type` objects.
#' @param id ID for the combined object.
#' @param label Label for the combined object.
#' @param op Logical operator used to combine conditions (`&` or `|`).
#'
#' @return An `ae_type` object.
#' @export
#'
#' @examples
#' rel_ae <- make_ae_type("rel_ae", "Related AEs", AEREL == "Y")
#' ser_ae <- make_ae_type("ser_ae", "Serious AEs", AESER == "Y")
#'
#' merge_ae_types(
#'   list(rel_ae, ser_ae),
#'   id = "rel_ser_ae",
#'   label = "Serious Related AEs"
#' )
merge_ae_types <- function(ae_types, id, label, op = c("&", "|")) {
  if (!is.list(ae_types) || length(ae_types) == 0) {
    cli::cli_abort("{.arg ae_types} must be a non-empty list.")
  }
  if (!all(purrr::map_lgl(ae_types, inherits, "ae_type"))) {
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

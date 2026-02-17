#' Helper function to bind ADAE rows by ae_types: filter by condition, add AETYPE (= label), then row-bind
#'
#' Given a data.frame and one or more `ae_type` objects, this function filters
#' the data by each ae_type's condition, adds an `AETYPE` label column, and
#' row-binds the results together.
#'
#' @param data A data.frame to be filtered (e.g. ADAE).
#' @param ae_types An `ae_type` object or a list of `ae_type` objects.
#'   A single `ae_type` object is automatically wrapped in a list.
#' @param verbose Logical. If `TRUE`, a log message is printed for each
#'   `ae_type` showing the label, id, and number of matched rows.
#'   Default is `FALSE`.
#' @return A data.frame with added columns `id` and `AETYPE`, row-bound
#'   across all ae_types.
#' @importFrom purrr map_dfr
#' @keywords internal
bind_by_aetype <- function(data, ae_types, verbose = FALSE) {
  stopifnot(is.data.frame(data))

  if (inherits(ae_types, "ae_type")) {
    ae_types <- list(ae_types)
  }

  stopifnot(is.list(ae_types))

  result <- purrr::map_dfr(ae_types, function(at) {
    stopifnot(inherits(at, "ae_type"))
    df <- apply_ae_type(data, at, label_col = "AETYPE")
    if (verbose) {
      message(
        sprintf("bind_by_aetype: AETYPE='%s' (id='%s'): %d row(s) matched.",
                ae_label(at), ae_id(at), nrow(df))
      )
    }
    df
  })

  result
}

#' Helper function to apply a single ae_type to a dataset (filter + add id/label)
#' @param data A data.frame to be filtered (e.g. ADAE).
#' @param ae_type An ae_type object created by make_ae_type().
#' @param label_col A character string specifying the name of the label column (default: "label").
#' @return A data.frame with added columns `id`, `label` (or custom label column).
#' @importFrom dplyr filter mutate
#' @keywords internal
apply_ae_type <- function(data, ae_type, label_col = "label") {
  stopifnot(inherits(ae_type, "ae_type"))
  stopifnot(is.character(label_col), length(label_col) == 1L)

  cond <- ae_condition(ae_type)

  df <- if (is.null(cond)) {
    data
  } else {
    dplyr::filter(data, !!cond)
  }

  # always keep id; label column name is configurable (default keeps current behavior)
  dplyr::mutate(
    df,
    id = ae_id(ae_type),
    !!label_col := ae_label(ae_type)
  )
}

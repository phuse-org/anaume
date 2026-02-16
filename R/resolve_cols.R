#' Helper function to resolve column selection (internal helper)
#'
#' Accepts a defused expression via `{{ }}` or `enquo()`, or a character vector.
#'
#' @param expr A defused expression (quosure). Pass with `{{ x }}` or `enquo(x)`.
#' @param data Data frame to resolve column names against.
#' @return Character vector of column names, or `character(0)`.
#' @importFrom rlang enquo quo_is_null eval_tidy
#' @importFrom tidyselect eval_select
#' @keywords internal
resolve_cols <- function(expr, data) {
  quo <- rlang::enquo(expr)
  if (rlang::quo_is_null(quo)) return(character(0))

  # character vector passed programmatically
  result <- tryCatch(rlang::eval_tidy(quo), error = function(e) NULL)
  if (is.character(result)) return(result)

  # bare column name / tidyselect expression
  names(tidyselect::eval_select(quo, data))
}

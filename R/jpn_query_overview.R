#' Create ARD for adverse event overview (AETYPE level only)
#'
#' Convenience wrapper around [jpn_query_aggregate()] that summarizes at the
#' `AETYPE` level only (i.e. `variables = NULL`).
#'
#' @inheritParams jpn_query_aggregate
#'
#' @return A `{cards}` ARD object returned by `cards::ard_stack_hierarchical()`.
#'
#' @examples
#' \dontrun{
#' ard <- jpn_query_overview(
#'   data = adae,
#'   denominator = adsl,
#'   ae_types = ae_types,
#'   by = TRT01A
#' )
#' }
#'
#' @export
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

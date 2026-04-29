#' Create ARD for adverse event overview (AETYPE × PT(AEDECOD))
#'
#' Convenience wrapper around [jpn_query_aggregate()] that summarizes data
#' Aggregate by AETYPE and AEDECOD.
#'
#' @inheritParams jpn_query_aggregate
#'
#' @return A `{cards}` ARD object returned by `cards::ard_stack_hierarchical()`.
#'
#' @examples
#' \dontrun{
#' ard <- jpn_query_ptsummary(
#'   data = adae,
#'   denominator = adsl,
#'   ae_types = ae_types,
#'   by = TRT01A
#' )
#' }
#'
#' @export

# ARD Creation [AETYPE × PT(AEDECOD)]
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

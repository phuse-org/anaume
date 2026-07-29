#' Create ARD (analysis ready data) for adverse event summaries (aggregate wrapper)
#'
#' Wrapper around [jpn_query_base()] that first expands an ADAE-like dataset with
#' `AETYPE` using `bind_by_aetype()` and then creates a `{cards}` ARD via
#' `cards::ard_stack_hierarchical()`.
#'
#' Use this function when you have a raw ADAE dataset (without `AETYPE`) and an
#' `ae_types` specification, and want to obtain the same ARD output as
#' [jpn_query_base()] in a single call.
#'
#' @param data A data.frame (ADAE-like). Unlike [jpn_query_base()], `data` does not
#'   need to contain `AETYPE` in advance.
#' @param ae_types List of `ae_type` objects passed to `bind_by_aetype()` to create `AETYPE`.
#' @inheritParams jpn_query_base
#'
#' @details
#' Internally this function performs:
#' 1) `bind_by_aetype(data, ae_types)` to add `AETYPE`
#' 2) [jpn_query_base()] with `data` replaced by the bound data
#'
#' @return A `{cards}` ARD object returned by `cards::ard_stack_hierarchical()`.
#'
#' @examples
#' ae_types <- list(
#'   make_ae_type("any_ae", "Any AE"),
#'   make_ae_type("rel_ae", "Related AEs", AEREL == "Y")
#' )
#'
#' # AETYPE-level summary, split by treatment arm
#' jpn_query_aggregate(
#'   data        = adae,
#'   denominator = adsl,
#'   ae_types    = ae_types,
#'   by          = TRT01A
#' )
#'
#' # Add preferred term (AEDECOD) as an additional summary variable
#' jpn_query_aggregate(
#'   data        = adae,
#'   denominator = adsl,
#'   ae_types    = ae_types,
#'   by          = TRT01A,
#'   variables   = AEDECOD
#' )
#'
#' @export
#' @importFrom cards ard_stack_hierarchical
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

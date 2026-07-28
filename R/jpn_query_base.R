#' Create ARD (analysis ready data) for adverse event summaries
#'
#' Helper to create a `{cards}` ARD based on an ADAE-like dataset that has already
#' been expanded with `AETYPE` (e.g. via `bind_by_aetype()` upstream).
#'
#' The ARD is created by `cards::ard_stack_hierarchical()` with:
#' - subject identifier fixed to `USUBJID`
#' - `AETYPE` always included in `variables`
#' - optional additional summary variables (`variables`)
#' - optional stratification columns (`by`) such as treatment arm and subgroup factors
#'
#' @param data A data.frame that must contain at least `USUBJID` and `AETYPE`.
#'   Typically ADAE expanded to multiple rows per subject/event type.
#' @param denominator A data.frame used as the denominator in `{cards}`.
#'   Must contain the columns specified in `by` (if provided).
#' @param variables Optional tidyselect specification of additional variables to
#'   summarize hierarchically under `AETYPE`. If `NULL` (default), `variables`
#'   will be `AETYPE` only.
#' @param by Optional tidyselect specification of column(s) used for column splits
#'   (e.g. treatment arm, subgroup). If `NULL` (default), no `by` columns are used.
#'
#' @details
#' This function assumes `data` already includes `AETYPE`; it does not call
#' `bind_by_aetype()` internally.
#'
#' Internally, `variables` is resolved to column names from `data` and combined as:
#' `unique(c("AETYPE", variables))`.
#'
#' @return A `{cards}` ARD object returned by `cards::ard_stack_hierarchical()`.
#'
#' @examples
#' \dontrun{
#' # adae_aetype <- bind_by_aetype(adae, ae_types)
#' ard <- jpn_query_base(
#'   data = adae_aetype,
#'   denominator = adsl,
#'   by = TRT01A
#' )
#'
#' ard_pt <- jpn_query_base(
#'   data = adae_aetype,
#'   denominator = adsl,
#'   by = TRT01A,
#'   variables = AEDECOD
#' )
#' }
#'
#' @export
#' @importFrom rlang enquo quo_is_null
#' @importFrom dplyr select all_of group_vars
#' @importFrom cards ard_stack_hierarchical
#' @importFrom tidyselect eval_select
jpn_query_base <- function(
    data,
    denominator,
    variables = NULL,
    by = dplyr::group_vars(data)
) {
  stopifnot(is.data.frame(data), is.data.frame(denominator))

  by_vars  <- resolve_cols({{ by }}, data)
  vars_nm  <- resolve_cols({{ variables }}, data)

  summary_vars <- unique(c("AETYPE", vars_nm))
  required <- c("USUBJID", summary_vars, by_vars)

  missing_data <- setdiff(required, names(data))
  if (length(missing_data)) stop("`data` is missing column(s): ", toString(missing_data), call. = FALSE)

  missing_denom_by <- setdiff(by_vars, names(denominator))
  if (length(missing_denom_by)) stop("`denominator` is missing `by` column(s): ", toString(missing_denom_by), call. = FALSE)

  # build ARD
  cards::ard_stack_hierarchical(
    data = data,
    by        = if (length(by_vars) == 0L) NULL else dplyr::all_of(by_vars),
    variables = dplyr::all_of(summary_vars),
    id        = dplyr::all_of("USUBJID"),
    denominator = denominator
  )
}

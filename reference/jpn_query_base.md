# Create ARD (analysis ready data) for adverse event summaries

Helper to create a `{cards}` ARD based on an ADAE-like dataset that has
already been expanded with `AETYPE` (e.g. via
[`bind_by_aetype()`](https://phuse-org.github.io/anaume/reference/bind_by_aetype.md)
upstream).

## Usage

``` r
jpn_query_base(
  data,
  denominator,
  variables = NULL,
  by = dplyr::group_vars(data)
)
```

## Arguments

- data:

  A data.frame that must contain at least `USUBJID` and `AETYPE`.
  Typically ADAE expanded to multiple rows per subject/event type.

- denominator:

  A data.frame used as the denominator in `{cards}`. Must contain the
  columns specified in `by` (if provided).

- variables:

  Optional tidyselect specification of additional variables to summarize
  hierarchically under `AETYPE`. If `NULL` (default), `variables` will
  be `AETYPE` only.

- by:

  Optional tidyselect specification of column(s) used for column splits
  (e.g. treatment arm, subgroup). If `NULL` (default), no `by` columns
  are used.

## Value

A `{cards}` ARD object returned by
[`cards::ard_stack_hierarchical()`](https://pharmaverse.github.io/cards/latest-tag/reference/ard_stack_hierarchical.html).

## Details

The ARD is created by
[`cards::ard_stack_hierarchical()`](https://pharmaverse.github.io/cards/latest-tag/reference/ard_stack_hierarchical.html)
with:

- subject identifier fixed to `USUBJID`

- `AETYPE` always included in `variables`

- optional additional summary variables (`variables`)

- optional stratification columns (`by`) such as treatment arm and
  subgroup factors

This function assumes `data` already includes `AETYPE`; it does not call
[`bind_by_aetype()`](https://phuse-org.github.io/anaume/reference/bind_by_aetype.md)
internally.

Internally, `variables` is resolved to column names from `data` and
combined as: `unique(c("AETYPE", variables))`.

## Examples

``` r
if (FALSE) { # \dontrun{
# adae_aetype <- bind_by_aetype(adae, ae_types)
ard <- jpn_query_base(
  data = adae_aetype,
  denominator = adsl,
  by = TRT01A
)

ard_pt <- jpn_query_base(
  data = adae_aetype,
  denominator = adsl,
  by = TRT01A,
  variables = AEDECOD
)
} # }
```

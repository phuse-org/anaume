# Create ARD for adverse event overview (AETYPE level only)

Convenience wrapper around
[`jpn_query_aggregate()`](https://phuse-org.github.io/anaume/reference/jpn_query_aggregate.md)
that summarizes at the `AETYPE` level only (i.e. `variables = NULL`).

## Usage

``` r
jpn_query_overview(data, denominator, ae_types, by = NULL)
```

## Arguments

- data:

  A data.frame (ADAE-like). Unlike
  [`jpn_query_base()`](https://phuse-org.github.io/anaume/reference/jpn_query_base.md),
  `data` does not need to contain `AETYPE` in advance.

- denominator:

  A data.frame used as the denominator in `{cards}`. Must contain the
  columns specified in `by` (if provided).

- ae_types:

  List of `ae_type` objects passed to
  [`bind_by_aetype()`](https://phuse-org.github.io/anaume/reference/bind_by_aetype.md)
  to create `AETYPE`.

- by:

  Optional tidyselect specification of column(s) used for column splits
  (e.g. treatment arm, subgroup). If `NULL` (default), no `by` columns
  are used.

## Value

A `{cards}` ARD object returned by
[`cards::ard_stack_hierarchical()`](https://pharmaverse.github.io/cards/latest-tag/reference/ard_stack_hierarchical.html).

## Examples

``` r
ae_types <- list(
  make_ae_type("any_ae", "Any AE"),
  make_ae_type("rel_ae", "Related AEs", AEREL == "Y")
)

# AETYPE-level overview, split by treatment arm
jpn_query_overview(
  data        = adae,
  denominator = adsl,
  ae_types    = ae_types,
  by          = TRT01A
)
#> # An ARD data frame: 27 × 11
#>    group1 group1_level variable variable_level       context   stat_name    stat
#>    <chr>  <list>       <chr>    <list>               <chr>     <chr>      <list>
#>  1 NA     <NULL>       TRT01A   Placebo              tabulate  n          86    
#>  2 NA     <NULL>       TRT01A   Placebo              tabulate  N         254    
#>  3 NA     <NULL>       TRT01A   Placebo              tabulate  p           0.339
#>  4 NA     <NULL>       TRT01A   Xanomeline High Dose tabulate  n          72    
#>  5 NA     <NULL>       TRT01A   Xanomeline High Dose tabulate  N         254    
#>  6 NA     <NULL>       TRT01A   Xanomeline High Dose tabulate  p           0.283
#>  7 NA     <NULL>       TRT01A   Xanomeline Low Dose  tabulate  n          96    
#>  8 NA     <NULL>       TRT01A   Xanomeline Low Dose  tabulate  N         254    
#>  9 NA     <NULL>       TRT01A   Xanomeline Low Dose  tabulate  p           0.378
#> 10 TRT01A Placebo      AETYPE   Any AE               hierarch… n          69    
#> # ℹ 17 more rows
#> # ℹ 4 more variables: stat_label <chr>, fmt_fun <list>, warning <list>,
#> #   error <list>
```

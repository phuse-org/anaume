# Create ARD (analysis ready data) for adverse event summaries (aggregate wrapper)

Wrapper around
[`jpn_query_base()`](https://phuse-org.github.io/anaume/reference/jpn_query_base.md)
that first expands an ADAE-like dataset with `AETYPE` using
[`bind_by_aetype()`](https://phuse-org.github.io/anaume/reference/bind_by_aetype.md)
and then creates a `{cards}` ARD via
[`cards::ard_stack_hierarchical()`](https://pharmaverse.github.io/cards/latest-tag/reference/ard_stack_hierarchical.html).

## Usage

``` r
jpn_query_aggregate(data, denominator, ae_types, variables = NULL, by = NULL)
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

Use this function when you have a raw ADAE dataset (without `AETYPE`)
and an `ae_types` specification, and want to obtain the same ARD output
as
[`jpn_query_base()`](https://phuse-org.github.io/anaume/reference/jpn_query_base.md)
in a single call.

Internally this function performs:

1.  `bind_by_aetype(data, ae_types)` to add `AETYPE`

2.  [`jpn_query_base()`](https://phuse-org.github.io/anaume/reference/jpn_query_base.md)
    with `data` replaced by the bound data

## Examples

``` r
ae_types <- list(
  make_ae_type("any_ae", "Any AE"),
  make_ae_type("rel_ae", "Related AEs", AEREL == "Y")
)

# AETYPE-level summary, split by treatment arm
jpn_query_aggregate(
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

# Add preferred term (AEDECOD) as an additional summary variable
jpn_query_aggregate(
  data        = adae,
  denominator = adsl,
  ae_types    = ae_types,
  by          = TRT01A,
  variables   = AEDECOD
)
#> # An ARD data frame: 3,258 × 13
#>    group1 group1_level group2 group2_level variable variable_level     stat_name
#>    <chr>  <list>       <chr>  <list>       <chr>    <list>             <chr>    
#>  1 NA     <NULL>       NA     <NULL>       TRT01A   Placebo            n        
#>  2 NA     <NULL>       NA     <NULL>       TRT01A   Placebo            N        
#>  3 NA     <NULL>       NA     <NULL>       TRT01A   Placebo            p        
#>  4 NA     <NULL>       NA     <NULL>       TRT01A   Xanomeline High D… n        
#>  5 NA     <NULL>       NA     <NULL>       TRT01A   Xanomeline High D… N        
#>  6 NA     <NULL>       NA     <NULL>       TRT01A   Xanomeline High D… p        
#>  7 NA     <NULL>       NA     <NULL>       TRT01A   Xanomeline Low Do… n        
#>  8 NA     <NULL>       NA     <NULL>       TRT01A   Xanomeline Low Do… N        
#>  9 NA     <NULL>       NA     <NULL>       TRT01A   Xanomeline Low Do… p        
#> 10 TRT01A Placebo      NA     <NULL>       AETYPE   Any AE             n        
#> # ℹ 3,248 more rows
#> # ℹ 6 more variables: context <chr>, stat_label <chr>, stat <list>,
#> #   fmt_fun <list>, warning <list>, error <list>
```

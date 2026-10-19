# Create ARD for adverse event overview (by AETYPE and PT(AEDECOD))

Convenience wrapper around
[`jpn_query_aggregate()`](https://phuse-org.github.io/anaume/reference/jpn_query_aggregate.md)
that summarizes data Aggregate by AETYPE and AEDECOD.

## Usage

``` r
jpn_query_ptsummary(data, denominator, ae_types, by = NULL)
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

# AETYPE x PT (AEDECOD) summary, split by treatment arm
jpn_query_ptsummary(
  data        = adae,
  denominator = adsl,
  ae_types    = ae_types,
  by          = TRT01A
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

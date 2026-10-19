# Get properties of an `ae_type` object

`ae_id()` and `ae_label()` return the `id` and `label` properties of an
`ae_type` object.

`ae_condition()` returns the stored condition. If the condition is
`NULL`, it returns `quo(TRUE)` so it can be safely used inside
[`dplyr::filter()`](https://dplyr.tidyverse.org/reference/filter.html).

## Usage

``` r
ae_id(ae_type)

ae_label(ae_type)

ae_condition(ae_type)
```

## Arguments

- ae_type:

  An `ae_type` object.

## Examples

``` r
rel_ae <- make_ae_type("rel_ae", "Related AEs", AEREL == "Y")

ae_id(rel_ae)
#> [1] "rel_ae"
ae_label(rel_ae)
#> [1] "Related AEs"
ae_condition(rel_ae)
#> <quosure>
#> expr: ^AEREL == "Y"
#> env:  0x55fe339bc4c0

all_ae <- make_ae_type("all_ae", "All AEs")
ae_condition(all_ae)
#> <quosure>
#> expr: ^TRUE
#> env:  empty
```

# Combine multiple `ae_type` objects

Combine multiple `ae_type` objects

## Usage

``` r
merge_ae_types(ae_types, id, label, op = c("&", "|"))
```

## Arguments

- ae_types:

  List of `ae_type` objects.

- id:

  ID for the combined object.

- label:

  Label for the combined object.

- op:

  Logical operator used to combine conditions (`&` or `|`).

## Value

An `ae_type` object.

## Examples

``` r
rel_ae <- make_ae_type("rel_ae", "Related AEs", AEREL == "Y")
ser_ae <- make_ae_type("ser_ae", "Serious AEs", AESER == "Y")

merge_ae_types(
  list(rel_ae, ser_ae),
  id = "rel_ser_ae",
  label = "Serious Related AEs"
)
#> <ae_type>
#> id: rel_ser_ae
#> label: Serious Related AEs
#> condition: AEREL == "Y" & AESER == "Y"
```

# Create an `ae_type` object

Create an `ae_type` object

## Usage

``` r
make_ae_type(id, label, condition = NULL)
```

## Arguments

- id:

  ID value for the object.

- label:

  Label for the AE type.

- condition:

  Expression for subsetting the dataset.

## Value

An `ae_type` object.

## Examples

``` r
make_ae_type("all_ae", "All AEs")
#> <ae_type>
#> id: all_ae
#> label: All AEs
#> condition: TRUE
make_ae_type("rel_ae", "Related AEs", AEREL == "Y")
#> <ae_type>
#> id: rel_ae
#> label: Related AEs
#> condition: AEREL == "Y"
```

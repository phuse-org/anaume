# Helper function to apply a single ae_type to a dataset (filter + add id/label)

Helper function to apply a single ae_type to a dataset (filter + add
id/label)

## Usage

``` r
apply_ae_type(data, ae_type, label_col = "label")
```

## Arguments

- data:

  A data.frame to be filtered (e.g. ADAE).

- ae_type:

  An ae_type object created by make_ae_type().

- label_col:

  A character string specifying the name of the label column (default:
  "label").

## Value

A data.frame with added columns `id`, `label` (or custom label column).

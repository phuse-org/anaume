# Helper function to bind ADAE rows by ae_types: filter by condition, add AETYPE (= label), then row-bind

Given a data.frame and one or more `ae_type` objects, this function
filters the data by each ae_type's condition, adds an `AETYPE` label
column, and row-binds the results together.

## Usage

``` r
bind_by_aetype(data, ae_types, verbose = FALSE)
```

## Arguments

- data:

  A data.frame to be filtered (e.g. ADAE).

- ae_types:

  An `ae_type` object or a list of `ae_type` objects. A single `ae_type`
  object is automatically wrapped in a list.

- verbose:

  Logical. If `TRUE`, a log message is printed for each `ae_type`
  showing the label, id, and number of matched rows. Default is `FALSE`.

## Value

A data.frame with added columns `id` and `AETYPE`, row-bound across all
ae_types.

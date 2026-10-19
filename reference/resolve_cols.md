# Helper function to resolve column selection (internal helper)

Accepts a defused expression via `{{ }}` or `enquo()`, or a character
vector.

## Usage

``` r
resolve_cols(expr, data)
```

## Arguments

- expr:

  A defused expression (quosure). Pass with `{{ x }}` or `enquo(x)`.

- data:

  Data frame to resolve column names against.

## Value

Character vector of column names, or `character(0)`.

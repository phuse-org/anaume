# Example ADSL dataset

A processed Subject-Level Analysis Dataset (ADSL) used throughout the
examples and vignettes of anaume. It is derived from the CDISC pilot
dummy data shipped with the pharmaverseadam package and restricted to
the safety population (`SAFFL == "Y"`). It serves as the denominator
dataset when building adverse event summaries.

## Usage

``` r
adsl
```

## Format

A tibble with 254 rows and 55 variables. Key variables include:

- USUBJID:

  Unique subject identifier.

- TRT01A:

  Actual treatment arm.

- ARM:

  Planned treatment arm.

- ACTARM:

  Actual treatment arm description.

- SAFFL:

  Safety population flag (`"Y"`/`"N"`).

- AGE:

  Age in years.

- SEX:

  Sex (`"F"`/`"M"`).

Additional CDISC ADaM standard variables are also included.

## Source

Derived from the pharmaverseadam package using the preprocessing script
`data-raw/adamdummy.R`.

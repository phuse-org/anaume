# Example ADAE dataset

A processed Adverse Event Analysis Dataset (ADAE) used throughout the
examples and vignettes of anaume. It is derived from the CDISC pilot
dummy data shipped with the pharmaverseadam package, restricted to the
safety population (`SAFFL == "Y"`) and augmented with a number of
analysis flags used to define adverse event query categories.

## Usage

``` r
adae
```

## Format

A tibble with 1191 rows and 115 variables. Key variables include:

- USUBJID:

  Unique subject identifier.

- TRT01A:

  Actual treatment arm.

- AEDECOD:

  Dictionary-derived preferred term (PT).

- AEBODSYS:

  Body system or organ class.

- AEREL:

  Analysis flag for treatment relatedness (`"Y"`/`"N"`).

- AESER:

  Serious event flag (`"Y"`/`"N"`).

- AEGRD:

  Flag for events of Grade 3 or higher (`"Y"`/`"N"`).

- AEFAT:

  Fatal event flag (`"Y"`/`"N"`).

- AEDISCON:

  Flag for events leading to drug withdrawal (`"Y"`/`"N"`).

- AEITRR:

  Flag for events leading to drug interruption (`"Y"`/`"N"`).

- AEREDUCE:

  Flag for events leading to dose reduction (`"Y"`/`"N"`).

Additional CDISC ADaM standard variables are also included.

## Source

Derived from the pharmaverseadam package using the preprocessing script
`data-raw/adamdummy.R`.

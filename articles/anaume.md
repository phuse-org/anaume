# Get started

## Analysis for outputs required by PMDA in oncology

[anaume](https://github.com/phuse-org/anaume) is a package to generate
outputs required in oncology therapeutic area by PMDA.

``` r

library(anaume)
```

## Setup for dummy data

Dummy data are based on the `pharmaverseadam` package. Install it with
`install.packages("pharmaverseadam")` to run the examples below.

``` r

adae <- pharmaverseadam::adae
adsl <- pharmaverseadam::adsl
```

## Define types of AE to be analyzed

Use
[`make_ae_type()`](https://phuse-org.github.io/anaume/reference/make_ae_type.md)
to define each adverse event category to summarize. A category can be
unconditional (all AEs) or defined by a filtering condition.

``` r

ae_types <- list(
  make_ae_type("any_ae", "Any AE"),
  make_ae_type("rel_ae", "Related AEs", AEREL == "Y")
)
```

## Generate ARD

Pass the data, denominator, and AE types to
[`jpn_query_overview()`](https://phuse-org.github.io/anaume/reference/jpn_query_overview.md)
to create an analysis-ready data (ARD) object summarized at the AETYPE
level.

``` r

jpn_query_overview(
  data        = adae,
  denominator = adsl,
  ae_types    = ae_types,
  by          = TRT01A
)
#> # An ARD data frame: 21 × 11
#>    group1 group1_level variable variable_level       context  stat_name    stat
#>    <chr>  <list>       <chr>    <list>               <chr>    <chr>      <list>
#>  1 NA     <NULL>       TRT01A   Placebo              tabulate n          86    
#>  2 NA     <NULL>       TRT01A   Placebo              tabulate N         306    
#>  3 NA     <NULL>       TRT01A   Placebo              tabulate p           0.281
#>  4 NA     <NULL>       TRT01A   Screen Failure       tabulate n          52    
#>  5 NA     <NULL>       TRT01A   Screen Failure       tabulate N         306    
#>  6 NA     <NULL>       TRT01A   Screen Failure       tabulate p           0.170
#>  7 NA     <NULL>       TRT01A   Xanomeline High Dose tabulate n          72    
#>  8 NA     <NULL>       TRT01A   Xanomeline High Dose tabulate N         306    
#>  9 NA     <NULL>       TRT01A   Xanomeline High Dose tabulate p           0.235
#> 10 NA     <NULL>       TRT01A   Xanomeline Low Dose  tabulate n          96    
#> # ℹ 11 more rows
#> # ℹ 4 more variables: stat_label <chr>, fmt_fun <list>, warning <list>,
#> #   error <list>
```

#' Example ADAE dataset
#'
#' A processed Adverse Event Analysis Dataset (ADAE) used throughout the
#' examples and vignettes of \pkg{anaume}. It is derived from the CDISC pilot
#' dummy data shipped with the \pkg{pharmaverseadam} package, restricted to the
#' safety population (`SAFFL == "Y"`) and augmented with a number of analysis
#' flags used to define adverse event query categories.
#'
#' @format A tibble with 1191 rows and 115 variables. Key variables include:
#' \describe{
#'   \item{USUBJID}{Unique subject identifier.}
#'   \item{TRT01A}{Actual treatment arm.}
#'   \item{AEDECOD}{Dictionary-derived preferred term (PT).}
#'   \item{AEBODSYS}{Body system or organ class.}
#'   \item{AEREL}{Analysis flag for treatment relatedness (`"Y"`/`"N"`).}
#'   \item{AESER}{Serious event flag (`"Y"`/`"N"`).}
#'   \item{AEGRD}{Flag for events of Grade 3 or higher (`"Y"`/`"N"`).}
#'   \item{AEFAT}{Fatal event flag (`"Y"`/`"N"`).}
#'   \item{AEDISCON}{Flag for events leading to drug withdrawal (`"Y"`/`"N"`).}
#'   \item{AEITRR}{Flag for events leading to drug interruption (`"Y"`/`"N"`).}
#'   \item{AEREDUCE}{Flag for events leading to dose reduction (`"Y"`/`"N"`).}
#' }
#' Additional CDISC ADaM standard variables are also included.
#'
#' @source Derived from the \pkg{pharmaverseadam} package using the
#'   preprocessing script \code{data-raw/adamdummy.R}.
"adae"

#' Example ADSL dataset
#'
#' A processed Subject-Level Analysis Dataset (ADSL) used throughout the
#' examples and vignettes of \pkg{anaume}. It is derived from the CDISC pilot
#' dummy data shipped with the \pkg{pharmaverseadam} package and restricted to
#' the safety population (`SAFFL == "Y"`). It serves as the denominator dataset
#' when building adverse event summaries.
#'
#' @format A tibble with 254 rows and 55 variables. Key variables include:
#' \describe{
#'   \item{USUBJID}{Unique subject identifier.}
#'   \item{TRT01A}{Actual treatment arm.}
#'   \item{ARM}{Planned treatment arm.}
#'   \item{ACTARM}{Actual treatment arm description.}
#'   \item{SAFFL}{Safety population flag (`"Y"`/`"N"`).}
#'   \item{AGE}{Age in years.}
#'   \item{SEX}{Sex (`"F"`/`"M"`).}
#' }
#' Additional CDISC ADaM standard variables are also included.
#'
#' @source Derived from the \pkg{pharmaverseadam} package using the
#'   preprocessing script \code{data-raw/adamdummy.R}.
"adsl"

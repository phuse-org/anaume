# Package
library(haven)
library(dplyr)
library(purrr)
library(rlang)
library(tidyselect)
library(cards)

# Load XPT
adsl <- read_xpt(here("data", "adsl.xpt"))
adae <- read_xpt(here("data", "adae.xpt"))

# Helper function call
source(here("R", "func1.R"))
source(here("R", "bind_by_aetype.R"))
source(here("R", "jpn_query_base.R"))
source(here("R", "resolve_cols.R"))

# Definition of the AE Category
ae_types <- list(
  func1("any_ae",   "Any AE",                       expr(TRUE)),
  func1("aeg3",     "AE >= Grade 3",                expr(AEGRD == "Y")),
  func1("sae",      "Any SAE",                      expr(AESER == "Y")),
  func1("fatal",    "Fatal SAEs",                   expr(AESER == "Y" & AEFAT == "Y")),
  func1("disc",     "AE leads drug withdraw",       expr(AEDISCON == "Y")),
  func1("itrr",     "AE leads drug interrupt",      expr(AEITRR == "Y")),
  func1("redu",     "AE leads to dose reduction",   expr(AEREDUCE == "Y"))
)

# ARD Creation [AETYPE × PT(AEDECOD)]
jpn_query_ptsummary <- function(
    ADAE,
    ADSL,
    ae_types,
    by,
    variables = AEDECOD,
    verbose = FALSE
) {
  # --- Resolve by converting to a column vector (also used in the denominator) ---
  by_vars <- resolve_cols({{ by }}, ADSL)
  by_syms <- rlang::syms(by_vars)

  # 1) Add AETYPE
  adae_aetype <- bind_by_aetype(ADAE, ae_types, verbose = verbose)

  # 2) Combine the by column from ADSL and pass it to group_by
  adae_aetype <- adae_aetype %>%
    dplyr::inner_join(ADSL %>% dplyr::select(USUBJID, !!!by_syms), by = "USUBJID")

  # 3) Denominator (Subject Level × by)
  denom <- ADSL %>%
    dplyr::distinct(USUBJID, dplyr::across(dplyr::all_of(by_vars)))

  # 4) ARD（AETYPE × variables）
  jpn_query_base(
    data        = adae_aetype,
    denominator = denom,
    variables   = {{ variables }}
  )
}

library(pharmaverseadam)
library(dplyr)
library(haven)
library(labelled)
library(purrr)
library(rlang)

# Clear the environment
rm(list = ls())

# Read pharmacverse dummy data
data("adsl", package = "pharmaverseadam")
data("adae", package = "pharmaverseadam")

# Add total treatment group and filter on SAFFL
adsl <- adsl %>%
  filter(SAFFL == "Y") #%>%
#  bind_rows(mutate(., TRT01A = "Total"))

# Load and preprocess adverse event data
adae <- adae %>%
  filter(SAFFL == "Y") %>%
  mutate(
    ATOXGRN = sample(1:5, n(), replace = TRUE),
    ATOXGR = as.character(ATOXGRN),
    AEACN = sample(c("DOSE NOT CHANGED", "DOSE REDUCED",
                     "DRUG INTERRUPTED", "DRUG WITHDRAWN"),
                   n(), replace = TRUE),
    #TRT01A = factor(TRT01A, levels = c("Placebo",
    #                                   "Xanomeline High Dose",
    #                                   "Xanomeline Low Dose", "Total")),
    ANYAE = "Any AE",
    AEREL = if_else(AEREL %in% c("POSSIBLE", "PROBABLE"), "Y", "N"),
    AEFAT = if_else(AEOUT == "FATAL", "Y", "N"),
    AEGRD = if_else(ATOXGRN >= 3, "Y", "N"),
    AEDISCON = if_else(AEACN == "DRUG WITHDRAWN", "Y", "N"),
    AEITRR = if_else(AEACN == "DRUG INTERRUPTED", "Y", "N"),
    AEREDUCE = if_else(AEACN == "DOSE REDUCED", "Y", "N")
  )# %>%
  #bind_rows(., mutate(., TRT01A = "Total"))

write_xpt(adsl, "~/haqard/data/adsl.xpt", version = 5)
write_xpt(adae, "~/haqard/data/adae.xpt", version = 5)



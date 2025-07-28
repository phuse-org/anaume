library(cards)
library(tfrmt)
library(dplyr)
library(haven)
library(here)

# Clear the environment
rm(list = ls())

# Load data
adsl <- read_xpt(here("data", "adsl.xpt"))
adae <- read_xpt(here("data", "adae.xpt"))

# Mapping
map_variables <- function(data) {
  data |>
    rename(
      AEGRD = AEGRD,
      AESER = AESER,
      AEFAT = AEFAT,
      AEDISCON = AEDISCON,
      AEITRR = AEITRR,
      AEREDUCE = AEREDUCE
    )
}
adae <- map_variables(adae)

# Create label variables
adae <- adae |>
  mutate(
    rel_grp = case_when(
      AEREL %in% c("POSSIBLE", "PROBABLE", "Y") ~ "Related",
      TRUE ~ "Unrelated"
    )
  )

# Get bigN by TRT01A
big_n_data <- adsl |>
  count(TRT01A) |>
  rename(bigN = n)

# Define function for ARD
create_ard <- function(data, variable) {
  data |>
    distinct(USUBJID, TRT01A, rel_grp, .keep_all = TRUE) |>
    ard_categorical(
      by = c("TRT01A", "rel_grp"),
      variables = variable,
      statistic = ~c("n", "p"),
      denominator = adsl
    )
}

# Create ARDs
ard_ae     <- create_ard(adae, "ANYAE")
ard_aeg3   <- create_ard(filter(adae, AEGRD == "Y"), "AEGRD")
ard_sae    <- create_ard(filter(adae, AESER == "Y"), "AESER")
ard_fatal  <- create_ard(filter(adae, AESER == "Y"), "AEFAT")
ard_disc   <- create_ard(filter(adae, AEDISCON == "Y"), "AEDISCON")
ard_itrr   <- create_ard(filter(adae, AEITRR == "Y"), "AEITRR")
ard_redu   <- create_ard(filter(adae, AEREDUCE == "Y"), "AEREDUCE")

# Bind and label
all_ard_temp <- bind_ard(ard_ae, ard_aeg3, ard_fatal, ard_sae, ard_disc, ard_itrr, ard_redu) |>
  rename_ard_columns(unlist = "stat") |>
  mutate(
    label = case_when(
      !is.na(ANYAE) ~ "Any AE",
      AEGRD == "Y" ~ "AE >= Grade 3",
      AEFAT == "Y" ~ "Fatal SAEs",
      AESER == "Y" ~ "Any SAE",
      AEDISCON == "Y" ~ "AE leads drug withdraw",
      AEITRR == "Y" ~ "AE leads drug interrupt",
      AEREDUCE == "Y" ~ "AE leads to dose reduction"
    ),
    group = case_when(
      label == "Any AE" ~ "Any AE",
      label %in% c("Any SAE", "Fatal SAEs") ~ "Any SAE",
      label == "AE >= Grade 3" ~ "Grade 3",
      label %in% c("AE leads drug withdraw", "AE leads drug interrupt", "AE leads to dose reduction") ~ "Dose related",
      TRUE ~ NA_character_
    ),
    stat = ifelse(stat_name == "p", stat * 100, stat),
    ord1 = if_else(group == "Any AE", 0, 1),
    ord2 = if_else(label %in% c("Any AE", "Any SAE"), 0, 1)
  ) |>
  filter(!is.na(label)) |>
  select(TRT01A, rel_grp, group, label, stat_name, stat, ord1, ord2)

# Prepare bigN rows (TRT01A only, no rel_grp)
big_n_data2 <- big_n_data |>
  mutate(
    rel_grp = NA_character_,
    stat_name = "bigN",
    stat = bigN,
    group = NA_character_,
    label = NA_character_,
    ord1 = 99,
    ord2 = 99
  ) |>
  select(TRT01A, rel_grp, group, label, stat_name, stat, ord1, ord2)

# Combine all rows
all_ard <- bind_rows(all_ard_temp, big_n_data2)


####### tfrmt
big_n_obj <- big_n_structure(
  param_val = "bigN",
  n_frmt = frmt("(N = xx)")
)

AE_sample2 <- tfrmt_n_pct(n = "n", pct = "p") |>
  tfrmt(
  group = group,
  label = label,
  param = stat_name,
  value = stat,
  column = c(TRT01A, rel_grp),
  sorting_cols = c(ord1, ord2),
  col_plan = col_plan(everything(), -ord1, -ord2),
  big_n = big_n_obj
  ) |>
  print_to_gt(all_ard)

AE_sample2


library(cards)
library(tfrmt)
library(dplyr)
library(haven)
library(here)

# Clear the environment
rm(list = ls())

adsl <- read_xpt(here("data", "adsl.xpt"))
adae <- read_xpt(here("data", "adae.xpt"))

# Function to map variable names (dummy example)
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

# Apply mapping
adae <- map_variables(adae)

# Helper function to create ard_categorical objects
create_ard <- function(data, variable) {
  data |>
    distinct(USUBJID, TRT01A, .keep_all = TRUE) |>
    ard_categorical(
      by = TRT01A,
      variables = variable,
      statistic = ~c("n", "p"),
      denominator = adsl
    )
}

# Create various `ard_categorical` data frames
ard_ae <- create_ard(adae, "ANYAE")
ard_aeg3 <- create_ard(filter(adae, AEGRD == "Y"), "AEGRD")
ard_sae <- create_ard(filter(adae, AESER == "Y"), "AESER")
ard_fatal <- create_ard(filter(adae, AESER == "Y"), "AEFAT")
ard_disc <- create_ard(filter(adae, AEDISCON == "Y"), "AEDISCON")
ard_itrr <- create_ard(filter(adae, AEITRR == "Y"), "AEITRR")
ard_redu <- create_ard(filter(adae, AEREDUCE == "Y"), "AEREDUCE")

big_n_data <- adsl |>
  count(TRT01A) |>
  mutate(
    stat_name = "bigN",
    stat = n
  ) |>
  select(-n)

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
    stat_name = if_else(stat_name == "N" & is.na(label), "bigN", stat_name),
    group = case_when(
      label %in% c("Any AE") ~ "Any AE",
      label %in% c("Any SAE", "Fatal SAEs") ~ "Any SAE",
      label %in% c("AE >= Grade 3") ~ "Grade 3",
      label %in% c("AE leads drug withdraw", "AE leads drug interrupt", "AE leads to dose reduction") ~ "Dose related",
      TRUE ~ NA_character_
    ),
    stat = ifelse(stat_name == "p", stat * 100, stat),
    ord1 = if_else(group == "Any AE", 0, 1),
    ord2 = if_else(label %in% c("Any AE", "Any SAE"), 0, 1)
  ) |>
  filter(!(is.na(label))) |>
  select(TRT01A, group, label, stat_name, stat_label, stat, ord1, ord2)


all_ard <- bind_rows(all_ard_temp, big_n_data)

write_csv(all_ard, here("sample_ard.csv"))

# Create table with formatting
AE_sample <- tfrmt_n_pct(n = "n", pct = "p") |>
  tfrmt(
    group = group,
    label = label,
    param = stat_name,
    value = stat,
    column = TRT01A,
    sorting_cols = c(ord1, ord2),
    col_plan = col_plan(-ord1, -ord2, -stat_label),
    row_grp_plan = row_grp_plan(row_grp_structure(
      group_val = ".default", element_block(post_space = " ")
    )),
    big_n = big_n_structure(param_val = "bigN", n_frmt = frmt(" (N=xx)")
    )) |>
  print_to_gt(all_ard)

AE_sample

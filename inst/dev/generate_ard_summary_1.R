

generate_ard_summary <- function(data,
                                 adsl,
                                 trt_var = "TRT01A",
                                 cross_tab = TRUE,
                                 strat_var = "rel_grp"
                                 ){

  # Derive bigN
  big_n_data <- adsl %>%
    count(!!sym(trt_var)) %>%
    rename(bigN = n)

  create_ard <- function(df, variable, strat = strat_var) {
    by_vars <- if (cross_tab) c(trt_var, strat) else trt_var
    df %>%
      distinct(USUBJID, !!sym(trt_var), .data[[strat]], .keep_all = TRUE) %>%
      ard_categorical(
        by = by_vars,
        variables = variable,
        statistic = ~c("n", "p"),
        denominator = big_n_data
      )
  }

  ard_ae     <- create_ard(data, "ANYAE")
  ard_aeg3   <- create_ard(filter(data, AEGRD == "Y"), "AEGRD")
  ard_sae    <- create_ard(filter(data, AESER == "Y"), "AESER")
  ard_fatal  <- create_ard(filter(data, AESER == "Y"), "AEFAT")
  ard_disc   <- create_ard(filter(data, AEDISCON == "Y"), "AEDISCON")
  ard_itrr   <- create_ard(filter(data, AEITRR == "Y"), "AEITRR")
  ard_redu   <- create_ard(filter(data, AEREDUCE == "Y"), "AEREDUCE")

  all_ard_temp <- bind_ard(ard_ae, ard_aeg3, ard_fatal, ard_sae, ard_disc, ard_itrr, ard_redu) %>%
    rename_ard_columns(unlist = "stat") %>%
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
      stat = as.numeric(stat),
      stat = ifelse(stat_name == "p", stat * 100, stat),
      ord1 = if_else(group == "Any AE", 0, 1),
      ord2 = if_else(label %in% c("Any AE", "Any SAE"), 0, 1)
    ) %>%
    filter(!is.na(label)) %>%
    select(!!sym(trt_var), !!sym(strat_var), group, label, stat_name, stat, ord1, ord2)

  big_n_data2 <- big_n_data %>%
    mutate(
      !!sym(strat_var) := NA_character_,
      stat_name = "bigN",
      stat = bigN,
      group = NA_character_,
      label = NA_character_,
      ord1 = 99,
      ord2 = 99
    ) %>%
    select(!!sym(trt_var), !!sym(strat_var), group, label, stat_name, stat, ord1, ord2)

  bind_rows(all_ard_temp, big_n_data2)
}

# クロス集計（TRT01A × rel_grp）
all_ard_cross <- generate_ard_summary(adae, adsl, cross_tab = TRUE, strat_var = "rel_grp")

# 単純集計（TRT01Aのみ）
#all_ard_simple <- generate_ard_summary(adae, adsl, cross_tab = FALSE)

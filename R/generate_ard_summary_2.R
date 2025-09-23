#' @import dplyr
#' @import cards
#' @import rlang
#' @import purrr

generate_ard_summary_2 <- function(data, adsl, strat_var = NULL) {

  # ----------------------------------------------------------------------------
  # AEカテゴリの定義
  # ----------------------------------------------------------------------------
  ae_types <- list(
    func1("any_ae",   "Any AE",                       expr(TRUE)),
    func1("aeg3",     "AE >= Grade 3",                expr(AEGRD == "Y")),
    func1("sae",      "Any SAE",                      expr(AESER == "Y")),
    func1("fatal",    "Fatal SAEs",                   expr(AESER == "Y" & AEFAT == "Y")),
    func1("disc",     "AE leads drug withdraw",       expr(AEDISCON == "Y")),
    func1("itrr",     "AE leads drug interrupt",      expr(AEITRR == "Y")),
    func1("redu",     "AE leads to dose reduction",   expr(AEREDUCE == "Y"))
  )

  # ----------------------------------------------------------------------------
  # ARD生成ロジック
  # ----------------------------------------------------------------------------
  big_n_data <- adsl %>%
    count(TRT01A) %>%
    rename(bigN = n)

  # ARD作成用ヘルパー関数
  create_ard <- function(df, ae_type_obj, strat = strat_var) {
    # 【修正点】strat_varがNULLでない場合のみ、by_varsに含める
    by_vars <- if (!is.null(strat)) c("TRT01A", strat) else "TRT01A"

    filtered_data <- df %>%
      filter(!!ae_condition(ae_type_obj))

    if (nrow(filtered_data) == 0) {
      return(tibble())
    }

    tab_variable_name <- ae_id(ae_type_obj)
    filtered_data[[tab_variable_name]] <- "Y"

    # 患者をユニークにする処理もstrat_varの有無で動的に
    distinct_cols <- c("USUBJID", "TRT01A")
    if (!is.null(strat)) {
      distinct_cols <- c(distinct_cols, strat)
    }
    distinct_data <- filtered_data %>%
      distinct(across(all_of(distinct_cols)), .keep_all = TRUE)

    ard <- distinct_data %>%
      ard_categorical(
        by = all_of(by_vars),
        variables = all_of(tab_variable_name),
        statistic = ~c("n", "p"),
        denominator = adsl
      ) %>%
      mutate(label = ae_label(ae_type_obj))

    ard %>%
      filter(variable_level == "Y") %>%
      rename(id = variable) %>%
      select(-variable_level)
  }

  raw_ard <- purrr::map_dfr(ae_types, ~create_ard(data, .x))

  # 整形処理
  all_ard_temp <- raw_ard %>%
    rename_ard_columns(unlist = "stat") %>%
    mutate(
      group = case_when(
        id == "any_ae" ~ "Any AE",
        id %in% c("sae", "fatal") ~ "Any SAE",
        id == "aeg3" ~ "Grade 3",
        id %in% c("disc", "itrr", "redu") ~ "Dose related",
        TRUE ~ NA_character_
      ),
      stat = as.numeric(stat),
      stat = ifelse(stat_name == "p", stat * 100, stat),
      stat_label = case_when(
        stat_name == "n" ~ "n",
        stat_name == "p" ~ "%",
        TRUE ~ stat_name
      ),
      ord1 = if_else(group == "Any AE", 0, 1),
      ord2 = if_else(id %in% c("any_ae", "sae"), 0, 1)
    )

  # 母数行の準備
  big_n_data2 <- big_n_data %>%
    mutate(
      stat_name = "bigN",
      stat_label = "N",
      stat = bigN,
      group = NA_character_,
      label = NA_character_,
      ord1 = 99,
      ord2 = 99
    )

  # 【修正点】最終的な列の選択をより堅牢な方法に変更
  if (!is.null(strat_var)) {
    # 層別化ありの場合
    all_ard_temp <- all_ard_temp %>%
      select(TRT01A, all_of(strat_var), group, label, stat_name, stat_label, stat, ord1, ord2)

    big_n_data2 <- big_n_data2 %>%
      mutate(!!sym(strat_var) := NA_character_) %>%
      select(TRT01A, all_of(strat_var), group, label, stat_name, stat_label, stat, ord1, ord2)
  } else {
    # 層別化なしの場合
    all_ard_temp <- all_ard_temp %>%
      select(TRT01A, group, label, stat_name, stat_label, stat, ord1, ord2)

    big_n_data2 <- big_n_data2 %>%
      select(TRT01A, group, label, stat_name, stat_label, stat, ord1, ord2)
  }

  final_ard <- bind_rows(all_ard_temp, big_n_data2)

  filtered_data <- purrr::map_dfr(ae_types, function(ae_type) {
    data %>%
      filter(!!ae_condition(ae_type)) %>%
      mutate(ae_type_id = ae_id(ae_type), .before = 1)
  })

  list(
    final_ard = final_ard,
    raw_ard = raw_ard,
    big_n = big_n_data,
    filtered_data = filtered_data
  )
}

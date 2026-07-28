library(cards)
library(tfrmt)
library(dplyr)
library(haven)
library(here)
library(readr)
library(gt)
library(tidyr)

# Clear the environment
rm(list = ls())

# ----------------------------------------------------------------------------
# スクリプトの読み込み
# ----------------------------------------------------------------------------
source(here("R", "func1.R"))
source(here("R", "generate_ard_summary_2.R"))


# ----------------------------------------------------------------------------
# データの読み込みと前処理
# ----------------------------------------------------------------------------
adsl <- read_xpt(here("data", "adsl.xpt"))
adae <- read_xpt(here("data", "adae.xpt"))

# Create label variables
adae <- adae |>
  mutate(
    rel_grp = case_when(
      AEREL %in% c("POSSIBLE", "PROBABLE", "Y") ~ "Related",
      TRUE ~ "Unrelated"
    ),
    subjpn = case_when(
      COUNTRY == "JPN" ~ "Japanese",
      TRUE ~ "Non-Japanese"
    )
  )

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
# ARDの作成
# ----------------------------------------------------------------------------
stratification_var <- "SEX"

# 設定に基づいてARD関連のリストを取得
ard_results <- generate_ard_summary_2(
  data = adae,
  adsl = adsl,
  strat_var = NULL #stratification_var
)

# リストから最終的なデータフレームを抽出
all_ard <- ard_results$final_ard


print(colnames(all_ard))
print(head(all_ard))


# ----------------------------------------------------------------------------
# Tableの作成
# ----------------------------------------------------------------------------
create_table <- function(all_ard, strat_var = NULL) {

  # 1. Big N を取得（投与群ごと）
  bigN_data <- all_ard %>%
    filter(stat_name == "bigN") %>%
    select(TRT01A, stat) %>%
    distinct() %>%
    rename(bigN = stat)

  # 2. n / % を結合
  all_ard_display <- all_ard %>%
    filter(stat_name %in% c("n","p")) %>%
    mutate(stat_label2 = case_when(
      stat_name == "n" ~ as.character(stat),
      stat_name == "p" ~ paste0(round(stat,1), "%")
    ))

  # 3. Pivot wider
  if(!is.null(strat_var) && strat_var %in% colnames(all_ard_display)) {
    all_ard_display <- all_ard_display %>%
      select(TRT01A, !!sym(strat_var), label, stat_name, stat_label2) %>%
      pivot_wider(
        id_cols = label,
        names_from = c(TRT01A, !!sym(strat_var), stat_name),
        values_from = stat_label2
      )
  } else {
    all_ard_display <- all_ard_display %>%
      select(TRT01A, label, stat_name, stat_label2) %>%
      pivot_wider(
        id_cols = label,
        names_from = c(TRT01A, stat_name),
        values_from = stat_label2
      )
  }

  # 4. n と p を結合して "n (p%)"
  cols_n <- grep("_n$", colnames(all_ard_display), value = TRUE)
  for(col_n in cols_n) {
    col_p <- sub("_n$", "_p", col_n)
    if(col_p %in% colnames(all_ard_display)) {
      all_ard_display[[col_n]] <- paste0(all_ard_display[[col_n]], " (", all_ard_display[[col_p]], ")")
      all_ard_display[[col_p]] <- NULL
    }
  }

  # 5. 列順を設定
  trt_order <- unique(all_ard$TRT01A)
  if(!is.null(strat_var) && strat_var %in% colnames(all_ard)) {
    rel_order <- unique(all_ard[[strat_var]])
    col_order <- unlist(lapply(trt_order, function(trt) paste0(trt, "_", rel_order, "_n")))
  } else {
    col_order <- paste0(trt_order, "_n")
  }
  col_order <- col_order[col_order %in% colnames(all_ard_display)]
  all_ard_display <- all_ard_display %>% select(label, all_of(col_order))

  # 6. gt 表作成
  table_gt <- all_ard_display %>%
    gt(rowname_col = "label") %>%
    fmt_missing(missing_text = "-") %>%
    tab_header(
      title = "Adverse Event Summary",
      subtitle = "xxxx"
    )

  # 7. TRT ごとに spanner (Big N) を設定
  for(trt in trt_order) {
    trt_cols <- grep(paste0("^", trt, "_"), colnames(all_ard_display), value = TRUE)
    n_val <- bigN_data %>% filter(TRT01A == trt) %>% pull(bigN)
    if(length(n_val)==0) n_val <- "-"
    table_gt <- table_gt %>%
      tab_spanner(label = paste0(trt, " (N=", n_val, ")"),
                  columns = trt_cols)
  }

  # 8. strat_var がある場合は列ラベルをそのまま表示
  if(!is.null(strat_var) && strat_var %in% colnames(all_ard)) {
    for(trt in trt_order) {
      rel_values <- unique(all_ard[[strat_var]])
      trt_cols <- grep(paste0("^", trt, "_"), colnames(all_ard_display), value = TRUE)
      new_labels <- rel_values
      names(new_labels) <- trt_cols
      table_gt <- table_gt %>% cols_label(.list = new_labels)
    }
  }

  return(table_gt)
}

# 層別化あり
#report_table <- create_table(all_ard, strat_var = stratification_var)

# 層別化なし
report_table <- create_table(all_ard, strat_var = NULL)

report_table

library(pharmaverseadam)
library(dplyr)
library(rlang)
library(cards)
library(purrr)

adsl <- pharmaverseadam::adsl
adae <- pharmaverseadam::adae

# ae_type関数
ae_type <- function(id, label, condition) {
  list(id = id, label = label, condition = condition)
}

# 条件を定義
ae_types <- list(
  ae_type(id = "sae", label = "Serious AE", condition = expr(AESER == "Y")),
  ae_type(id = "aerel", label = "Related AE", condition = expr(AEREL != "NONE"))
)

# 各ae_typeに対して処理を繰り返す
results <- map(ae_types, function(ae) {
  # SOC処理
  # 条件に合致する USUBJID × AESOC のユニークな組み合わせに "Y" を立てる
  tab_variable_soc <- paste0(ae$id, "_SOC")
  filtered_data_soc <- adae %>%
    filter(!!ae$condition) %>%
    distinct(USUBJID, AEBODSYS) %>%
    mutate(!!tab_variable_soc := "Y")

  # ARD作成
  # 治療群ごとに分割
  soc_results <- adsl %>%
    select(USUBJID, TRT01A) %>%
    distinct() %>%
    split(.$TRT01A) %>%
    map(function(trt_data) {
      trt_filtered_data <- filtered_data_soc %>%
        semi_join(trt_data, by = "USUBJID")

      if (nrow(trt_filtered_data) == 0 || all(is.na(trt_filtered_data[[tab_variable_soc]]))) {
        return(NULL)
      }

      ard_categorical(
        data = trt_filtered_data,
        by = "AEBODSYS",
        variables = all_of(tab_variable_soc),
        statistic = ~c("n", "p"),
        denominator = trt_data
      ) %>%
        mutate(TRT01A = unique(trt_data$TRT01A),
               label = ae$label)
    }) %>%
    compact() %>%
    bind_rows()

  # PT処理
  # 条件に合致する USUBJID × AESOC × AEDECODのユニークな組み合わせに "Y" を立てる
  tab_variable_pt <- paste0(ae$id, "_PT")
  filtered_data_pt <- adae %>%
    filter(!!ae$condition) %>%
    distinct(USUBJID, AEBODSYS, AEDECOD) %>%
    mutate(!!tab_variable_pt := "Y")

  # ARD作成
  # 治療群ごとに分割
  pt_results <- adsl %>%
    select(USUBJID, TRT01A) %>%
    distinct() %>%
    split(.$TRT01A) %>%
    map(function(trt_data) {
      trt_filtered_data <- filtered_data_pt %>%
        semi_join(trt_data, by = "USUBJID")

      if (nrow(trt_filtered_data) == 0 || all(is.na(trt_filtered_data[[tab_variable_pt]]))) {
        return(NULL)
      }

      ard_categorical(
        data = trt_filtered_data,
        by = c("AEBODSYS", "AEDECOD"),
        variables = all_of(tab_variable_pt),
        statistic = ~c("n", "p"),
        denominator = trt_data
      ) %>%
        mutate(TRT01A = unique(trt_data$TRT01A),
               label = ae$label)
    }) %>%
    compact() %>%
    bind_rows()

  # SOCとPTの結果を結合
  bind_rows(soc_results, pt_results)
})

# 全条件の結果を結合
combined_results <- bind_rows(results)

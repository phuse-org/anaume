library(cards)
library(haven)
library(dplyr)
library(rlang)
library(purrr)

# Load data
adsl <- read_xpt(here("data", "adsl.xpt"))
adae <- read_xpt(here("data", "adae.xpt"))

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
# ARD を作成
# ----------------------------------------------------------------------------
create_ard_pt <- function(adsl, adae) {
  force(adsl); force(adae)  # 引数をクロージャに固定

  function(ae_types, strat_var = NULL,
           statistic = everything() ~ c("n", "N", "p")) {

    # --- strat_var の既定値処理 ---
    if (missing(strat_var) || is.null(strat_var) || length(strat_var) == 0) {
      if (!"TRT01A" %in% names(adsl)) {
        stop("`strat_var` が未指定ですが、ADSL に `TRT01A` がありません。群変数を明示的に指定してください。")
      }
      strat_var <- "TRT01A"
    }

    # --- 入力チェック ---
    missing_group <- setdiff(strat_var, names(adsl))
    if (length(missing_group) > 0) {
      stop("ADSL に存在しない群変数: ", paste(missing_group, collapse = ", "))
    }

    # --- 階層（variables） ---
    hier_vars <- if ("AEBODSYS" %in% names(adae)) {
      c("AEBODSYS", "AEDECOD")
    } else if ("AESOC" %in% names(adae)) {
      c("AESOC", "AEDECOD")
    } else {
      c("AEDECOD")
    }

    # ADSL の群情報（USUBJID + group_vars
    subject_groups <- adsl %>%
      dplyr::select(USUBJID, dplyr::all_of(strat_var)) %>%
      dplyr::distinct()

    # --- ae_typesごとに ARD を作成 ---
    ard_list <- purrr::map(ae_types, function(ae) {
      adae_f <- adae %>%
        dplyr::filter(!!ae_condition(ae)) %>%
        dplyr::select(USUBJID, dplyr::any_of(hier_vars)) %>%
        dplyr::distinct() %>%
        dplyr::inner_join(subject_groups, by = "USUBJID") %>%
        dplyr::distinct()

      if (nrow(adae_f) == 0) {
        message(sprintf("'%s' は該当イベント0件のためスキップします。", ae_id(ae)))
        return(NULL)
      }

    # cards の階層率計算（n/N/p）
      cards::ard_stack_hierarchical(
        data        = adae_f,
        variables   = dplyr::all_of(hier_vars),
        by          = dplyr::all_of(strat_var),
        id          = USUBJID,
        denominator = adsl,
        statistic   = statistic
      ) %>%
        dplyr::mutate(ae_id = ae_id(ae), label = ae_label(ae))
    })

    # --- 結合 ---
    ard_list <- purrr::compact(ard_list)
    if (length(ard_list) == 0) {
      return(cards::ard_total_n(adsl, by = dplyr::all_of(strat_var)))
    }
    purrr::reduce(ard_list, ~cards::bind_ard(.x, .y, .distinct = TRUE))
  }
}

   # --- 使用データセット固定 ---
  jpn_query_summary_pt <- create_ard_pt(adsl, adae)

# ----------------------------------------------------------------------------
# 使用例
# ----------------------------------------------------------------------------
# ard_pt_all <- jpn_query_summary_pt(ae_types, group_vars = )　# デフォルトの群変数はTRT01A
# ard_pt_all <- jpn_query_summary_pt(ae_types, group_vars = c("SEX","TRT01A"))

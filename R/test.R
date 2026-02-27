# パッケージ
library(haven)
library(dplyr)
library(purrr)
library(rlang)
library(tidyselect)
library(cards)

# main の worktree から XPT を読み込み
ADAE <- haven::read_xpt("C:/Users/c7671/R/proj-main/data/adae.xpt")
ADSL <- haven::read_xpt("C:/Users/c7671/R/proj-main/data/adsl.xpt")

# Helper function call
source("C:/Users/c7671/R/proj-main/R/bind_by_aetype.R")
source("C:/Users/c7671/R/proj-main/R/jpn_query_base.R")
source("C:/Users/c7671/R/proj-main/R/resolve_cols.R")
source("C:/Users/c7671/R/proj-main/R/func1.R")

# AEカテゴリの定義
ae_types <- list(
  func1("any_ae",   "Any AE",                       expr(TRUE)),
  func1("aeg3",     "AE >= Grade 3",                expr(AEGRD == "Y")),
  func1("sae",      "Any SAE",                      expr(AESER == "Y")),
  func1("fatal",    "Fatal SAEs",                   expr(AESER == "Y" & AEFAT == "Y")),
  func1("disc",     "AE leads drug withdraw",       expr(AEDISCON == "Y")),
  func1("itrr",     "AE leads drug interrupt",      expr(AEITRR == "Y")),
  func1("redu",     "AE leads to dose reduction",   expr(AEREDUCE == "Y"))
)

# AETYPE × PT（AEDECOD）
ard_pt <- jpn_query_ptsummary(
  ADAE, ADSL, ae_types,
  by = TRT01A,
  variables = AEDECOD
)

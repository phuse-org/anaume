devtools::load_all()
library(rlang)
library(haven)
library(dplyr)
library(cards)
library(tidyr)
library(tfrmt)
library(tibble)
library(gtsummary)

# source("R/func1.R")
# source("R/bind_by_aetype.R")
# source("R/resolve_cols.R")
# source("R/jpn_query_base.R")
# source("R/jpn_query_aggregate.R")
# source("R/jpn_query_overview.R")
#source("R/generate_ard_summary_2.R")

# ----------------------------------------------------------------------------
# データの読み込みと前処理
# ----------------------------------------------------------------------------
adsl <- read_xpt("data-raw/adsl.xpt")
adae <- read_xpt("data-raw/adae.xpt")

# Randomly downsample ADAE to 1/20 of records (reproducible)
set.seed(20260130)
adae <- adae %>%
  dplyr::slice_sample(prop = 1 / 20)

ae_types <- list(
  make_ae_type("any_ae",   "Any AE"),
  make_ae_type("aeg3",     "AE >= Grade 3",                AEGRD == "Y"),
  make_ae_type("sae",      "Any SAE",                      AESER == "Y"),
  make_ae_type("fatal",    "Fatal SAEs",                   AESER == "Y" & AEFAT == "Y"),
  make_ae_type("disc",     "AE leads drug withdraw",       AEDISCON == "Y"),
  make_ae_type("itrr",     "AE leads drug interrupt",      AEITRR == "Y"),
  make_ae_type("redu",     "AE leads to dose reduction",   AEREDUCE == "Y")
)

# AETYPE付与は上流で実施（jpn_query_base内では行わない）

# ----------------------------------------------------------------------------
# AETYPEごと（SOC/PTではない）に「AEを発現した被験者」のARDを作成
# - variables/by は tidyselect 非対応の関数実装でも落ちないよう "文字列" で渡す
# ----------------------------------------------------------------------------

# ard1 <- jpn_query_base(adae,adsl,variables = NULL,by = TRT01A)
ard2 <- jpn_query_aggregate(adae,adsl,ae_types = ae_types,variables = NULL,by = TRT01A)
ard3 <- cards::ard_stack_hierarchical(
  data = adae
  ,denominator = adsl
  ,by = c(AGEGR1,TRT01A)
  ,id = USUBJID
  ,variables = AEDECOD
  ,statistic = ~ c("n","p")
)
ard3.ov <- cards::ard_stack_hierarchical(
  data = adae
  ,denominator = adsl
  ,by = c(AGEGR1,TRT01A)
  ,variables = AEDECOD
  ,id = USUBJID
  ,statistic = ~ c("n","p")
  ,overall =TRUE
)

cnt <- adsl %>% count(AGEGR1,TRT01A)

ov.sub <- jpn_query_overview(
  data = adae
  ,ae_types = ae_types
  ,denominator = adsl
  ,by = c(AGEGR1,TRT01A)
)

ov.sub.shuffled <- ov.sub %>%
  shuffle_card()
ov.sub.prep <- ov.sub.shuffled %>%
  prep_hierarchical_fill(
    vars = c("AETYPE"),
    fill_from_left = TRUE
  )

ov.sub %>%  tibble::view()

ov.sub.bign <- ov.sub.prep %>%
  prep_big_n(vars = c("AGEGR1","TRT01A"))

# jpn_query_bign <- function(data,vars) {
#   bign <- data %>%
#     dplyr::filter(stat_name == "N") %>%
#     distinct(AGEGR1,TRT01A)
#   res <- dplyr::bind_rows(
#     bign,
#     data
#   )
#
#   return(res)
# }
#
# jpn_query_bign(ov.sub.prep,c("AGEGR1","TRT01A"))
bign <- ov.sub.prep %>%
  dplyr::filter(stat_name == "N") %>%
  distinct(AGEGR1,TRT01A)

ov.sub.bign.mod <- ov.sub.bign %>%
  filter(stat_name == "N") %>%
  distinct(AGEGR1,TRT01A,.keep_all = TRUE) %>%
  dplyr::select(-c(context, stat_label, stat_variable)) %>%
  dplyr::mutate(AETYPE = NA) %>%
  bind_rows(ov.sub.bign %>% dplyr::filter(stat_name != "N"))

# ov.sub.fin <- ov.sub.bign %>%
#   dplyr::select(-c(context, stat_label, stat_variable))
ov.sub.fin <- ov.sub.bign.mod %>%
  dplyr::select(-c(context, stat_label, stat_variable)) %>%
  dplyr::filter(stat_name != "bigN")

bp <- body_plan(
  frmt_structure(
    group_val = ".default",
    label_val = ".default",
    frmt_combine(
      "{n} ({p}%)",
      n = frmt("xx"),
      p = frmt("xx", transform = ~ . * 100)
    )
  )
)
cp <- col_plan(
  span_structure(
    TRT01A = c("Xanomeline Low Dose", "Xanomeline High Dose", "Placebo"),
    AGEGR1 = c("18-64", ">64")
  )
)

tfrmt(
  # group = AETYPE,
  label = AETYPE,
  param = stat_name,
  value = stat,
  column = c(TRT01A, AGEGR1),
  body_plan = bp,
  col_plan = cp,
  big_n = big_n_structure(
    param_val = "N",
    n_frmt = frmt("\n(N=xx)")
  )
) |>
  print_to_gt(ov.sub.fin)

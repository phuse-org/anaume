


# Setting
library(dplyr)
library(tfrmt)
library(gt)


# big_n_structure
bn <- big_n_structure(
  param_val  = "bigN",
  n_frmt = frmt("\nN = xx")   # N の表示フォーマット（整数）
)

# body_plan
bp <- body_plan(
  frmt_structure(
    group_val = ".default",
    label_val = ".default",
    frmt = frmt_combine(
      "{n} ({p}%)",
      n = frmt("xx",   missing = "0"),
      p = frmt("xx.x", missing = "--")
    )
  )
)


# col_plan
trt_levels <- all_ard %>% distinct(TRT01A) %>% pull(TRT01A)
cp <- col_plan(trt_levels)

# col_style_plan
# csp <- col_style_plan(
#   col_style_structure(col = trt_levels, align = ".") # 小数点寄せ
# )

# tfrmt
tf <- tfrmt(
  column         = TRT01A,
  group          = group,
  label          = label,
  param          = stat_name,
  value          = stat,
  sorting_cols   = c(ord1, ord2),
  big_n          = bn,
  body_plan      = bp,
  col_plan       = cp,
  # col_style_plan = csp
)

# print_to_gt
gt_tbl <- print_to_gt(tf, all_ard) %>%
  cols_hide(columns = c(ord1, ord2,stat_label)) %>%
  tab_header(
    title = "PMDA inqueries",
    subtitle = "Adverse Event"
  )


# 中央寄せ (tfrmtのcol_style_planだとleft, right, string以外の指定が出来ない？)
gt_tbl <- gt_tbl %>%
  cols_align(
    align = "center",
    columns = -label
  ) %>%
  cols_align(
    align = "left",
    columns = label
  )

# Save
gtsave(gt_tbl, filename = here::here("output", "pmda_ae_summary.pdf"))


gt_tbl




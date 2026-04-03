

# Setting
library(dplyr)
library(tfrmt)
library(gt)

#置き換え
tbl_disp <- all_ard %>%
  transmute(
    TRT01A,
    SEX,
    group,
    label,
    stat_name,
    stat,
    stat_label,
    ord1, ord2
  )



########################
## ここからtfmrt
########################

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
      n = frmt("xx",   missing = "0"), #statがNullのレコードが必要
      p = frmt("xx.x", missing = "--") #statがNullのレコードが必要
    )
  )
)


# col_plan
# col_planを別で使っちゃうとなぜか順序情報が失われるので、tfrmtで直接呼び出し
# trt_levels = c("Placebo", "Xanomeline Low Dose", "Xanomeline High Dose")
# sex_levels = c("M", "F")
# cp <- col_plan(
#   span_structure(
#     TRT01A = trt_levels,
#     SEX    = sex_levels
#   )
# )


# col_style_plan
# 中央寄せをしたかったけど、right,left, "."(小数点に合わせる)しかできない？
# csp <- col_style_plan(
#   col_style_structure(col = trt_levels, align = ".") # 小数点寄せ
# )


# tfrmt
tf <- tfrmt(
  column         = c(TRT01A,SEX),
  group          = group,
  label          = label,
  param          = stat_name,
  value          = stat,
  sorting_cols   = c(ord1, ord2),
  big_n          = bn,
  body_plan      = bp,
  # col_plan       = cp,
  col_plan     = col_plan(
    span_structure(
      TRT01A = c("Xanomeline Low Dose", "Xanomeline High Dose", "Placebo"),
      SEX    = c("M", "F")
    )
  )
  # col_style_plan = csp
)

# print_to_gt
gt_tbl <- print_to_gt(tf, tbl_disp) %>%
  cols_hide(columns = c(ord1, ord2, stat_label)) %>%
  tab_header(
    title = "PMDA inqueries",
    subtitle = "Adverse Event"
  )



# gt_tbl <- gt_tbl %>%
#   cols_align(
#     align = "center",
#     columns = -label
#   ) %>%
#   cols_align(
#     align = "left",
#     columns = label
#   ) %>%
#   tab_options(
#     table.font.size = px(8)
#   ) %>%
#   opt_table_font(
#     font = list(google_font("Times New Roman"), default_fonts())
#   )


########################
## ここからgt
########################
gt_tbl <- gt_tbl %>%
  # 中央寄せ (tfrmtのcol_style_planだとleft, right, string以外の指定が出来ない？)
  cols_align(
    align = "center",
    columns = -label
  ) %>%
  cols_align(
    align = "left",
    columns = label
  ) %>%

  # フォントの設定
  tab_options(
    table.font.size = px(8),
    heading.title.font.size = px(8),
    heading.subtitle.font.size = px(8),
    column_labels.font.size = px(8),
    data_row.padding = px(2)
  ) %>%

  opt_table_font(font = "Times New Roman") %>%

  tab_style(
    style = list(
      cell_text(font = "Times New Roman", size = px(8))
    ),
    locations = list(
      cells_body(),
      cells_column_labels(),
      cells_stub(),
      cells_stubhead(),
      cells_title(groups = "title"),
      cells_title(groups = "subtitle"),
      cells_column_spanners(spanners = everything())
    )
  )



# gtsave
gtsave(gt_tbl, filename = here::here("output", "pmda_ae_summary.pdf"))


gt_tbl

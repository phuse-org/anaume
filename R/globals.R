# Declare column names used via non-standard evaluation (NSE) across the
# package. This avoids "no visible binding for global variable" NOTEs raised
# by R CMD check for bare data-variable names such as `AEDECOD`.
utils::globalVariables(c(
  "AEDECOD"
))

#' @export
#' @examples
#' func1("rel_ae", "Related AEs", expr(AEREL == "Y"))
func1 <- function(id, label, condition = NULL) {
  out <- list(
    id = id,
    label = label,
    condition = condition
  )

  class(out) <- "ae_type"

  out
}

#' @export
#' @examples
#' rel_aes <- func1("rel_ae", "Related AEs", expr(AEREL == "Y"))
#' ae_id(rel_aes)
ae_id <- function(ae_type) {
  ae_type[["id"]]
}

#' @export
#' @examples
#' rel_aes <- func1("rel_ae", "Related AEs", expr(AEREL == "Y"))
#' ae_label(rel_aes)
ae_label <- function(ae_type) {
  ae_type[["label"]]
}

#' @export
#' @examples
#' rel_aes <- func1("rel_ae", "Related AEs", expr(AEREL == "Y"))
#' ae_condition(rel_aes)
ae_condition <- function(ae_type) {
  ae_type[["condition"]]
}

#' @export
print.ae_type <-function(x, ...) {
  cat("ae_type\n")
  cat(paste0("  id: ", ae_id(x), "\n"))
  cat(paste0("  label: ", ae_label(x), "\n"))
  cat(paste0("  condition: ", rlang::expr_deparse(ae_condition(x)), "\n"))
  invisible(x)
}

#' @export
#' @examples
#' rel_aes <- func1("rel_ae", "Related AEs", expr(AEREL == "Y"))
#' ser_aes <- func1("ser_ae", "Serious AEs", expr(AESER == "Y"))
#' merge(rel_aes, ser_aes, .id = "rel_ser_ae", .label = "Serious Related AEs")
merge.ae_type <- function(..., .id, .label, .fn = c("&", "|")) {
  .fn <- match.arg(.fn)
  ae_types <- list(...)

  condition <- ae_types |>
    purrr::map(\(x) ae_condition(x)) |>
    purrr::reduce(\(x, y) rlang::call2(.fn, x, y))

  func1(.id, .label, condition)
}

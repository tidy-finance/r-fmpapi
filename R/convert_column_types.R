#' Convert Column Types in a Data Frame
#'
#' @param df A data frame containing columns to be processed.
#'
#' @return A data frame with updated column types.
#'
#' @keywords internal
#'
convert_column_types <- function(df) {
  df |>
    mutate(across(contains("calendar_year"), as.integer),
           across(contains("date"), as.Date))
}

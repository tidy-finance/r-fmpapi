#' Convert Column Names to snake_case
#'
#' @param df A data frame whose column names are to be converted.
#'
#' @return The data frame with its column names converted to snake_case.
#'
#' @keywords internal
#'
convert_column_names <- function(df) {
  new_names <- gsub("([a-z])([A-Z])", "\\1_\\2", names(df))
  new_names <- tolower(new_names)
  colnames(df) <- new_names
  df
}

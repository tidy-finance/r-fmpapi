convert_column_types <- function(df) {
  df |>
    mutate(calendar_year = as.integer(calendar_year),
           across(contains("date"), as.Date))
}

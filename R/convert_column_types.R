convert_column_types <- function(df) {
  df |>
    mutate(across(contains("calendar_year"), as.integer),
           across(contains("date"), as.Date))
}

#' Get Historical Market Capitalization
#'
#' Retrieves historical market capitalization data for a specified symbol
#' within a defined date range.
#'
#' @param symbol Character. The stock ticker symbol of the company for which to retrieve market capitalization data.
#' @param start_date Date. The start date for the data retrieval in "YYYY-MM-DD" format.
#' @param end_date Date. The end date for the data retrieval in "YYYY-MM-DD" format.
#'
#' @return A tibble with historical market capitalization data, arranged by date.
#' @details The function queries an API to obtain market capitalization data for the specified `symbol` between `start_date` and `end_date`.
#' The data is returned as a tibble with appropriately converted column names and types.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' get_market_cap_historical("UNH", "2023-12-01", "2023-12-31")
#' }
#'
get_market_cap_historical <- function(symbol, start_date, end_date) {

  market_cap_historical_raw <- perform_request(
    resource = paste0("historical-market-capitalization/", symbol),
    api_version = "v3",
    from = start_date,
    to = end_date
  )

  market_cap_historical <- market_cap_historical_raw |>
    bind_rows() |>
    convert_column_names() |>
    convert_column_types() |>
    arrange(date)

  market_cap_historical
}

#' Get income statements from the Financial Modeling Prep API
#'
#' This function retrieves the income statements for a specified stock symbol from the Financial Modeling Prep (FMP) API.
#'
#' @param symbol A character string representing a single stock symbol.
#' @param period A character string specifying the period for the statements. Can be either "annual" (default) or "quarter".
#' @param limit An integer specifying the maximum number of records to retrieve. Defaults to 100. Must be a positive integer.
#'
#' @details The function sends a request to the FMP API to fetch income statements for the provided stock symbol.
#' The period can be set to either "annual" or "quarter". The function returns an error if the period is invalid or if the
#' limit is not a positive integer. The response is processed into a tidy data frame with snake_case column names.
#'
#' @return A data frame containing the income statements.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' get_income_statements("AAPL", period = "quarter", limit = 5)
#' }
#'
get_income_statements <- function(
    symbol,
    period = "annual",
    limit = 100
) {

  if (length(symbol) != 1) {
    cli::cli_abort(
      "Please provide a single {.arg symbol}."
    )
  }

  if (!period %in% c("annual", "quarter")) {
    cli::cli_abort(
      "{.arg period} must be either 'annual' or 'quarter'."
    )
  }

  if (!is.numeric(limit) || limit %% 1L != 0 || limit < 1L) {
    cli::cli_abort("{.arg limit} must be an integer larger than 0.")
  }

  resource <- paste0("income-statement/", symbol)
  income_statements_raw <- perform_request(resource, period = period, limit = limit)

  income_statements <- income_statements_raw |>
    bind_rows() |>
    convert_column_names()

  income_statements
}


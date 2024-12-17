#' Get Income Statements from the Financial Modeling Prep API
#'
#' This function retrieves the income statements for a specified stock symbol
#' from the Financial Modeling Prep (FMP) API.
#'
#' @param symbol A character string representing a single stock symbol.
#' @param period A character string specifying the period for the statements.
#'  Can be either "annual" (default) or "quarter".
#' @param limit An integer specifying the maximum number of records to retrieve.
#'  Defaults to 5. Must be a positive integer.
#'
#' @return A data frame containing the income statements.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' get_income_statements("AAPL", period = "annual", limit = 5)
#' }
#'
get_income_statements <- function(
  symbol, period = "annual", limit = 100
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
  income_statements_raw <- perform_request(
    resource, period = period, limit = limit
  )

  income_statements <- income_statements_raw |>
    bind_rows() |>
    convert_column_names() |>
    convert_column_types()

  income_statements
}

#' Get company profile from the Financial Modeling Prep API
#'
#' This function retrieves the company profile for a specified stock symbol from the Financial Modeling Prep (FMP) API.
#'
#' @param symbol A character string representing a single stock symbol.
#'
#' @details The function sends a request to the FMP API to fetch the company profile for the provided stock symbol.
#' It expects a single symbol and will return an error if multiple symbols are provided.
#' The response is processed into a tidy data frame with snake_case column names.
#'
#' @return A data frame containing the company's profile information.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' get_company_profile("AAPL")
#' }
#'
get_company_profile <- function(
    symbol
  ) {

  if (length(symbol) != 1) {
    cli::cli_abort(
      "Please provide a single {.arg symbol}."
    )
  }

  resource <- paste0("profile/", symbol)
  company_profile_raw <- perform_request(resource)

  company_profile <- company_profile_raw |>
    bind_rows() |>
    convert_column_names()

  company_profile

}

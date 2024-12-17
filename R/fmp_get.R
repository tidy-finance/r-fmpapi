#' Retrieve Financial Data from the FMP API
#'
#' This function fetches financial data from the Financial Modeling Prep (FMP)
#' API, including balance sheet statements, income statements, cash flow
#' statements, historical market data, stock lists, and company profiles.
#'
#' @param resource A string indicating the API resource to query. Examples
#'  include `"balance-sheet-statement"`, `"income-statement"`,
#'  `"cash-flow-statement"`, `"historical-market-capitalization"`,
#'  `"profile"`, and `"stock/list"`.
#' @param symbol A string specifying the stock ticker symbol (optional).
#' @param ... Additional arguments to customize the query. Examples include:
#'   \itemize{
#'     \item \code{limit}: An integer indicating the number of results to
#'      return.
#'     \item \code{period}: A string specifying the reporting period, such as
#'     `"annual"` or `"quarterly"`.
#'     \item \code{from}: A string in YYYY-MM-DD format indicating the start
#'      date for historical queries.
#'     \item \code{to}: A string in YYYY-MM-DD format indicating the end date
#'     for historical queries.
#'     \item \code{query}: A search string for querying stock information.
#'   }
#' @param api_version A string specifying the version of the FMP API to use.
#'  Defaults to `"v3"`.
#'
#' @return A data frame containing the balance sheet statements.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Get available balance sheet statements
#' fmp_get(
#'   resource = "balance-sheet-statement",
#'   symbol = "AAPL"
#' )
#'
#' # Get last income statements
#' fmp_get(
#'   resource = "income-statement",
#'   symbol = "AAPL",
#'   limit = 1
#' )
#'
#' # Get annual cash flow statements
#' fmp_get(
#'   resource = "cash-flow-statement",
#'   symbol = "AAPL",
#'   period = "annual"
#' )
#'
#' # Get historical market capitalization
#' fmp_get(
#'   resource = "historical-market-capitalization",
#'   symbol = "UNH",
#'   from = "2023-12-01",
#'   to = "2023-12-31"
#'  )
#'
#' # Get stock list
#' fmp_get(
#'   resource = "stock/list"
#' )
#'
#' # Get company profile
#' fmp_get(
#'   resource = "profile", symbol = "AAPL"
#' )
#'
#' # Search for stock information
#' fmp_get(
#'   resource = "search", query = "AA"
#' )
#' }
#'
fmp_get <- function(
  resource, symbol = NULL, ..., api_version = "v3"
) {

  dots <- list(...)

  if (!is.null(symbol)) {
    validate_symbol(symbol)
    resource_processed <- paste0(resource, "/", symbol)
  } else {
    resource_processed <- resource
  }

  if (!is.null(dots$limit)) {
    validate_limit(dots$limit)
  }

  if (!is.null(dots$period)) {
    validate_period(dots$period)
  }

  data_raw <- perform_request(
    resource_processed, ...,  api_version =  api_version
  )

  data_processed <- data_raw |>
    bind_rows() |>
    convert_column_names() |>
    convert_column_types()

  data_processed
}

#' Perform a request to the Financial Modeling Prep API
#'
#' This function sends a request to the Financial Modeling Prep (FMP) API based
#' on the specified resource and additional query parameters. It constructs the
#' request URL using the base API URL and the specified version, and it
#' automatically includes the API key from the environment.
#'
#' @param resource The specific API resource to be accessed, such as a stock
#'  symbol or financial endpoint.
#' @param base_url The base URL for the FMP API. Defaults to
#' "https://financialmodelingprep.com/api/".
#' @param api_version The version of the FMP API to use. Defaults to "v3".
#' @param ... Additional query parameters to be included in the API request.
#'
#' @return A parsed JSON response from the FMP API.
#'
#' @keywords internal
#'
perform_request <- function(
  resource,
  base_url = "https://financialmodelingprep.com/api/",
  api_version = "v3",
  ...
) {

  req <- create_request(base_url, api_version, resource, ...)

  resp <- req |>
    req_perform()

  if (resp$status_code != 200) {
    cli::cli_abort(
      resp_body_json(resp)
    )
  } else {
    body <- resp_body_json(resp)

    validate_body(body)

    body
  }

}

#' @keywords internal
create_request <- function(base_url, api_version, resource, ...) {
  request(base_url) |>
    req_url_path_append(api_version) |>
    req_url_path_append(resource) |>
    req_url_query(apikey = Sys.getenv("FMP_API_KEY"), ...) |>
    req_user_agent(
      "fmpapi R package (https://github.com/tidy-finance/r-fmpapi)"
    ) |>
    req_error(is_error = \(resp) FALSE)
}

#' @keywords internal
validate_symbol <- function(symbol) {
  if (length(symbol) != 1) {
    cli::cli_abort(
      "Please provide a single {.arg symbol}."
    )
  }
}

#' @keywords internal
validate_period <- function(period) {
  if (!period %in% c("annual", "quarter")) {
    cli::cli_abort(
      "{.arg period} must be either 'annual' or 'quarter'."
    )
  }
}

#' @keywords internal
validate_limit <- function(limit) {
  if (!is.numeric(limit) || limit %% 1L != 0 || limit < 1L) {
    cli::cli_abort("{.arg limit} must be an integer larger than 0.")
  }
}

#' @keywords internal
validate_body <- function(body) {
  if (length(body) == 0) {
    cli::cli_abort(
      "Response body is empty. Check your resource and parameter specification."
    )
  }
}

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

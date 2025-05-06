#' Retrieve Financial Data from the Financial Modeling Prep (FMP) API
#'
#' This function fetches financial data from the FMP API, including
#' balance sheet statements, income statements, cash flow statements,
#' historical market data, stock lists, and company profiles.
#'
#' @param resource A string indicating the API resource to query. Examples
#'  include `"balance-sheet-statement"`, `"income-statement"`,
#'  `"cash-flow-statement"`, `"historical-market-capitalization"`,
#'  `"profile"`, and `"stock/list"`.
#' @param symbol A string specifying the stock ticker symbol (optional).
#' @param params List of additional arguments to customize the query (optional).
#' @param api_version A string specifying the version of the FMP API to use.
#'  Defaults to `"v3"`.
#' @param snake_case A boolean indicating whether column names are converted
#'  to snake_case. Defaults to `TRUE`.
#'
#' @return A data frame containing the processed financial data.
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
#'   params = list(limit = 1)
#' )
#'
#' # Get annual cash flow statements
#' fmp_get(
#'   resource = "cash-flow-statement",
#'   symbol = "AAPL",
#'   params = list(period = "annual")
#' )
#'
#' # Get historical market capitalization
#' fmp_get(
#'   resource = "historical-market-capitalization",
#'   symbol = "UNH",
#'   params = list(from = "2023-12-01", to = "2023-12-31")
#' )
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
#'   resource = "search", params = list(query = "AAP")
#' )
#'
#' # Get data with original column names
#' fmp_get(
#'   resource = "profile", symbol = "AAPL", snake_case = FALSE
#' )
#' }
#'
fmp_get <- function(
  resource,
  symbol = NULL,
  params = list(),
  api_version = "v3",
  snake_case = TRUE
) {
  if (!is.null(symbol)) {
    validate_symbol(symbol)
    resource_processed <- paste0(resource, "/", symbol)
  } else {
    resource_processed <- resource
  }

  if (!is.null(params$limit)) {
    validate_limit(params$limit)
  }

  if (!is.null(params$period)) {
    validate_period(params$period)
  }

  data_raw <- perform_request(
    resource_processed,
    params,
    api_version = api_version
  )

  data_processed <- data_raw |>
    bind_rows() |>
    convert_column_types()

  if (snake_case) {
    data_processed <- data_processed |>
      convert_column_names()
  }

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
#' @param params Additional query parameters to be included in the API request.
#' @param base_url The base URL for the FMP API. Defaults to
#' "https://financialmodelingprep.com/api/".
#' @param api_version The version of the FMP API to use. Defaults to "v3".
#'
#' @return A parsed JSON response from the FMP API.
#'
#' @keywords internal
#'
perform_request <- function(
  resource,
  params,
  base_url = "https://financialmodelingprep.com/api/",
  api_version = "v3"
) {
  req <- create_request(base_url, api_version, resource, params)

  resp <- req |>
    req_perform()

  if (resp$status_code != 200) {
    cli::cli_abort(
      resp_body_json(resp)$`Error Message`
    )
  } else {
    body <- resp_body_json(resp)

    validate_body(body)

    body
  }
}

#' @keywords internal
create_request <- function(base_url, api_version, resource, params) {

  # nocov start
  if (Sys.getenv("FMP_API_KEY") == "") {
    cli::cli_abort(
      "Please set an API key using `fmp_set_api_key()`"
    )
  }
  # nocov end

  request(base_url) |>
    req_url_path_append(api_version) |>
    req_url_path_append(resource) |>
    req_url_query(apikey = Sys.getenv("FMP_API_KEY"), !!!params) |>
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
    mutate(
      across(contains("calendarYear"), as.integer),
      across(c(contains("Date"), contains("date")), function(x) {
        posix_converted <- as.POSIXct(x, tz = "UTC")
        has_time <- any(format(posix_converted, "%H:%M:%S") != "00:00:00")
        if (!has_time) {
          return(as.Date(x))
        }
        posix_converted
      })
    )
}

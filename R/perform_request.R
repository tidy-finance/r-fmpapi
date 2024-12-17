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

  resp <- req_perform(req)

  body <- resp_body_json(resp)

  body
}

#' @keywords internal
create_request <- function(base_url, api_version, resource, ...) {
  request(base_url) |>
    req_url_path_append(api_version) |>
    req_url_path_append(resource) |>
    req_url_query(apikey = Sys.getenv("FMP_API_KEY"), ...) |>
    req_user_agent(
      "fmpapi R package (https://github.com/tidy-finance/r-fmpapi)"
    )
}

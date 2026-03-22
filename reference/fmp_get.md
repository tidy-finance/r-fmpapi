# Retrieve Financial Data from the Financial Modeling Prep (FMP) API

This function fetches financial data from the FMP API, including balance
sheet statements, income statements, cash flow statements, historical
market data, stock lists, and company profiles.

## Usage

``` r
fmp_get(
  resource,
  symbol = NULL,
  params = list(),
  api_version = "stable",
  snake_case = TRUE
)
```

## Arguments

- resource:

  A string indicating the API resource to query. Examples include
  `"balance-sheet-statement"`, `"income-statement"`,
  `"cash-flow-statement"`, `"historical-market-capitalization"`,
  `"profile"`, and `"stock/list"`.

- symbol:

  A string specifying the stock ticker symbol (optional).

- params:

  List of additional arguments to customize the query (optional).

- api_version:

  A string specifying the version of the FMP API to use. Defaults to
  `"v3"`.

- snake_case:

  A boolean indicating whether column names are converted to snake_case.
  Defaults to `TRUE`.

## Value

A data frame containing the processed financial data.

## Examples

``` r
if (FALSE) { # \dontrun{
# Get available balance sheet statements
fmp_get(
  resource = "balance-sheet-statement",
  symbol = "AAPL"
)

# Get last income statements
fmp_get(
  resource = "income-statement",
  symbol = "AAPL",
  params = list(limit = 1)
)

# Get annual cash flow statements
fmp_get(
  resource = "cash-flow-statement",
  symbol = "AAPL",
  params = list(period = "annual")
)

# Get historical market capitalization
fmp_get(
  resource = "historical-market-capitalization",
  symbol = "UNH",
  params = list(from = "2023-12-01", to = "2023-12-31")
)

# Get stock list
fmp_get(
  resource = "stock/list"
)

# Get company profile
fmp_get(
  resource = "profile", symbol = "AAPL"
)

# Search for stock information
fmp_get(
  resource = "search", params = list(query = "AAP")
)

# Get data with original column names
fmp_get(
  resource = "profile", symbol = "AAPL", snake_case = FALSE
)
} # }
```

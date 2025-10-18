# Validation tests --------------------------------------------------------

test_that("fmp_get validates limit correctly", {
  expect_error(
    fmp_get(
      resource = "balance-sheet-statement",
      symbol = "AAPL",
      params = list(limit = -1)
    ),
    "limit.*must be an integer larger than 0"
  )
  expect_error(
    fmp_get(
      resource = "balance-sheet-statement",
      symbol = "AAPL",
      params = list(limit = "ten")
    ),
    "limit.*must be an integer larger than 0"
  )
})

test_that("fmp_get validates period input", {
  expect_error(
    fmp_get(
      resource = "cash-flow-statement",
      symbol = "AAPL",
      params = list(period = "monthly")
    ),
    "period.*must be either 'annual' or 'quarter'"
  )
})

test_that("fmp_get validates symbol input", {
  expect_error(
    fmp_get(resource = "profile", symbol = c("AAPL", "MSFT")),
    "provide a single `symbol`"
  )
})

# Request handling tests --------------------------------------------------

test_that("fmp_get parses response without symbol inputs", {
  example_body <- '[
    {
      "symbol": "ABCX.US",
      "name": "AlphaBeta Corporation",
      "price": 152.35,
      "exchange": "New York Stock Exchange",
      "exchangeShortName": "NYSE",
      "type": "stock"
    },
    {
      "symbol": "GLOTECH.TO",
      "name": "Global Technologies Inc.",
      "price": 88.50,
      "exchange": "Toronto Stock Exchange",
      "exchangeShortName": "TSX",
      "type": "stock"
    }
  ]'

  my_mock <- function(req) {
    response(
      status_code = 200L,
      headers = list("Content-Type" = "application/json"),
      body = charToRaw(example_body)
    )
  }

  with_mocked_bindings(
    validate_api_key = function(...) invisible(TRUE),
    with_mocked_responses(
      my_mock,
      {
        result <- fmp_get(resource = "stock/list")
        expect_type(result, "list")
        expect_equal(nrow(result), 2)
        expect_equal(result$symbol[1], "ABCX.US")
      }
    )
  )
})

test_that("fmp_get parses response with symbol inputs", {
  example_body <- c(
    '{
    "date": "2024-09-28",
    "symbol": "XYZC",
    "reportedCurrency": "USD",
    "cik": "0001234567",
    "fillingDate": "2024-11-01",
    "acceptedDate": "2024-11-01 06:01:36",
    "calendarYear": "2024",
    "period": "FY",
    "cashAndCashEquivalents": 67890
    }'
  )

  my_mock <- function(req) {
    response(
      status_code = 200,
      body = charToRaw(example_body),
      headers = list("Content-Type" = "application/json")
    )
  }

  with_mocked_bindings(
    validate_api_key = function(...) invisible(TRUE),
    with_mocked_responses(
      my_mock,
      {
        result <- fmp_get(resource = "balance-sheet-statement", "AAPL")
        expect_type(result, "list")
      }
    )
  )
})

test_that("perform_request throws error on non-200 response", {
  my_mock <- function(req) {
    response(
      status_code = 400,
      body = charToRaw('{"Invalid request"}'),
      headers = list("Content-Type" = "application/json")
    )
  }

  with_mocked_bindings(
    validate_api_key = function(...) invisible(TRUE),
    with_mocked_responses(
      my_mock,
      {
        expect_error(
          perform_request(resource = "invalid-resource", params = list()),
          "Invalid request"
        )
      }
    )
  )
})

test_that("perform_request handles empty responses", {
  my_mock <- function(req) {
    response(
      status_code = 200,
      body = charToRaw("[]"),
      headers = list("Content-Type" = "application/json")
    )
  }

  with_mocked_bindings(
    validate_api_key = function(...) invisible(TRUE),
    with_mocked_responses(
      my_mock,
      {
        expect_error(
          perform_request(resource = "invalid-resource", params = list()),
          "Response body is empty."
        )
      }
    )
  )
})

# Conversion tests --------------------------------------------------------

test_that("convert_column_names converts names to snake_case", {
  df <- data.frame(
    calendarYear = 2023,
    Date = "2023-12-31",
    SymbolName = "AAPL"
  )
  df_converted <- convert_column_names(df)

  expect_equal(
    names(df_converted),
    c("calendar_year", "date", "symbol_name")
  )
})


test_that("convert_column_types updates column types", {
  df <- data.frame(
    calendarYear = c("2023", "2022"),
    date = c("2023-12-31", "2022-12-31"),
    value = c(12345, 54321)
  )
  df_converted <- convert_column_types(df)

  expect_type(df_converted$calendarYear, "integer")
  expect_s3_class(df_converted$date, "Date")
  expect_type(df_converted$value, "double")
})

test_that("returns resource when symbol is NULL (no validation called)", {
  expect_equal(
    with_mocked_bindings(
      build_resource("users", NULL, "stable"),
      validate_symbol = function(x) stop("validate_symbol should not be called")
    ),
    "users"
  )
})

test_that(
  paste(
    "returns resource unchanged for api_version == 'stable' with symbol"
  ),
  {
    called <- 0
    out <- with_mocked_bindings(
      build_resource("users", "AAPL", "stable"),
      validate_symbol = function(x) {
        called <<- called + 1
        invisible(TRUE)
      }
    )
    expect_equal(out, "users")
    expect_equal(called, 1)
  }
)

test_that(
  paste("appends symbol for non-stable api_version (validation called once)"),
  {
    called <- 0
    out <- with_mocked_bindings(
      build_resource("users", "AAPL", "beta"),
      validate_symbol = function(x) {
        called <<- called + 1
        invisible(TRUE)
      }
    )
    expect_equal(out, "users/AAPL")
    expect_equal(called, 1)
  }
)

test_that(
  paste(
    "keeps resource as-is when symbol is NULL for non-stable api_version"
  ),
  {
    expect_equal(
      with_mocked_bindings(
        build_resource("users", NULL, "beta"),
        validate_symbol = function(x) {
          stop("validate_symbol should not be called")
        }
      ),
      "users"
    )
  }
)

test_that("does not normalize slashes (current behavior preserved)", {
  out <- with_mocked_bindings(
    build_resource("users/", "AAPL", "beta"),
    validate_symbol = function(x) invisible(TRUE)
  )
  expect_equal(out, "users//AAPL")
})

test_that("appends 'api/' for versions v1, v2, v3", {
  expect_equal(build_base_url("https://ex.com/", "v1"), "https://ex.com/api/")
  expect_equal(build_base_url("https://ex.com/", "v2"), "https://ex.com/api/")
  expect_equal(build_base_url("https://ex.com/", "v3"), "https://ex.com/api/")
})

test_that("does not append for non-listed versions", {
  expect_equal(build_base_url("https://ex.com/", "stable"), "https://ex.com/")
  expect_equal(build_base_url("https://ex.com/", "beta"), "https://ex.com/")
  expect_equal(build_base_url("https://ex.com/", "preview"), "https://ex.com/")
})

test_that("current behavior preserves base_url exactly ", {
  expect_equal(build_base_url("https://ex.com", "v1"), "https://ex.comapi/")

  expect_equal(build_base_url("https://ex.com/", "v1"), "https://ex.com/api/")

  expect_equal(
    build_base_url("https://ex.com/api/", "v1"),
    "https://ex.com/api/api/"
  )
})

test_that("NULL api_version errors (documenting current R semantics)", {
  expect_error(build_base_url("https://ex.com/", NULL))
})

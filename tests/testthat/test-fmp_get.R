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
        expect_warning(
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


test_that("calendarYear columns are converted to integer", {
  df <- data.frame(
    calendarYear = c("2020", "2021", "2022"),
    stringsAsFactors = FALSE
  )
  result <- convert_column_types(df)
  expect_type(result$calendarYear, "integer")
  expect_equal(result$calendarYear, c(2020L, 2021L, 2022L))
})

test_that("multiple calendarYear columns are all converted", {
  df <- data.frame(
    calendarYear = c("2020", "2021"),
    calendarYear_end = c("2022", "2023"),
    check.names = FALSE,
    stringsAsFactors = FALSE
  )
  result <- convert_column_types(df)
  expect_type(result$calendarYear, "integer")
  expect_type(result$calendarYear_end, "integer")
})

test_that("date-only strings become Date class", {
  df <- data.frame(
    filingDate = c("2023-01-15", "2023-06-30"),
    stringsAsFactors = FALSE
  )
  result <- convert_column_types(df)
  expect_s3_class(result$filingDate, "Date")
  expect_equal(result$filingDate, as.Date(c("2023-01-15", "2023-06-30")))
})

test_that("datetime strings with nonzero time become POSIXct", {
  df <- data.frame(
    updatedDate = c("2023-01-15 14:30:00", "2023-06-30 09:00:00"),
    stringsAsFactors = FALSE
  )
  result <- convert_column_types(df)
  expect_s3_class(result$updatedDate, "POSIXct")
  expect_equal(
    result$updatedDate,
    as.POSIXct(c("2023-01-15 14:30:00", "2023-06-30 09:00:00"), tz = "UTC")
  )
})

test_that("datetime strings with all-zero times become Date", {
  df <- data.frame(
    acceptedDate = c("2023-01-15 00:00:00", "2023-06-30 00:00:00"),
    stringsAsFactors = FALSE
  )
  result <- convert_column_types(df)
  expect_s3_class(result$acceptedDate, "Date")
  expect_equal(result$acceptedDate, as.Date(c("2023-01-15", "2023-06-30")))
})

test_that("empty strings are treated as NA in date columns", {
  df <- data.frame(
    filingDate = c("2023-01-15", "", "2023-03-20"),
    stringsAsFactors = FALSE
  )
  result <- convert_column_types(df)
  expect_s3_class(result$filingDate, "Date")
  expect_true(is.na(result$filingDate[2]))
  expect_equal(
    result$filingDate[c(1, 3)],
    as.Date(c("2023-01-15", "2023-03-20"))
  )
})

test_that("all-NA date column returns Date vector of NAs", {
  df <- data.frame(filingDate = c("", "", ""), stringsAsFactors = FALSE)
  result <- convert_column_types(df)
  expect_s3_class(result$filingDate, "Date")
  expect_true(all(is.na(result$filingDate)))
})

test_that("unparseable date strings return Date NAs", {
  df <- data.frame(
    filingDate = c("not-a-date", "also-bad"),
    stringsAsFactors = FALSE
  )
  result <- convert_column_types(df)
  expect_s3_class(result$filingDate, "Date")
  expect_true(all(is.na(result$filingDate)))
})

test_that("columns matching 'date' (lowercase) are also converted", {
  df <- data.frame(
    trade_date = c("2023-05-01", "2023-05-02"),
    stringsAsFactors = FALSE
  )
  result <- convert_column_types(df)
  expect_s3_class(result$trade_date, "Date")
})

test_that("columns not matching date or calendarYear are left untouched", {
  df <- data.frame(
    ticker = c("AAPL", "GOOG"),
    revenue = c(100.5, 200.3),
    filingDate = c("2023-01-01", "2023-06-01"),
    stringsAsFactors = FALSE
  )
  result <- convert_column_types(df)
  expect_type(result$ticker, "character")
  expect_type(result$revenue, "double")
  expect_equal(result$ticker, c("AAPL", "GOOG"))
  expect_equal(result$revenue, c(100.5, 200.3))
})

test_that("mixed NA and datetime values preserve POSIXct when time component exists", {
  df <- data.frame(
    updatedDate = c("2023-01-15 10:30:00", "", "2023-03-20 00:00:00"),
    stringsAsFactors = FALSE
  )
  result <- convert_column_types(df)
  expect_s3_class(result$updatedDate, "POSIXct")
  expect_true(is.na(result$updatedDate[2]))
})

test_that("single-row data frame works", {
  df <- data.frame(
    calendarYear = "2024",
    filingDate = "2024-03-15",
    stringsAsFactors = FALSE
  )
  result <- convert_column_types(df)
  expect_type(result$calendarYear, "integer")
  expect_s3_class(result$filingDate, "Date")
})

test_that("zero-row data frame does not error", {
  df <- data.frame(
    calendarYear = character(0),
    filingDate = character(0),
    stringsAsFactors = FALSE
  )
  expect_no_error(convert_column_types(df))
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

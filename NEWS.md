# fmpapi (development version)

## Improvements

- Refactored core data retrieval functions to a single flexible interface: `fmp_get()`

# fmpapi 0.1.0

## Initial Release

- Added function `set_fmp_api_key()` to store and manage Financial Modeling Prep (FMP) API keys securely in an `.Renviron` file.
- Introduced the core data retrieval functions:
  - `get_company_profile()` to retrieve a company's profile based on its stock symbol.
  - `get_balance_sheet_statements()` to fetch balance sheet statements (annual or quarterly) for a specific stock symbol.
  - `get_income_statements()` to retrieve income statements (annual or quarterly) for a company.
  - `get_cash_flow_statements()` to retrieve cash flow statements (annual or quarterly) for a company.
- All API responses are returned as tidy data frames with snake_case column names for easy integration with common R workflows.


<!-- README.md is generated from README.Rmd. Please edit that file -->

# fmpapi

[![License:
MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Overview

`fmpapi` is an R package that provides a tidy interface to the
[Financial Modeling Prep (FMP)
API](https://site.financialmodelingprep.com/developer/docs). With this
package, you can easily retrieve financial data such as company
profiles, balance sheet statements, income statements, and cash flow
statements. The package returns data as tidy data frames, with
snake_case column names, making it easier to integrate into your data
analysis workflows.

## Installation

Currently, `fmpapi` is not on CRAN. You can install the development
version from GitHub:

``` r
pak::pak("tidy-finance/r-fmpapi")
```

## Setup

Before using the package, you need to set your Financial Modeling Prep
API key. You can set it using the `set_fmp_api_key()` function, which
saves the key to your `.Renviron` file for future use.

``` r
library(fmpapi)

set_fmp_api_key()
```

## Usage

### Fetching Company Profiles

You can retrieve a company’s profile by providing its stock symbol:

``` r
get_company_profile("AAPL")
```

### Fetching Balance Sheet Statements

To retrieve the balance sheet statements for a company, use the
`get_balance_sheet_statements()` function. You can specify whether to
retrieve annual or quarterly data and the number of records.

``` r
get_balance_sheet_statements("AAPL", period = "annual", limit = 5)
```

### Fetching Income Statements

The `get_income_statements()` function allows you to retrieve income
statements for a specific stock symbol. You can specify the period and
the limit of records to return.

``` r
get_income_statements("MSFT", period = "annual", limit = 5)
```

### Fetching Cash Flow Statements

You can fetch cash flow statements using the get_cash_flow_statements()
function, specifying the period and the number of records to retrieve.

``` r
get_cash_flow_statements("TSLA", period = "annual", limit = 5)
```

## Contributing

Feel free to open issues or submit pull requests to improve the package.
Contributions are welcome!

## License

This package is licensed under the MIT License.

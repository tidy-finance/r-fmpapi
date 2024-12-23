
<!-- README.md is generated from README.Rmd. Please edit that file -->

# r-fmpapi

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/fmpapi)](https://cran.r-project.org/package=fmpapi)
[![CRAN
downloads](https://cranlogs.r-pkg.org/badges/fmpapi)](https://cran.r-project.org/package=fmpapi)
[![R-CMD-check](https://github.com/tidy-finance/r-fmpapi/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/tidy-finance/r-fmpapi/actions/workflows/R-CMD-check.yaml)
[![Lint](https://github.com/tidy-finance/r-fmpapi/actions/workflows/lint.yaml/badge.svg)](https://github.com/tidy-finance/r-fmpapi/actions/workflows/lint.yaml)
[![Codecov test
coverage](https://codecov.io/gh/tidy-finance/r-fmpapi/graph/badge.svg)](https://app.codecov.io/gh/tidy-finance/r-fmpapi)
[![License:
MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

<!-- badges: end -->

Provides a flexible interface to the [‘Financial Modeling Prep’
API](https://site.financialmodelingprep.com/developer/docs). The package
supports all available endpoints and parameters, enabling R users to
interact with a wide range of financial data.

This package is a product of Christoph Scheuch and not sponsored by or
affiliated with FMP in any way. For a Python implementation, please
consider the [`py-fmpapi`](https://github.com/tidy-finance/py-fmpapi)
library.

## Installation

You can install the package from CRAN via:

``` r
install.packages("fmpapi")
```

You can install the development version from GitHub:

``` r
pak::pak("tidy-finance/r-fmpapi")
```

## Setup

Before using the package, you need to set your Financial Modeling Prep
API key. You can set it using the `fmp_set_api_key()` function, which
saves the key to your `.Renviron` file for future use (either in your
project or home folder).

``` r
library(fmpapi)

fmp_set_api_key()
```

## Usage

Since the FMP API has a myriad of endpoints and parameters, the package
provides a single function to handle requests: `fmp_get()`.

You can retrieve a company’s profile by providing its stock symbol to
the `profile` endpoint:

``` r
fmp_get(resource = "profile", symbol = "AAPL")
```

To retrieve the balance sheet statements for a company, use the
`balance-sheet-statement` endpoint. You can specify whether to retrieve
annual or quarterly data using the `period` parameter and the number of
records via `limit`. Note that you need a paid account for quarterly
data.

``` r
fmp_get(resource = "balance-sheet-statement", symbol = "AAPL", params = list(period = "annual", limit = 5))
```

The `income-statement` endpoint allows you to retrieve income statements
for a specific stock symbol.

``` r
fmp_get(resource = "income-statement", symbol = "AAPL")
```

You can fetch cash flow statements using the `cash-flow-statement`
endpoint.

``` r
fmp_get(resource = "cash-flow-statement", symbol = "AAPL")
```

Most free endpoints live under API version 3, but you can also control
the api version in `fmp_get()`, which you need for some paid endpoints.
For instance, the `symbol_change` endpoint:

``` r
fmp_get(resource = "symbol_change", api_version = "v4")
```

## Relation to Existing Packages

There are two existing R packages that also provide an interface to the
FMP API. Both packages lack flexibility because they provide dedicated
functions for each endpoint, which means that users need to study both
the FMP API docs and the package documentation and developers have to
create new functions for each new endpoint.

- [fmpapi](https://github.com/jpiburn/fmpapi): not released on CRAN and
  last commit more than 3 years ago.
- [fmpcloudr](https://cran.r-project.org/package=fmpcloudr): last
  updated on CRAN more than 3 years ago.

## Contributing

Feel free to open issues or submit pull requests to improve the package.
Contributions are welcome!

## License

This package is licensed under the MIT License.

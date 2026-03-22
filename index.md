# r-fmpapi

Provides a flexible interface to the [‘Financial Modeling Prep’
API](https://site.financialmodelingprep.com/developer/docs). The package
supports all available endpoints and parameters, enabling R users to
interact with a wide range of financial data.

> 💡 This package is developed by Christoph Scheuch and not sponsored by
> or affiliated with FMP. However, you can get **15% off** your FMP
> subscription by using [this affiliate
> link](https://site.financialmodelingprep.com/pricing-plans?couponCode=tidyfinance).
> By signing up through this link, you also support the development of
> this package at no extra cost to you.

For a Python implementation, please consider the
[`py-fmpapi`](https://github.com/tidy-finance/py-fmpapi) library.

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
API key. You can set it using the
[`fmp_set_api_key()`](https://tidy-finance.github.io/r-fmpapi/reference/fmp_set_api_key.md)
function, which saves the key to your `.Renviron` file for future use
(either in your project or home folder).

``` r
fmp_set_api_key()
```

## Usage

``` r
library(fmpapi)
```

Since the FMP API has a myriad of endpoints and parameters, the package
provides a single function to handle requests:
[`fmp_get()`](https://tidy-finance.github.io/r-fmpapi/reference/fmp_get.md).

You can retrieve a company’s profile by providing its stock symbol to
the `profile` endpoint:

``` r
fmp_get(resource = "profile", symbol = "AAPL")
#> # A tibble: 1 × 36
#>   symbol price    market_cap  beta last_dividend range  change change_percentage
#>   <chr>  <dbl>         <dbl> <dbl>         <dbl> <chr>   <dbl>             <dbl>
#> 1 AAPL    248. 3644938780583  1.12          1.04 169.2…  -0.97            -0.390
#> # ℹ 28 more variables: volume <int>, average_volume <int>, company_name <chr>,
#> #   currency <chr>, cik <chr>, isin <chr>, cusip <chr>,
#> #   exchange_full_name <chr>, exchange <chr>, industry <chr>, website <chr>,
#> #   description <chr>, ceo <chr>, sector <chr>, country <chr>,
#> #   full_time_employees <chr>, phone <chr>, address <chr>, city <chr>,
#> #   state <chr>, zip <chr>, image <chr>, ipo_date <date>, default_image <lgl>,
#> #   is_etf <lgl>, is_actively_trading <lgl>, is_adr <lgl>, is_fund <lgl>
```

To retrieve the balance sheet statements for a company, use the
`balance-sheet-statement` endpoint. You can specify whether to retrieve
annual or quarterly data using the `period` parameter and the number of
records via `limit`. Note that you need a paid account for quarterly
data.

``` r
fmp_get(
  resource = "balance-sheet-statement",
  symbol = "AAPL",
  params = list(period = "annual", limit = 5)
)
#> # A tibble: 5 × 61
#>   date       symbol reported_currency cik        filing_date accepted_date      
#>   <date>     <chr>  <chr>             <chr>      <date>      <dttm>             
#> 1 2025-09-27 AAPL   USD               0000320193 2025-10-31  2025-10-31 06:01:26
#> 2 2024-09-28 AAPL   USD               0000320193 2024-11-01  2024-11-01 06:01:36
#> 3 2023-09-30 AAPL   USD               0000320193 2023-11-03  2023-11-02 18:08:27
#> 4 2022-09-24 AAPL   USD               0000320193 2022-10-28  2022-10-27 18:01:14
#> 5 2021-09-25 AAPL   USD               0000320193 2021-10-29  2021-10-28 18:04:28
#> # ℹ 55 more variables: fiscal_year <chr>, period <chr>,
#> #   cash_and_cash_equivalents <dbl>, short_term_investments <dbl>,
#> #   cash_and_short_term_investments <dbl>, net_receivables <dbl>,
#> #   accounts_receivables <dbl>, other_receivables <dbl>, inventory <dbl>,
#> #   prepaids <int>, other_current_assets <dbl>, total_current_assets <dbl>,
#> #   property_plant_equipment_net <dbl>, goodwill <int>,
#> #   intangible_assets <int>, goodwill_and_intangible_assets <int>, …
```

The `income-statement` endpoint allows you to retrieve income statements
for a specific stock symbol.

``` r
fmp_get(resource = "income-statement", symbol = "AAPL")
#> # A tibble: 5 × 39
#>   date       symbol reported_currency cik        filing_date accepted_date      
#>   <date>     <chr>  <chr>             <chr>      <date>      <dttm>             
#> 1 2025-09-27 AAPL   USD               0000320193 2025-10-31  2025-10-31 06:01:26
#> 2 2024-09-28 AAPL   USD               0000320193 2024-11-01  2024-11-01 06:01:36
#> 3 2023-09-30 AAPL   USD               0000320193 2023-11-03  2023-11-02 18:08:27
#> 4 2022-09-24 AAPL   USD               0000320193 2022-10-28  2022-10-27 18:01:14
#> 5 2021-09-25 AAPL   USD               0000320193 2021-10-29  2021-10-28 18:04:28
#> # ℹ 33 more variables: fiscal_year <chr>, period <chr>, revenue <dbl>,
#> #   cost_of_revenue <dbl>, gross_profit <dbl>,
#> #   research_and_development_expenses <dbl>,
#> #   general_and_administrative_expenses <dbl>,
#> #   selling_and_marketing_expenses <dbl>,
#> #   selling_general_and_administrative_expenses <dbl>, other_expenses <int>,
#> #   operating_expenses <dbl>, cost_and_expenses <dbl>, …
```

You can fetch cash flow statements using the `cash-flow-statement`
endpoint.

``` r
fmp_get(resource = "cash-flow-statement", symbol = "AAPL")
#> # A tibble: 5 × 47
#>   date       symbol reported_currency cik        filing_date accepted_date      
#>   <date>     <chr>  <chr>             <chr>      <date>      <dttm>             
#> 1 2025-09-27 AAPL   USD               0000320193 2025-10-31  2025-10-31 06:01:26
#> 2 2024-09-28 AAPL   USD               0000320193 2024-11-01  2024-11-01 06:01:36
#> 3 2023-09-30 AAPL   USD               0000320193 2023-11-03  2023-11-02 18:08:27
#> 4 2022-09-24 AAPL   USD               0000320193 2022-10-28  2022-10-27 18:01:14
#> 5 2021-09-25 AAPL   USD               0000320193 2021-10-29  2021-10-28 18:04:28
#> # ℹ 41 more variables: fiscal_year <chr>, period <chr>, net_income <dbl>,
#> #   depreciation_and_amortization <dbl>, deferred_income_tax <dbl>,
#> #   stock_based_compensation <dbl>, change_in_working_capital <dbl>,
#> #   accounts_receivables <dbl>, inventory <dbl>, accounts_payables <dbl>,
#> #   other_working_capital <dbl>, other_non_cash_items <dbl>,
#> #   net_cash_provided_by_operating_activities <dbl>,
#> #   investments_in_property_plant_and_equipment <dbl>, …
```

You can fetch market capitalization for multiple stocks:

``` r
fmp_get(
  "market-capitalization-batch",
  params = list("symbols" = c("AAPL", "MSFT", "GOOGL"))
)
#> # A tibble: 3 × 3
#>   symbol date          market_cap
#>   <chr>  <date>             <dbl>
#> 1 AAPL   2026-03-20 3644938780583
#> 2 MSFT   2026-03-20 2835625328100
#> 3 GOOGL  2026-03-20 3641197199262
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

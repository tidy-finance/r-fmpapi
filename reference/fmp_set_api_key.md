# Set the Financial Modeling Prep API key

This function prompts the user to input their Financial Modeling Prep
(FMP) API key and saves it to a `.Renviron` file, either in the project
directory or the home directory. It also gives the user the option to
add `.Renviron` to `.gitignore` for security purposes.

## Usage

``` r
fmp_set_api_key()
```

## Value

Invisibly returns `TRUE` after saving the key or aborting the operation.
The function will read the `.Renviron` file after saving, allowing the
environment variables to be immediately available. A restart of the R
session is recommended.

## Examples

``` r
# \donttest{
fmp_set_api_key()
#> Enter your FMP API key: 
#> Where do you want to store the .Renviron file? Enter 'project' for project directory or 'home' for home directory: 
#> Invalid choice. Please start again and enter "project" or "home".
# }

```

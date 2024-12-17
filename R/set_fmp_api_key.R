#' Set the Financial Modeling Prep API key
#'
#' This function prompts the user to input their Financial Modeling Prep (FMP)
#' API key and saves it to a `.Renviron` file, either in the project directory
#' or the home directory. It also gives the user the option to add `.Renviron`
#' to `.gitignore` for security purposes.
#'
#' @return Invisibly returns `TRUE` after saving the key or aborting the
#' operation. The function will read the `.Renviron` file after saving,
#' allowing the environment variables to be immediately available. A restart of
#' the R session is recommended.
#'
#' @export
#'
set_fmp_api_key <- function() {
  fmp_api_key <- readline(prompt = "Enter your FMP API key: ")

  location_choice <- readline(
    prompt = paste0(
      "Where do you want to store the .Renviron file? ",
      "Enter 'project' for project directory or 'home' for home directory: "
    )
  )

  if (tolower(location_choice) == "project") {
    renviron_path <- file.path(getwd(), ".Renviron")
    gitignore_path <- file.path(getwd(), ".gitignore")
  } else if (tolower(location_choice) == "home") {
    renviron_path <- file.path(Sys.getenv("HOME"), ".Renviron")
    gitignore_path <- file.path(Sys.getenv("HOME"), ".gitignore")
  } else {
    cli::cli_inform(
      paste0(
        "Invalid choice. Please start again and enter ",
        "{.str project} or {.str home}."
      )
    )
    return(invisible(TRUE))
  }

  if (file.exists(renviron_path)) {
    env_lines <- readLines(renviron_path)
  } else {
    env_lines <- character()
  }

  fmp_api_key_exists <- any(grepl("^FMP_API_KEY=", env_lines))

  if (fmp_api_key_exists) {
    overwrite_choice <- readline(
      prompt = paste0(
        "API key already exist. Do you want to overwrite it? ",
        "Enter 'yes' or 'no': "
      )
    )
    if (tolower(overwrite_choice) != "yes") {
      cli::cli_inform("Aborted. API key already exist and is not overwritten.")
      return(invisible(TRUE))
    }
  }

  if (file.exists(gitignore_path)) {
    add_gitignore <- readline(
      prompt = paste0(
        "Do you want to add .Renviron to .gitignore? ",
        "It is highly recommended! Enter 'yes' or 'no': "
      )
    )
    if (tolower(add_gitignore) == "yes") {
      gitignore_lines <- readLines(gitignore_path)
      if (!any(grepl("^\\.Renviron$", gitignore_lines))) {
        gitignore_lines <- c(gitignore_lines, ".Renviron")
        writeLines(gitignore_lines, gitignore_path)
        cli::cli_inform("{.file .Renviron} added to {.file .gitignore}.")
      }
    } else if (tolower(add_gitignore) == "no") {
      cli::cli_inform("{.file .Renviron} NOT added to {.file .gitignore}.")
    } else {
      cli::cli_inform(
        "Invalid choice. Please start again and enter 'yes' or 'no'."
      )
      return(invisible(TRUE))
    }
  }

  env_lines <- env_lines[!grepl("^FMP_API_KEY=", env_lines)]

  env_lines <- c(env_lines, sprintf("FMP_API_KEY=%s", fmp_api_key))

  writeLines(env_lines, renviron_path)

  readRenviron(renviron_path)

  cli::cli_inform(
    paste0(
      "FMP API key has been set and saved in {.file .Renviron} in your ",
      "{.path {location_choice}} directory. Please restart your R session ",
      "to load the new environment."
    )
  )
}

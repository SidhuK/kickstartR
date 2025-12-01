#' Load kickstartR Configuration
#'
#' Loads configuration from .kickstartR.yml file if present.
#' Checks current directory first, then user home directory.
#'
#' @return List of configuration options merged with defaults.
#' @keywords internal
load_config <- function() {
  defaults <- list(
    template = "basic",
    include_renv = FALSE,
    include_models = TRUE,
    include_notebooks = TRUE,
    include_targets = FALSE,
    create_rproj = TRUE,
    license = NULL,
    author = NULL,
    custom_dirs = NULL,
    git_init = FALSE,
    open_project = FALSE,
    open_readme = FALSE
  )

  config_paths <- c(
    file.path(".", ".kickstartR.yml"),
    file.path(".", ".kickstartR.yaml"),
    file.path(Sys.getenv("HOME"), ".kickstartR.yml"),
    file.path(Sys.getenv("HOME"), ".kickstartR.yaml")
  )

  config_file <- NULL
  for (path in config_paths) {
    if (file.exists(path)) {
      config_file <- path
      break
    }
  }

  if (is.null(config_file)) {
    return(defaults)
  }

  if (!requireNamespace("yaml", quietly = TRUE)) {
    message("Note: 'yaml' package not installed. Using default config.")
    message("Install with: install.packages('yaml')")
    return(defaults)
  }

  tryCatch({
    user_config <- yaml::read_yaml(config_file)
    message("Loaded config from: ", config_file)

    if (!is.null(user_config$defaults)) {
      for (name in names(user_config$defaults)) {
        if (name %in% names(defaults)) {
          defaults[[name]] <- user_config$defaults[[name]]
        }
      }
    }

    if (!is.null(user_config$author$name)) {
      defaults$author <- user_config$author$name
    }

    if (!is.null(user_config$custom_dirs)) {
      defaults$custom_dirs <- user_config$custom_dirs
    }

    defaults
  }, error = function(e) {
    warning("Error reading config file: ", e$message)
    defaults
  })
}

#' Create Default Config File
#'
#' Creates a .kickstartR.yml configuration file with default settings.
#' This file can be customized to set team-wide or personal defaults.
#'
#' @param path Directory where config file should be created. Default is current directory.
#' @param global If TRUE, creates config in user's home directory (~/.kickstartR.yml).
#' @return Invisibly returns the path to the created config file.
#' @export
#' @examples
#' \dontrun{
#' # Create config in current directory
#' create_config()
#'
#' # Create global config in home directory
#' create_config(global = TRUE)
#' }
create_config <- function(path = ".", global = FALSE) {
  config_content <- c(
    "# kickstartR Configuration",
    "# https://github.com/sidhuk/kickstartR",
    "",
    "defaults:",
    "  template: basic        # basic, analysis, shiny, targets, minimal",
    "  include_renv: false    # Initialize renv for dependency management",
    "  include_models: true   # Include 04_models folder",
    "  include_notebooks: true # Include 05_notebooks folder",
    "  include_targets: false # Include targets pipeline files",
    "  create_rproj: true     # Create RStudio .Rproj file",
    "  license: MIT           # MIT, GPL-3, GPL-2, CC-BY-4.0, CC0, or null",
    "  git_init: false        # Initialize git repository",
    "",
    "author:",
    "  name: \"Your Name\"",
    "  email: \"you@example.com\"",
    "",
    "# Add custom directories to every project:",
    "# custom_dirs:",
    "#   - \"06_archive\"",
    "#   - \"07_references\""
  )

  dest <- if (global) {
    file.path(Sys.getenv("HOME"), ".kickstartR.yml")
  } else {
    file.path(path, ".kickstartR.yml")
  }

  if (file.exists(dest)) {
    stop("Config file already exists: ", dest)
  }

  writeLines(config_content, dest)
  message("Created config file: ", dest)
  invisible(dest)
}

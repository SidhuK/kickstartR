#' Initialize a New Project with Boilerplate Structure
#'
#' Creates a standardized directory structure for a new R project with
#' customizable templates, dependency management, and workflow tools.
#'
#' @param project_name The name of the project (required). This will be the
#'   name of the main project directory.
#' @param path The path where the project directory should be created.
#'   Defaults to the current working directory.
#' @param template Project template to use. One of "basic", "analysis",
#'   "shiny", "targets", or "minimal". See `available_templates()` for details.
#' @param overwrite If TRUE and a directory with `project_name` already exists,
#'   it will be overwritten (use with caution). Defaults to FALSE.
#' @param author Author name for project metadata and LICENSE file.
#'   Defaults to system username.
#' @param license License type for the project. One of "MIT", "GPL-3", "GPL-2",
#'   "CC-BY-4.0", "CC0", or NULL for no license. See `available_licenses()`.
#' @param create_rproj If TRUE, creates an RStudio project file (.Rproj).
#'   Defaults to TRUE.
#' @param include_models If TRUE and using "basic" template, includes a
#'   '04_models' folder. Defaults to TRUE.
#' @param include_notebooks If TRUE and using "basic" template, includes a
#'   '05_notebooks' folder. Defaults to TRUE.
#' @param include_renv If TRUE, initializes renv for dependency management.
#'   Requires the renv package. Defaults to FALSE.
#' @param include_targets If TRUE, adds targets pipeline files (_targets.R and
#'   R/functions.R). Defaults to FALSE.
#' @param custom_dirs Character vector of additional directories to create.
#' @param gitignore_extras Character vector of additional patterns to add to
#'   .gitignore.
#' @param git_init If TRUE, initializes a git repository. Defaults to FALSE.
#' @param open_project If TRUE and in RStudio, opens the project after creation.
#'   Defaults to FALSE.
#' @param open_readme If TRUE, opens README.md for editing after creation.
#'   Defaults to FALSE.
#'
#' @return Invisibly returns the path to the created project directory.
#' @export
#'
#' @examples
#' \dontrun{
#' # Basic usage
#' initialize_project("MyAnalysis")
#'
#' # Use a template
#' initialize_project("MyShinyApp", template = "shiny")
#'
#' # Full featured project
#' initialize_project(
#'   "DataProject",
#'   template = "analysis",
#'   author = "Jane Doe",
#'   license = "MIT",
#'   include_renv = TRUE,
#'   git_init = TRUE
#' )
#'
#' # Minimal project with custom directories
#' initialize_project(
#'   "QuickProject",
#'   template = "minimal",
#'   custom_dirs = c("docs", "references")
#' )
#' }
initialize_project <- function(project_name,
                               path = ".",
                               template = "basic",
                               overwrite = FALSE,
                               author = NULL,
                               license = NULL,
                               create_rproj = TRUE,
                               include_models = TRUE,
                               include_notebooks = TRUE,
                               include_renv = FALSE,
                               include_targets = FALSE,
                               custom_dirs = NULL,
                               gitignore_extras = NULL,
                               git_init = FALSE,
                               open_project = FALSE,
                               open_readme = FALSE) {

  # Validate project_name
  if (!is.character(project_name) || length(project_name) != 1 ||
      nchar(trimws(project_name)) == 0) {
    stop("`project_name` must be a non-empty character string.")
  }
  project_name <- trimws(project_name)

  # Validate template
  valid_templates <- c("basic", "analysis", "shiny", "targets", "minimal")
  if (!template %in% valid_templates) {
    stop("Unknown template: '", template, "'. ",
         "Available: ", paste(valid_templates, collapse = ", "))
  }

  # Set defaults
  author <- author %||% Sys.info()[["user"]]
  date <- format(Sys.Date(), "%Y-%m-%d")

  # Construct full project path
  full_project_path <- normalizePath(file.path(path, project_name), mustWork = FALSE)

  # Check if directory exists
  if (dir.exists(full_project_path)) {
    if (overwrite) {
      message("Overwriting existing directory: ", full_project_path)
      unlink(full_project_path, recursive = TRUE, force = TRUE)
    } else {
      stop("Directory already exists: '", full_project_path, "'. ",
           "Use `overwrite = TRUE` to replace it.")
    }
  }

  # Create main project directory
  dir.create(full_project_path, recursive = TRUE, showWarnings = FALSE)
  message("Creating project: ", project_name)

  # Get template configuration
  template_config <- get_template_config(template)

  # Create directories from template
  for (dir_path in template_config$dirs) {
    dir.create(file.path(full_project_path, dir_path),
               showWarnings = FALSE, recursive = TRUE)
  }

  # Handle optional directories for basic template
  if (template == "basic") {
    if (include_models && !is.null(template_config$optional_dirs$models)) {
      dir.create(file.path(full_project_path, template_config$optional_dirs$models),
                 showWarnings = FALSE, recursive = TRUE)
    }
    if (include_notebooks && !is.null(template_config$optional_dirs$notebooks)) {
      dir.create(file.path(full_project_path, template_config$optional_dirs$notebooks),
                 showWarnings = FALSE, recursive = TRUE)
    }
  }

  # Create custom directories
  if (!is.null(custom_dirs) && length(custom_dirs) > 0) {
    for (dir_name in custom_dirs) {
      dir.create(file.path(full_project_path, dir_name),
                 showWarnings = FALSE, recursive = TRUE)
    }
    message("Created ", length(custom_dirs), " custom director",
            if (length(custom_dirs) == 1) "y" else "ies")
  }

  # Template substitutions
  substitutions <- list(
    PROJECT_NAME = project_name,
    DATE = date,
    AUTHOR = author
  )

  # Copy and process template files
  for (file_info in template_config$files) {
    src_path <- system.file("templates", file_info$src, package = "kickstartR")
    if (src_path != "" && file.exists(src_path)) {
      content <- readLines(src_path, warn = FALSE)
      content <- apply_substitutions(content, substitutions)
      dest_path <- file.path(full_project_path, file_info$dest)
      dest_dir <- dirname(dest_path)
      if (!dir.exists(dest_dir)) {
        dir.create(dest_dir, showWarnings = FALSE, recursive = TRUE)
      }
      writeLines(content, dest_path)
    }
  }

  # Add targets support if requested (and not already using targets template)
  if (include_targets && template != "targets") {
    targets_template <- system.file("templates", "targets/_targets.R", package = "kickstartR")
    functions_template <- system.file("templates", "targets/functions.R", package = "kickstartR")

    if (targets_template != "" && file.exists(targets_template)) {
      content <- readLines(targets_template, warn = FALSE)
      content <- apply_substitutions(content, substitutions)
      writeLines(content, file.path(full_project_path, "_targets.R"))
    }

    if (functions_template != "" && file.exists(functions_template)) {
      r_dir <- file.path(full_project_path, "R")
      if (!dir.exists(r_dir)) dir.create(r_dir, showWarnings = FALSE)
      content <- readLines(functions_template, warn = FALSE)
      content <- apply_substitutions(content, substitutions)
      writeLines(content, file.path(r_dir, "functions.R"))
    }

    message("Added targets pipeline support")
  }

  # Create README.md
  create_readme(full_project_path, project_name, template, author,
                include_models, include_notebooks, create_rproj,
                include_renv, include_targets || template == "targets")

  # Create .gitignore
  create_gitignore(full_project_path, template, include_renv,
                   include_targets || template == "targets", gitignore_extras)

  # Create LICENSE
  if (!is.null(license)) {
    generate_license(license, author, full_project_path)
  }

  # Create .Rproj file
  if (create_rproj) {
    create_rproj_file(full_project_path, project_name)
  }

  # Create .here file
  file.create(file.path(full_project_path, ".here"))

  # Initialize renv
  if (include_renv) {
    init_renv(full_project_path)
  }

  # Initialize git
  if (git_init) {
    init_git(full_project_path)
  }

  message("\nProject '", project_name, "' created successfully!")
  message("Location: ", full_project_path)

  # Post-creation hooks
  if (open_readme) {
    open_file_in_editor(file.path(full_project_path, "README.md"))
  }

  if (open_project && create_rproj) {
    open_rstudio_project(file.path(full_project_path, paste0(project_name, ".Rproj")))
  }

  invisible(full_project_path)
}


# Helper Functions --------------------------------------------------------

#' Create README.md
#' @keywords internal
create_readme <- function(path, project_name, template, author,
                          include_models, include_notebooks, create_rproj,
                          include_renv, include_targets) {

  content <- paste0(
    "# ", project_name, "\n\n",
    "> Created with [kickstartR](https://github.com/sidhuk/kickstartR)\n\n",
    "**Author:** ", author, "
",
    "**Created:** ", format(Sys.Date(), "%Y-%m-%d"), "\n\n",
    "## Overview\n\n",
    "Describe your project here.\n\n",
    "## Project Structure\n\n",
    "```\n",
    project_name, "/\n"
  )

  if (template == "shiny") {
    content <- paste0(content,
      "+-- app.R              # Shiny app entry point\n",
      "+-- R/\n",
      "|   +-- ui.R           # UI definition\n",
      "|   +-- server.R       # Server logic\n",
      "+-- www/               # Static assets\n",
      "|   +-- css/\n",
      "|   +-- js/\n",
      "+-- data/              # App data\n"
    )
  } else if (template == "targets") {
    content <- paste0(content,
      "+-- _targets.R         # Pipeline definition\n",
      "+-- R/\n",
      "|   +-- functions.R    # Pipeline functions\n",
      "+-- 01_data/\n",
      "|   +-- 01_raw/\n",
      "|   +-- 02_processed/\n",
      "+-- 03_output/\n"
    )
  } else if (template == "minimal") {
    content <- paste0(content,
      "+-- scripts/           # R scripts\n",
      "+-- data/              # Data files\n",
      "+-- output/            # Results\n"
    )
  } else {
    content <- paste0(content,
      "+-- 01_data/\n",
      "|   +-- 01_raw/        # Original data\n",
      "|   +-- 02_processed/  # Cleaned data\n",
      "|   +-- 03_external/   # External data\n",
      "+-- 02_scripts/        # Analysis scripts\n",
      "+-- 03_output/\n",
      "|   +-- 01_figures/\n",
      "|   +-- 02_tables/\n",
      "|   +-- 03_reports_rendered/\n"
    )
    if (include_models || template == "analysis") {
      content <- paste0(content, "+-- 04_models/         # Saved models\n")
    }
    if (include_notebooks || template == "analysis") {
      content <- paste0(content, "+-- 05_notebooks/      # RMarkdown/Quarto\n")
    }
  }

  content <- paste0(content, "```\n\n")

  if (include_targets) {
    content <- paste0(content,
      "## Pipeline\n\n",
      "This project uses [{targets}](https://docs.ropensci.org/targets/) for workflow management.\n\n",
      "```r\n",
      "# Run the pipeline\n",
      "targets::tar_make()\n\n",
      "# Visualize the pipeline\n",
      "targets::tar_visnetwork()\n",
      "```\n\n"
    )
  }

  if (include_renv) {
    content <- paste0(content,
      "## Dependencies\n\n",
      "This project uses [{renv}](https://rstudio.github.io/renv/) for dependency management.\n\n",
      "```r\n",
      "# Restore dependencies\n",
      "renv::restore()\n",
      "```\n\n"
    )
  }

  content <- paste0(content,
    "## Getting Started\n\n",
    "1. Open `", project_name, ".Rproj` in RStudio\n",
    "2. Install dependencies\n",
    "3. Start your analysis\n"
  )

  writeLines(content, file.path(path, "README.md"))
}

#' Create .gitignore
#' @keywords internal
create_gitignore <- function(path, template, include_renv, include_targets,
                             extras = NULL) {
  content <- c(
    "# R",
    ".Rproj.user",
    ".Rhistory",
    ".RData",
    ".Renviron",
    ".Rprofile.user",
    ""
  )

  if (template %in% c("basic", "analysis")) {
    content <- c(content,
      "# Output (regenerable)",
      "03_output/",
      "",
      "# Models (often large)",
      "04_models/",
      ""
    )
  }

  if (include_renv) {
    content <- c(content,
      "# renv",
      "renv/library/",
      "renv/local/",
      "renv/cellar/",
      "renv/lock/",
      "renv/python/",
      "renv/sandbox/",
      "renv/staging/",
      ""
    )
  }

  if (include_targets) {
    content <- c(content,
      "# targets",
      "_targets/",
      ""
    )
  }

  content <- c(content,
    "# OS",
    ".DS_Store",
    "Thumbs.db",
    "",
    "# Build",
    "*.tar.gz",
    "*.Rcheck/"
  )

  if (!is.null(extras) && length(extras) > 0) {
    content <- c(content, "", "# Custom", extras)
  }

  writeLines(content, file.path(path, ".gitignore"))
}

#' Create .Rproj file
#' @keywords internal
create_rproj_file <- function(path, project_name) {
  content <- c(
    "Version: 1.0",
    "",
    "RestoreWorkspace: No",
    "SaveWorkspace: No",
    "AlwaysSaveHistory: Default",
    "",
    "EnableCodeIndexing: Yes",
    "UseSpacesForTab: Yes",
    "NumSpacesForTab: 2",
    "Encoding: UTF-8",
    "",
    "RnwWeave: knitr",
    "LaTeX: pdfLaTeX",
    "",
    "AutoAppendNewline: Yes",
    "StripTrailingWhitespace: Yes"
  )
  writeLines(content, file.path(path, paste0(project_name, ".Rproj")))
}

#' Initialize renv
#' @keywords internal
init_renv <- function(path) {
  if (!requireNamespace("renv", quietly = TRUE)) {
    message("Note: 'renv' package not installed. Skipping renv initialization.")
    message("  Install with: install.packages('renv')")
    return(invisible(FALSE))
  }

  tryCatch({
    old_wd <- getwd()
    on.exit(setwd(old_wd))
    setwd(path)
    renv::init(bare = TRUE, restart = FALSE)
    message("Initialized renv")
    invisible(TRUE)
  }, error = function(e) {
    message("Note: Could not initialize renv: ", e$message)
    invisible(FALSE)
  })
}

#' Initialize git repository
#' @keywords internal
init_git <- function(path) {
  result <- tryCatch({
    system2("git", c("init", path), stdout = FALSE, stderr = FALSE)
  }, error = function(e) 1)

  if (result == 0) {
    message("Initialized git repository")
  } else {
    message("Note: Could not initialize git. Is git installed?")
  }
  invisible(result == 0)
}

#' Open file in editor
#' @keywords internal
open_file_in_editor <- function(file_path) {
  if (!interactive()) return(invisible(FALSE))

  if (requireNamespace("rstudioapi", quietly = TRUE) &&
      rstudioapi::isAvailable()) {
    rstudioapi::navigateToFile(file_path)
  } else {
    tryCatch(utils::file.edit(file_path), error = function(e) NULL)
  }
  invisible(TRUE)
}

#' Open RStudio project
#' @keywords internal
open_rstudio_project <- function(rproj_path) {
  if (!interactive()) return(invisible(FALSE))

  if (requireNamespace("rstudioapi", quietly = TRUE) &&
      rstudioapi::isAvailable()) {
    rstudioapi::openProject(rproj_path, newSession = TRUE)
    invisible(TRUE)
  } else {
    message("Tip: Open '", rproj_path, "' in RStudio to get started.")
    invisible(FALSE)
  }
}

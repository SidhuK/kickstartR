# Hello, world!
#
# This is an example function named 'hello'
# which prints 'Hello, world!'.
#
# You can learn more about package authoring with RStudio at:
#
#   https://r-pkgs.org
#
# Some useful keyboard shortcuts for package authoring:
#
#   Install Package:           'Cmd + Shift + B'
#   Check Package:             'Cmd + Shift + E'
#   Test Package:              'Cmd + Shift + T'

#' Initialize a New Project with Boilerplate Structure
#'
#' This function creates a standard directory structure for a new R project.
#'
#' @param project_name The name of the project. This will be the name of the main project directory.
#' @param path The path where the project directory should be created. Defaults to the current working directory.
#' @param overwrite Logical, if TRUE, and a directory with `project_name` already exists, it will be overwritten (use with caution). Defaults to FALSE.
#' @param create_rproj Logical, if TRUE, creates an RStudio project file (.Rproj). Defaults to TRUE.
#' @param include_models Logical, if TRUE, includes a 'models' folder. Defaults to TRUE.
#' @param include_notebooks Logical, if TRUE, includes a 'notebooks' or 'reports' folder. Defaults to TRUE.
#'
#' @return Invisibly returns the path to the created project directory.
#' @export
#' @examples
#' \dontrun{
#' # Create a project named "MyAnalysis" in the current directory
#' # initialize_project("MyAnalysis")
#'
#' # Create a project in a specific path
#' # temp_dir <- tempdir()
#' # initialize_project("MyTestProject", path = temp_dir)
#' # unlink(file.path(temp_dir, "MyTestProject"), recursive = TRUE) # Clean up
#' }
initialize_project <- function(project_name,
                               path = ".",
                               overwrite = FALSE,
                               create_rproj = TRUE,
                               include_models = TRUE,
                               include_notebooks = TRUE) {
  # 1. Validate project_name (basic check)
  if (!is.character(project_name) || length(project_name) != 1 || nchar(trimws(project_name)) == 0) {
    stop("`project_name` must be a non-empty character string.")
  }
  project_name <- trimws(project_name)

  # 2. Construct full project path
  full_project_path <- file.path(path, project_name)

  # 3. Check if directory exists
  if (dir.exists(full_project_path)) {
    if (overwrite) {
      message("Project directory '", full_project_path, "' already exists. Overwriting as requested.")
      unlink(full_project_path, recursive = TRUE, force = TRUE)
    } else {
      stop("Project directory '", full_project_path, "' already exists. Use `overwrite = TRUE` to replace it.")
    }
  }

  # 4. Create the main project directory
  dir.create(full_project_path, recursive = TRUE, showWarnings = FALSE)
  message("Created project directory: ", full_project_path)

  # 5. Define the directory structure
  #    You can make this more complex or configurable
  dirs_to_create <- c(
    "01_data",
    "01_data/01_raw",
    "01_data/02_processed",
    "01_data/03_external", # Or whatever you prefer
    "02_scripts", # Or 'R', 'src', 'code'
    "03_output",
    "03_output/01_figures",
    "03_output/02_tables",
    "03_output/03_reports_rendered" # If you have reports/notebooks
  )

  if (include_models) {
    dirs_to_create <- c(dirs_to_create, "04_models")
  }
  if (include_notebooks) {
    dirs_to_create <- c(dirs_to_create, "05_notebooks") # Or 'reports', 'analysis'
  }

  # 6. Create the subdirectories
  for (dir_path_segment in dirs_to_create) {
    dir.create(file.path(full_project_path, dir_path_segment), showWarnings = FALSE, recursive = TRUE)
  }
  message("Created subdirectories.")

  # 7. Create placeholder files (optional, but good practice)
  # README.md
  readme_content <- paste0(
    "# ", project_name, "\n\n",
    "This is the main directory for the '", project_name, "' project.\n\n",
    "## Project Structure\n\n",
    "- `/01_data`: Contains all data.\n",
    "  - `/01_data/01_raw`: Original, immutable data dump.\n",
    "  - `/01_data/02_processed`: Intermediate, cleaned, or transformed data.\n",
    "  - `/01_data/03_external`: Data from external sources.\n",
    "- `/02_scripts`: Source code for analysis, modeling, etc. (R scripts, Python scripts).\n",
    "- `/03_output`: All outputs from scripts and analyses.\n",
    "  - `/03_output/01_figures`: Generated plots and figures.\n",
    "  - `/03_output/02_tables`: Generated tables (e.g., CSVs for reports).\n",
    "  - `/03_output/03_reports_rendered`: Rendered reports (HTML, PDF) from notebooks/RMarkdown.\n"
  )
  if (include_models) {
    readme_content <- paste0(readme_content, "- `/04_models`: Saved model objects, model summaries, etc.\n")
  }
  if (include_notebooks) {
    readme_content <- paste0(readme_content, "- `/05_notebooks`: R Markdown files, Jupyter notebooks, Quarto documents for exploratory analysis and reporting.\n")
  }
  readme_content <- paste0(readme_content, "- `README.md`: This file - project overview and instructions.\n")
  if (create_rproj) {
    readme_content <- paste0(readme_content, "- `", project_name, ".Rproj`: RStudio Project file.\n")
  }

  writeLines(readme_content, file.path(full_project_path, "README.md"))
  message("Created README.md")

  # .gitignore
  gitignore_content <- c(
    "# R specific",
    ".Rproj.user",
    ".Rhistory",
    ".RData",
    ".Renviron",
    ".Rprofile.user",
    "",
    "# Output files",
    "03_output/",
    "*.html", # If notebooks are outside output
    "*.pdf", # If notebooks are outside output
    "",
    "# Data (if large or sensitive, otherwise consider versioning small data)",
    "# 01_data/01_raw/", # Uncomment if raw data is too large or sensitive
    "# 01_data/02_processed/",
    "",
    "# Models (often large)",
    "04_models/",
    "",
    "# Package specific (if you build packages within the project)",
    "/*.tar.gz",
    "/*.Rcheck/",
    "*.so",
    "*.dll",
    "",
    "# OS specific",
    ".DS_Store",
    "Thumbs.db"
  )
  writeLines(gitignore_content, file.path(full_project_path, ".gitignore"))
  message("Created .gitignore")

  # Placeholder script in 02_scripts
  main_script_content <- c(
    "# Main analysis script for ", project_name,
    "",
    "# Load libraries",
    "# library(tidyverse)",
    "# library(here)", # Consider recommending 'here' package
    "",
    "# Set base directory using here (if you decide to use it)",
    "# here::i_am(\"02_scripts/00_main_script.R\") # Adjust if script name/location changes",
    "",
    "# Load data",
    "# raw_data <- read.csv(here::here(\"01_data\", \"01_raw\", \"your_raw_data.csv\"))",
    "",
    "# Process data",
    "# ...",
    "",
    "# Save processed data",
    "# write.csv(processed_data, here::here(\"01_data\", \"02_processed\", \"processed_data.csv\"), row.names = FALSE)",
    "",
    "# Analysis / Modeling",
    "# ...",
    "",
    "# Save outputs (figures, tables)",
    "# ggsave(here::here(\"03_output\", \"01_figures\", \"my_plot.png\"), my_plot)",
    "",
    "message(\"Main script for ", project_name, " executed (placeholder).\")"
  )
  writeLines(main_script_content, file.path(full_project_path, "02_scripts", "00_main_script.R"))
  message("Created placeholder script in 02_scripts/00_main_script.R")

  # RStudio Project File (.Rproj)
  if (create_rproj) {
    rproj_content <- c(
      "Version: 1.0",
      "",
      "RestoreWorkspace: Default",
      "SaveWorkspace: Default",
      "AlwaysSaveHistory: Default",
      "",
      "EnableCodeIndexing: Yes",
      "UseSpacesForTab: Yes",
      "NumSpacesForTab: 2",
      "Encoding: UTF-8",
      "",
      "RnwWeave: Sweave",
      "LaTeX: pdfLaTeX"
    )
    writeLines(rproj_content, file.path(full_project_path, paste0(project_name, ".Rproj")))
    message("Created .Rproj file.")
  }

  # Add a .here file to make the project root identifiable by the 'here' package
  # This is highly recommended for robust path management.
  # You might need to add `usethis::use_package("here")` to your DESCRIPTION if you use it
  # directly, but just creating the file doesn't require a dependency.
  file.create(file.path(full_project_path, ".here"))
  message("Created .here file for use with the 'here' package.")


  message("\nProject '", project_name, "' initialized successfully at '", full_project_path, "'.")
  message("Consider opening the .Rproj file in RStudio to get started.")

  invisible(full_project_path)
}

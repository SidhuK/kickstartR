#' Initialize Project Interactively
#'
#' Launches an interactive wizard that guides users through project setup
#' with prompts for all configuration options.
#'
#' @return Invisibly returns the path to the created project, or NULL if cancelled.
#' @export
#' @examples
#' \dontrun{
#' # Launch the interactive wizard
#' initialize_project_interactive()
#' }
initialize_project_interactive <- function() {
  if (!interactive()) {
    stop("Interactive wizard requires an interactive R session.")
  }

  cat("\n")
  cat("
 _    _      _        _             _   ____  
| | _(_) ___| | _____| |_ __ _ _ __| |_|  _ \\ 
| |/ / |/ __| |/ / __| __/ _` | '__| __| |_) |
|   <| | (__|   <\\__ \\ || (_| | |  | |_|  _ < 
|_|\\_\\_|\\___|_|\\_\\___/\\__\\__,_|_|   \\__|_| \\_\\
")
  cat("\n")
  cat("=== Project Setup Wizard ===\n\n")

  # Project name
  project_name <- readline("Project name: ")
  if (nchar(trimws(project_name)) == 0) {
    message("Cancelled: Project name cannot be empty.")
    return(invisible(NULL))
  }
  project_name <- trimws(project_name)

  # Path
  cat("\nWhere should the project be created?\n")
  cat("  [Press Enter for current directory: ", getwd(), "]\n", sep = "")
  path_input <- readline("Path: ")
  path <- if (nchar(trimws(path_input)) == 0) "." else trimws(path_input)

  # Template selection
  cat("\n--- Template Selection ---\n")
  cat("  1. basic    - Standard data analysis structure\n")
  cat("  2. analysis - Full project with models & notebooks\n")
  cat("  3. shiny    - Shiny web application\n")
  cat("  4. targets  - Pipeline-based workflow\n")
  cat("  5. minimal  - Bare minimum structure\n")
  template_choice <- readline("Select template [1-5, default=1]: ")
  template <- switch(
    trimws(template_choice),
    "2" = "analysis",
    "3" = "shiny",
    "4" = "targets",
    "5" = "minimal",
    "basic"
  )

  # Author
  cat("\n--- Project Metadata ---\n")
  default_author <- Sys.info()[["user"]]
  author_input <- readline(paste0("Author name [", default_author, "]: "))
  author <- if (nchar(trimws(author_input)) == 0) default_author else trimws(author_input)

  # License
  cat("License options: ", paste(available_licenses(), collapse = ", "), ", none\n", sep = "")
  license_input <- readline("License [default=MIT]: ")
  license <- if (nchar(trimws(license_input)) == 0) {
    "MIT"
  } else if (tolower(trimws(license_input)) == "none") {
    NULL
  } else {
    trimws(license_input)
  }

  # Features
  cat("\n--- Optional Features ---\n")

  # renv
  renv_input <- tolower(readline("Initialize renv for dependency management? [y/N]: "))
  include_renv <- renv_input %in% c("y", "yes")

  # targets (only if not already using targets template)
  include_targets <- FALSE
  if (template != "targets") {
    targets_input <- tolower(readline("Add targets pipeline support? [y/N]: "))
    include_targets <- targets_input %in% c("y", "yes")
  }

  # Git
  git_input <- tolower(readline("Initialize git repository? [y/N]: "))
  git_init <- git_input %in% c("y", "yes")

  # RStudio project
  rproj_input <- tolower(readline("Create .Rproj file? [Y/n]: "))
  create_rproj <- !(rproj_input %in% c("n", "no"))

  # Open after creation
  open_input <- tolower(readline("Open project in RStudio after creation? [y/N]: "))
  open_project <- open_input %in% c("y", "yes")

  # Summary
  cat("\n")
  cat(paste(rep("=", 40), collapse = ""), "\n")
  cat("           PROJECT SUMMARY\n")
  cat(paste(rep("=", 40), collapse = ""), "\n")
  cat("  Name:       ", project_name, "\n")
  cat("  Location:   ", normalizePath(file.path(path, project_name), mustWork = FALSE), "\n")
  cat("  Template:   ", template, "\n")
  cat("  Author:     ", author, "\n")
  cat("  License:    ", if (is.null(license)) "None" else license, "\n")
  cat("  renv:       ", if (include_renv) "Yes" else "No", "\n")
  cat("  targets:    ", if (include_targets || template == "targets") "Yes" else "No", "\n")
  cat("  Git:        ", if (git_init) "Yes" else "No", "\n")
  cat("  .Rproj:     ", if (create_rproj) "Yes" else "No", "\n")
  cat(paste(rep("=", 40), collapse = ""), "\n\n")

  confirm <- tolower(readline("Create this project? [Y/n]: "))
  if (confirm %in% c("n", "no")) {
    message("\nProject creation cancelled.")
    return(invisible(NULL))
  }

  cat("\n")

  # Create the project
  result <- initialize_project(
    project_name = project_name,
    path = path,
    template = template,
    author = author,
    license = license,
    include_renv = include_renv,
    include_targets = include_targets,
    create_rproj = create_rproj,
    git_init = git_init,
    open_project = open_project
  )

  cat("\n")
  cat(paste(rep("*", 50), collapse = ""), "\n")
  cat("  Project created successfully!\n")
  cat(paste(rep("*", 50), collapse = ""), "\n")

  invisible(result)
}

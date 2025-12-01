#' Get Template Configuration
#'
#' Returns the directory structure and file configuration for a given template.
#'
#' @param template Character. Template name: "basic", "analysis", "shiny", "targets", or "minimal".
#' @return List with template configuration including dirs, optional_dirs, and files.
#' @keywords internal
get_template_config <- function(template = "basic") {
  templates <- list(
    basic = list(
      dirs = c(
        "01_data/01_raw",
        "01_data/02_processed",
        "01_data/03_external",
        "02_scripts",
        "03_output/01_figures",
        "03_output/02_tables",
        "03_output/03_reports_rendered"
      ),
      optional_dirs = list(
        models = "04_models",
        notebooks = "05_notebooks"
      ),
      files = list(
        main_script = list(src = "main_script_template.R", dest = "02_scripts/00_main_script.R")
      ),
      description = "Standard project structure for data analysis"
    ),

    analysis = list(
      dirs = c(
        "01_data/01_raw",
        "01_data/02_processed",
        "01_data/03_external",
        "02_scripts",
        "03_output/01_figures",
        "03_output/02_tables",
        "03_output/03_reports_rendered",
        "04_models",
        "05_notebooks"
      ),
      optional_dirs = list(),
      files = list(
        main_script = list(src = "main_script_template.R", dest = "02_scripts/00_main_script.R")
      ),
      description = "Full data analysis project with models and notebooks"
    ),

    shiny = list(
      dirs = c(
        "R",
        "www",
        "www/css",
        "www/js",
        "data"
      ),
      optional_dirs = list(),
      files = list(
        app = list(src = "shiny/app.R", dest = "app.R"),
        ui = list(src = "shiny/ui.R", dest = "R/ui.R"),
        server = list(src = "shiny/server.R", dest = "R/server.R"),
        css = list(src = "shiny/styles.css", dest = "www/css/styles.css")
      ),
      description = "Shiny web application structure"
    ),

    targets = list(
      dirs = c(
        "R",
        "01_data/01_raw",
        "01_data/02_processed",
        "03_output/01_figures",
        "03_output/02_tables"
      ),
      optional_dirs = list(),
      files = list(
        targets = list(src = "targets/_targets.R", dest = "_targets.R"),
        functions = list(src = "targets/functions.R", dest = "R/functions.R")
      ),
      description = "Pipeline-based workflow using {targets}"
    ),

    minimal = list(
      dirs = c(
        "scripts",
        "data",
        "output"
      ),
      optional_dirs = list(),
      files = list(
        main_script = list(src = "minimal/main.R", dest = "scripts/main.R")
      ),
      description = "Bare minimum project structure"
    )
  )

  if (!template %in% names(templates)) {
    stop(
      "Unknown template: '", template, "'. ",
      "Available templates: ", paste(names(templates), collapse = ", ")
    )
  }

  templates[[template]]
}

#' List Available Templates
#'
#' Returns information about available project templates.
#'
#' @param verbose If TRUE, prints detailed descriptions. Default is FALSE.
#' @return Character vector of available template names (invisibly if verbose).
#' @export
#' @examples
#' available_templates()
#' available_templates(verbose = TRUE)
available_templates <- function(verbose = FALSE) {
  templates <- c("basic", "analysis", "shiny", "targets", "minimal")

  if (verbose) {
    cat("\nAvailable kickstartR Templates:\n")
    cat(paste(rep("-", 50), collapse = ""), "\n\n")

    descriptions <- list(
      basic = "Standard project structure for data analysis\n        Includes: data, scripts, output folders",
      analysis = "Full data analysis project with models and notebooks\n        Includes: all basic folders + models + notebooks",
      shiny = "Shiny web application structure\n        Includes: R/, www/, data/ for Shiny apps",
      targets = "Pipeline-based workflow using {targets}\n        Includes: R/, _targets.R, data, output folders",
      minimal = "Bare minimum project structure\n        Includes: scripts, data, output only"
    )

    for (name in templates) {
      cat("  ", name, "\n")
      cat("        ", descriptions[[name]], "\n\n")
    }

    invisible(templates)
  } else {
    templates
  }
}

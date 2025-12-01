# kickstartR v0.2 Development Plan

## Overview

This document outlines the implementation plan for kickstartR v0.2, adding 7 major features plus quick wins to enhance project scaffolding capabilities.

---

## Feature 1: `renv` Integration

### Description
Automatically initialize `renv` for reproducible dependency management.

### New Parameter
```r
initialize_project(..., include_renv = FALSE)
```

### Implementation

**File: `R/initialize_project.R`**

```r
# Add to initialize_project() function:

if (include_renv) {

  # Check if renv is available

  if (!requireNamespace("renv", quietly = TRUE)) {
    message("Note: 'renv' package not installed. Skipping renv initialization.")
    message("Install with: install.packages('renv')")
  } else {
    # Initialize renv in the new project
    renv::init(project = full_project_path, bare = TRUE)
    message("Initialized renv for dependency management.")
  }
  

  # Add renv entries to .gitignore
  renv_gitignore <- c(
    "",
    "# renv",
    "renv/library/",
    "renv/local/",
    "renv/cellar/",
    "renv/lock/",
    "renv/python/",
    "renv/sandbox/",
    "renv/staging/"
  )
  # Append to existing .gitignore
}
```

### Files Created
- `renv/` directory structure
- `renv.lock` (empty/minimal)
- `.Rprofile` with `source("renv/activate.R")`
- `renv/activate.R`
- `renv/settings.json`

### DESCRIPTION Update
```
Suggests:
    renv
```

---

## Feature 2: Project Templates/Flavors

### Description
Preset project configurations for common use cases.

### New Parameter
```r
initialize_project(..., template = "basic")
```

### Available Templates

| Template | Description | Folders | Special Files |
|----------|-------------|---------|---------------|
| `"basic"` | Current default | data, scripts, output | main_script.R |
| `"analysis"` | Data analysis | + notebooks, models | analysis_template.R |
| `"shiny"` | Shiny application | + www, modules | app.R, ui.R, server.R |
| `"targets"` | Pipeline workflow | + R/ | _targets.R, functions.R |
| `"minimal"` | Bare minimum | scripts only | main_script.R |

### Implementation

**File: `R/templates.R`** (new file)

```r
#' Get Template Configuration
#' @param template Character. Template name.
#' @return List with template configuration
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
        main_script = "02_scripts/00_main_script.R"
      )
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
        app = "app.R",
        ui = "R/ui.R",
        server = "R/server.R"
      )
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
        targets = "_targets.R",
        functions = "R/functions.R"
      )
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
        main_script = "02_scripts/00_main_script.R",
        eda = "05_notebooks/01_eda.Rmd"
      )
    ),
    
    minimal = list(
      dirs = c("scripts", "data", "output"),
      optional_dirs = list(),
      files = list(
        main_script = "scripts/main.R"
      )
    )
  )
  
  if (!template %in% names(templates)) {
    stop("Unknown template: ", template, 
         ". Available: ", paste(names(templates), collapse = ", "))
  }
  
  templates[[template]]
}
```

### Template Files

**File: `inst/templates/shiny/app.R`**
```r
# {{PROJECT_NAME}} Shiny Application
# Created: {{DATE}}

library(shiny)

source("R/ui.R")
source("R/server.R")

shinyApp(ui = ui, server = server)
```

**File: `inst/templates/shiny/ui.R`**
```r
# UI definition for {{PROJECT_NAME}}

ui <- fluidPage(

  titlePanel("{{PROJECT_NAME}}"),
  

  sidebarLayout(
    sidebarPanel(
      # Add inputs here
    ),
    mainPanel(
      # Add outputs here
    )
  )
)
```

**File: `inst/templates/shiny/server.R`**
```r
# Server logic for {{PROJECT_NAME}}

server <- function(input, output, session) {
  # Add server logic here
}
```

---

## Feature 3: Interactive Project Wizard

### Description
Guided interactive mode for project creation.

### New Function

**File: `R/wizard.R`** (new file)

```r
#' Initialize Project Interactively
#'
#' Launches an interactive wizard to guide users through project setup.
#'
#' @return Invisibly returns the path to the created project.
#' @export
#' @examples
#' \dontrun{
#' initialize_project_interactive()
#' }
initialize_project_interactive <- function() {
  

  cat("\n")
  cat("=== kickstartR Project Wizard ===\n")
  cat("\n")
  

  # Project name
  project_name <- readline("Project name: ")
  if (nchar(trimws(project_name)) == 0) {
    stop("Project name cannot be empty.")
  }
  

  # Path
  cat("Where should the project be created?\n")
  cat("  Press Enter for current directory (", getwd(), ")\n", sep = "")
  path_input <- readline("Path: ")
  path <- if (nchar(trimws(path_input)) == 0) "." else path_input
  
  # Template selection
  cat("\nAvailable templates:\n")
  cat("  1. basic    - Standard project structure\n")
  cat("  2. analysis - Data analysis with notebooks\n
")
  cat("  3. shiny    - Shiny application\n")
  cat("  4. targets  - Pipeline-based workflow\n")
  cat("  5. minimal  - Bare minimum structure\n")
  template_choice <- readline("Select template [1-5, default=1]: ")
  template <- switch(
    template_choice,
    "2" = "analysis",
    "3" = "shiny",
    "4" = "targets",
    "5" = "minimal",
    "basic"
  )
  
  # Author
  author <- readline("Author name (optional): ")
  
  # License
  cat("\nLicense options: MIT, GPL-3, CC-BY-4.0, none\n")
  license <- readline("License [default=MIT]: ")
  if (nchar(trimws(license)) == 0) license <- "MIT"
  
  # renv
  use_renv <- tolower(readline("Initialize renv? [y/N]: "))
  include_renv <- use_renv %in% c("y", "yes")
  
  # RStudio project
  use_rproj <- tolower(readline("Create .Rproj file? [Y/n]: "))
  create_rproj <- !(use_rproj %in% c("n", "no"))
  
  # Confirm
  cat("\n=== Summary ===\n")
  cat("Project:  ", project_name, "\n")
  cat("Path:     ", file.path(path, project_name), "\n")
  cat("Template: ", template, "\n")
  cat("Author:   ", if (nchar(author) > 0) author else "(not set)", "\n")
  cat("License:  ", license, "\n")
  cat("renv:     ", if (include_renv) "Yes" else "No", "\n")
  cat(".Rproj:   ", if (create_rproj) "Yes" else "No", "\n")
  
  confirm <- tolower(readline("\nCreate project? [Y/n]: "))
  if (confirm %in% c("n", "no")) {
    message("Project creation cancelled.")
    return(invisible(NULL))
  }
  
  # Create the project
  initialize_project(
    project_name = project_name,
    path = path,
    template = template,
    author = if (nchar(author) > 0) author else NULL,
    license = if (license != "none") license else NULL,
    include_renv = include_renv,
    create_rproj = create_rproj,
    open_project = TRUE
  )
}
```

---

## Feature 4: Config File Support

### Description
Read default settings from `.kickstartR.yml` in user home or project directory.
### Config File Location Priority
1. `./.kickstartR.yml` (current directory)
2. `~/.kickstartR.yml` (user home)
3. Built-in defaults

### Config File Format

```yaml
# ~/.kickstartR.yml
defaults:
  template: analysis
  include_renv: true
  include_models: true
  include_notebooks: true
  create_rproj: true
  license: MIT
  
author:
  name: "Your Name"
  email: "you@example.com"

custom_dirs:
  - "06_archive"
  - "07_references"
```

### Implementation

**File: `R/config.R`** (new file)

```r
#' Load kickstartR Configuration
#' 
#' @return List of configuration options
#' @keywords internal
load_config <- function() {
  # Default configuration

  defaults <- list(
    template = "basic",
    include_renv = FALSE,
    include_models = TRUE,
    include_notebooks = TRUE,
    create_rproj = TRUE,
    license = NULL,
    author = NULL,
    custom_dirs = NULL
  )
  
  # Look for config files
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
  
  # Parse YAML (requires yaml package)
  if (!requireNamespace("yaml", quietly = TRUE)) {
    message("Note: 'yaml' package not installed. Using default config.")
    return(defaults)
  }
  
  user_config <- yaml::read_yaml(config_file)
  message("Loaded config from: ", config_file)
  
  # Merge user config with defaults
  if (!is.null(user_config$defaults)) {
    for (name in names(user_config$defaults)) {
      if (name %in% names(defaults)) {
        defaults[[name]] <- user_config$defaults[[name]]
      }
    }
  }
  
  if (!is.null(user_config$author)) {
    defaults$author <- user_config$author$name
  }
  
  if (!is.null(user_config$custom_dirs)) {
    defaults$custom_dirs <- user_config$custom_dirs
  }
  
  defaults
}

#' Create Default Config File
#'
#' @param path Where to create the config file
#' @param global If TRUE, creates in home directory
#' @export
create_config <- function(path = ".", global = FALSE) {
  config_content <- c(
    "# kickstartR Configuration",
    "# See: https://github.com/sidhuk/kickstartR",
    "",
    "defaults:",
    "  template: basic",
    "  include_renv: false",
    "  include_models: true",
    "  include_notebooks: true",
    "  create_rproj: true",
    "  license: MIT",
    "",
    "author:",
    "  name: \"Your Name\"",
    "  email: \"you@example.com\"",
    "",
    "# custom_dirs:",
    "#   - \"06_archive\"",
    "#   - \"07_references\""
  )
  
  dest <- if (global) {
    file.path(Sys.getenv("HOME"), ".kickstartR.yml")
  } else {
    file.path(path, ".kickstartR.yml")
  }
  
  writeLines(config_content, dest)
  message("Created config file: ", dest)
  invisible(dest)
}
```

### DESCRIPTION Update
```
Suggests:
    yaml
```

---

## Feature 5: `targets` Pipeline Integration

### Description
Set up a `targets` pipeline-based workflow.

### New Parameter
```r
initialize_project(..., include_targets = FALSE)
```

### Implementation

```r
# Add to initialize_project():

if (include_targets) {
  # Create _targets.R
  targets_content <- read_template("targets_template.R")
  targets_content <- gsub("\\{\\{PROJECT_NAME\\}\\}", project_name, targets_content)
  writeLines(targets_content, file.path(full_project_path, "_targets.R"))
  
  # Create R/functions.R
  dir.create(file.path(full_project_path, "R"), showWarnings = FALSE)
  functions_content <- read_template("functions_template.R")
  writeLines(functions_content, file.path(full_project_path, "R", "functions.R"))
  
  # Add to .gitignore
  targets_gitignore <- c(
    "",
    "# targets",
    "_targets/",
    "_targets.yaml"
  )
  
  message("Created targets pipeline structure.")
}
```

### Template Files

**File: `inst/templates/targets_template.R`**

```r
# _targets.R for {{PROJECT_NAME}}
# Created: {{DATE}}
# 
# This is the main targets pipeline file.
# Run tar_make() to execute the pipeline.
# Run tar_visnetwork() to visualize the pipeline.

library(targets)

# Set target options
tar_option_set(
  packages = c("tidyverse"),  # Add packages used by targets
  format = "rds"              # Default storage format
)

# Source functions
source("R/functions.R")

# Define pipeline
list(
  # Load raw data
  tar_target(
    raw_data_file,
    "01_data/01_raw/data.csv",
    format = "file"
  ),
  
  tar_target(
    raw_data,
    read_csv(raw_data_file)
  ),
  
  # Process data
  tar_target(
    processed_data,
    process_data(raw_data)
  ),
  
  # Analysis
  tar_target(
    model,
    fit_model(processed_data)
  ),
  
  # Output
  tar_target(
    results_table,
    create_results_table(model),
    format = "rds"
  )
)
```

**File: `inst/templates/functions_template.R`**

```r
# R/functions.R
# Pipeline functions for {{PROJECT_NAME}}
# 
# Define reusable functions for your targets pipeline here.

#' Process Raw Data
#' @param data Raw data frame
#' @return Processed data frame
process_data <- function(data) {
  # Add data processing steps
  data
}

#' Fit Model
#' @param data Processed data frame
#' @return Fitted model object
fit_model <- function(data) {
  # Add modeling code
  # Example: lm(y ~ x, data = data)
  NULL
}

#' Create Results Table
#' @param model Fitted model
#' @return Data frame with results
create_results_table <- function(model) {
  # Summarize model results
  data.frame(result = "placeholder")
}
```

### DESCRIPTION Update
```
Suggests:
    targets
```

---

## Feature 6: License File Generator

### Description
Auto-generate LICENSE file based on selected license type.

### New Parameter
```r
initialize_project(..., license = NULL, author = NULL)
```

### Implementation

**File: `R/licenses.R`** (new file)

```r
#' Generate License File
#' @param license License type ("MIT", "GPL-3", "GPL-2", "CC-BY-4.0", "CC0")
#' @param author Author name for license
#' @param path Project path
#' @keywords internal
generate_license <- function(license, author = NULL, path) {
  if (is.null(license)) return(invisible(NULL))
  
  year <- format(Sys.Date(), "%Y")
  author <- author %||% Sys.info()["user"]
  
  license_text <- switch(
    toupper(license),
    
    "MIT" = paste0(
      "MIT License\n\n",
      "Copyright (c) ", year, " ", author, "\n\n",
      "Permission is hereby granted, free of charge, to any person obtaining a copy\n",
      "of this software and associated documentation files (the \"Software\"), to deal\n",
      "in the Software without restriction, including without limitation the rights\n",
      "to use, copy, modify, merge, publish, distribute, sublicense, and/or sell\n",
      "copies of the Software, and to permit persons to whom the Software is\n",
      "furnished to do so, subject to the following conditions:\n\n",
      "The above copyright notice and this permission notice shall be included in all\n",
      "copies or substantial portions of the Software.\n\n",
      "THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR\n",
      "IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,\n",
      "FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE\n",
      "AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER\n",
      "LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,\n",
      "OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE\n",
      "SOFTWARE.\n"
    ),
    
    "GPL-3" = paste0(
      "Copyright (c) ", year, " ", author, "\n\n",
      "This program is free software: you can redistribute it and/or modify\n",
      "it under the terms of the GNU General Public License as published by\n",
      "the Free Software Foundation, either version 3 of the License, or\n",
      "(at your option) any later version.\n\n",
      "This program is distributed in the hope that it will be useful,\n",
      "but WITHOUT ANY WARRANTY; without even the implied warranty of\n",
      "MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the\n",
      "GNU General Public License for more details.\n\n",
      "You should have received a copy of the GNU General Public License\n",
      "along with this program. If not, see <https://www.gnu.org/licenses/>.\n"
    ),
    
    "GPL-2" = paste0(
      "Copyright (c) ", year, " ", author, "\n\n",
      "This program is free software; you can redistribute it and/or modify\n",
      "it under the terms of the GNU General Public License as published by\n",
      "the Free Software Foundation; either version 2 of the License, or\n",
      "(at your option) any later version.\n\n",
      "This program is distributed in the hope that it will be useful,\n",
      "but WITHOUT ANY WARRANTY; without even the implied warranty of\n",
      "MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the\n",
      "GNU General Public License for more details.\n"
    ),
    
    "CC-BY-4.0" = paste0(
      "Creative Commons Attribution 4.0 International License\n\n",
      "Copyright (c) ", year, " ", author, "\n\n",
      "This work is licensed under the Creative Commons Attribution 4.0\n",
      "International License. To view a copy of this license, visit\n",
      "http://creativecommons.org/licenses/by/4.0/ or send a letter to\n",
      "Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.\n"
    ),
    
    "CC0" = paste0(
      "CC0 1.0 Universal\n\n",
      "The person who associated a work with this deed has dedicated the work\n",
      "to the public domain by waiving all of his or her rights to the work\n",
      "worldwide under copyright law, including all related and neighboring\n",
      "rights, to the extent allowed by law.\n\n",
      "You can copy, modify, distribute and perform the work, even for\n",
      "commercial purposes, all without asking permission.\n"
    ),
    
    # Default: unknown license
    {
      warning("Unknown license: ", license, ". Skipping license file.")
      return(invisible(NULL))
    }
  )
  
  writeLines(license_text, file.path(path, "LICENSE"))
  message("Created LICENSE file (", license, ")")
  invisible(license_text)
}

#' List Available Licenses
#' @return Character vector of available license identifiers
#' @export
available_licenses <- function() {
  c("MIT", "GPL-3", "GPL-2", "CC-BY-4.0", "CC0")
}
```

---

## Feature 7: Post-Creation Hooks

### Description
Automatic actions after project creation.

### New Parameters
```r
initialize_project(
  ...,
  open_project = FALSE,   # Open in RStudio
  open_readme = FALSE,    # Open README for editing
  git_init = FALSE        # Initialize git repo
)
```

### Implementation

```r
# Add at end of initialize_project():

# Post-creation hooks
if (git_init) {
  tryCatch({
    system2("git", c("init", full_project_path), stdout = FALSE, stderr = FALSE)
    message("Initialized git repository.")
  }, error = function(e) {
    message("Note: Could not initialize git. Is git installed?")
  })
}

if (open_readme) {
  readme_path <- file.path(full_project_path, "README.md")
  if (interactive() && requireNamespace("rstudioapi", quietly = TRUE)) {
    if (rstudioapi::isAvailable()) {
      rstudioapi::navigateToFile(readme_path)
    }
  } else {
    utils::file.edit(readme_path)
  }
}

if (open_project && create_rproj) {
  rproj_path <- file.path(full_project_path, paste0(project_name, ".Rproj"))
  if (interactive() && requireNamespace("rstudioapi", quietly = TRUE)) {
    if (rstudioapi::isAvailable()) {
      rstudioapi::openProject(rproj_path, newSession = TRUE)
    }
  }
}
```

### DESCRIPTION Update
```
Suggests:
    rstudioapi
```

---

## Quick Wins

### Additional Parameters for `initialize_project()`

```r
initialize_project <- function(
  project_name,
  path = ".",
  overwrite = FALSE,
  

  # Existing
  create_rproj = TRUE,
  include_models = TRUE,
  include_notebooks = TRUE,
  
  # NEW: Template system

  template = NULL,
  
  # NEW: Metadata
  author = NULL,
  date = Sys.Date(),
  
  # NEW: Integrations
  include_renv = FALSE,
  include_targets = FALSE,
  license = NULL,
  
  # NEW: Custom structure
  custom_dirs = NULL,
  gitignore_extras = NULL,
  
  # NEW: Post-creation
  open_project = FALSE,
  open_readme = FALSE,
  git_init = FALSE
)
```

### Custom Directories

```r
# Support for additional custom directories
if (!is.null(custom_dirs)) {
  for (dir_name in custom_dirs) {
    dir.create(file.path(full_project_path, dir_name), 
               showWarnings = FALSE, recursive = TRUE)
  }
  message("Created ", length(custom_dirs), " custom directories.")
}
```

### Extra .gitignore Patterns

```r
# Support for additional .gitignore patterns
if (!is.null(gitignore_extras)) {
  cat("\n# Custom patterns\n", file = file.path(full_project_path, ".gitignore"), append = TRUE)
  cat(paste(gitignore_extras, collapse = "\n"), 
      file = file.path(full_project_path, ".gitignore"), append = TRUE)
}
```

---

## File Structure After v0.2

```
kickstartR/
├── R/
│   ├── initialize_project.R  # Updated with new parameters
│   ├── templates.R           # NEW: Template configurations
│   ├── wizard.R              # NEW: Interactive wizard
│   ├── config.R              # NEW: Config file support
│   ├── licenses.R            # NEW: License generation
│   └── utils.R               # NEW: Helper functions
├── inst/
│   └── templates/
│       ├── main_script_template.R
│       ├── targets_template.R      # NEW
│       ├── functions_template.R    # NEW
│       └── shiny/                  # NEW
│           ├── app.R
│           ├── ui.R
│           └── server.R
├── tests/
│   └── testthat/
│       ├── test-initialize_project.R
│       ├── test-templates.R        # NEW
│       ├── test-wizard.R           # NEW
│       ├── test-config.R           # NEW
│       └── test-licenses.R         # NEW
└── ...
```

---

## Updated DESCRIPTION (Suggests)

```
Suggests:
    testthat (>= 3.0.0),
    knitr,
    rmarkdown,
    renv,
    targets,
    yaml,
    rstudioapi
```

---

## Implementation Priority

| Priority | Feature | Effort | Impact |
|----------|---------|--------|--------|
| 1 | Quick Wins (author, date, etc.) | Low | Medium |
| 2 | License Generator | Low | High |
| 3 | Post-Creation Hooks | Low | High |
| 4 | renv Integration | Medium | High |
| 5 | Project Templates | Medium | High |
| 6 | targets Integration | Medium | Medium |
| 7 | Config File Support | Medium | Medium |
| 8 | Interactive Wizard | High | Medium |

---

## Testing Checklist

- [ ] All new parameters work with existing functionality
- [ ] Templates create correct directory structures
- [ ] renv initialization works when renv is installed
- [ ] renv skipped gracefully when not installed
- [ ] targets pipeline files are valid R code
- [ ] License files contain correct year and author
- [ ] Config files are parsed correctly
- [ ] Interactive wizard handles edge cases
- [ ] Post-creation hooks work in RStudio
- [ ] Post-creation hooks degrade gracefully outside RStudio
- [ ] All 28+ existing tests still pass
- [ ] New tests achieve good coverage

---

## Version Bump

Update `DESCRIPTION`:
```
Version: 0.2.0
```

Update `NEWS.md`:
```markdown
# kickstartR 0.2.0

## New Features
- Added project templates: basic, analysis, shiny, targets, minimal
- Added `renv` integration for dependency management
- Added `targets` pipeline support
- Added automatic license file generation
- Added interactive project wizard (`initialize_project_interactive()`)
- Added config file support (`.kickstartR.yml`)
- Added post-creation hooks (open_project, open_readme, git_init)
- New parameters: author, date, custom_dirs, gitignore_extras

## Improvements
- Template files now support placeholder substitution
- Better error messages and validation
- Graceful degradation when optional packages not installed
```

# kickstartR 0.2.0

## New Features

### Project Templates
- **5 built-in templates**: `basic`, `analysis`, `shiny`, `targets`, `minimal`
- Use `available_templates(verbose = TRUE)` to see all options
- Shiny template includes `app.R`, `ui.R`, `server.R`, and CSS structure
- Targets template includes `_targets.R` pipeline and `R/functions.R`

### Dependency Management
- **renv integration**: Use `include_renv = TRUE` to initialize renv
- Automatic `.gitignore` entries for renv directories
- Graceful fallback when renv is not installed

### Pipeline Support
- **targets integration**: Use `include_targets = TRUE` to add pipeline files
- Works with any template (not just the targets template)
- Pre-configured `_targets.R` with example pipeline structure

### License Generation
- **Automatic LICENSE files**: Use `license = "MIT"` (or GPL-3, GPL-2, CC-BY-4.0, CC0)
- `available_licenses()` function to list options
- Includes author name and current year

### Interactive Wizard
- **New function**: `initialize_project_interactive()` 
- Guided step-by-step project setup
- Perfect for beginners or quick project creation

### Configuration Files
- **Config file support**: `.kickstartR.yml` for team defaults
- Place in project or home directory
- `create_config()` function to generate template config

### New Parameters
- `author`: Set author name for templates and LICENSE
- `custom_dirs`: Add extra directories to any template
- `gitignore_extras`: Add custom patterns to .gitignore
- `git_init`: Initialize git repository automatically
- `open_project`: Open in RStudio after creation
- `open_readme`: Open README.md for editing

## Improvements
- Better README.md generation with project-specific content
- Improved .Rproj settings (no workspace saving by default)
- Template files support placeholder substitution
- Cleaner console output with progress messages
- All helper functions properly documented

## Internal
- New files: `R/templates.R`, `R/licenses.R`, `R/config.R`, `R/wizard.R`, `R/utils.R`
- Template files in `inst/templates/` for shiny, targets, minimal
- Refactored `initialize_project()` for modularity

---

# kickstartR 0.1.0

- Initial release of kickstartR package
- Added `initialize_project()` function for creating standardized R project structures
- Features include:
  - Organized directory structure (data, scripts, output, models, notebooks)
  - Boilerplate files (README.md, .gitignore, starter R script)
  - RStudio project integration (.Rproj files)
  - Flexible configuration options
  - Template files for consistent project setup
  - Support for the `here` package for robust path management
- Comprehensive test suite with 28 tests
- Complete documentation with roxygen2
- Package website with pkgdown
- Getting started vignette with examples and best practices

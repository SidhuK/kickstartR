# {{PROJECT_NAME}}

This is the main directory for the '{{PROJECT_NAME}}' project.

## Project Structure

- `/01_data`: Contains all data.
  - `/01_data/01_raw`: Original, immutable data dump.
  - `/01_data/02_processed`: Intermediate, cleaned, or transformed data.
  - `/01_data/03_external`: Data from external sources.
- `/02_scripts`: Source code for analysis, modeling, etc. (R scripts, Python scripts).
- `/03_output`: All outputs from scripts and analyses.
  - `/03_output/01_figures`: Generated plots and figures.
  - `/03_output/02_tables`: Generated tables (e.g., CSVs for reports).
  - `/03_output/03_reports_rendered`: Rendered reports (HTML, PDF) from notebooks/RMarkdown.
    {{#INCLUDE_MODELS}}- `/04_models`: Saved model objects, model summaries, etc.{{/INCLUDE_MODELS}}
    {{#INCLUDE_NOTEBOOKS}}- `/05_notebooks`: R Markdown files, Jupyter notebooks, Quarto documents for exploratory analysis and reporting.{{/INCLUDE_NOTEBOOKS}}
- `README.md`: This file - project overview and instructions.
  {{#CREATE_RPROJ}}- `{{PROJECT_NAME}}.Rproj`: RStudio Project file.{{/CREATE_RPROJ}}

## Getting Started

1. Open the `.Rproj` file in RStudio to set up the project environment
2. Place your raw data in `/01_data/01_raw/`
3. Start your analysis in `/02_scripts/00_main_script.R`
4. Save processed data to `/01_data/02_processed/`
5. Export figures to `/03_output/01_figures/`
6. Export tables to `/03_output/02_tables/`

## Dependencies

Consider using the `here` package for robust file path management:

```r
# Install if you haven't already
install.packages("here")

# Use in your scripts
library(here)
here::i_am("02_scripts/00_main_script.R")
data <- read.csv(here::here("01_data", "01_raw", "data.csv"))
```

## Project Guidelines

- Keep raw data immutable - never modify files in `/01_data/01_raw/`
- Use descriptive file names and include dates where relevant
- Document your workflow in scripts with clear comments
- Use version control (git) to track changes to your analysis code

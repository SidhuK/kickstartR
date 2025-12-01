# _targets.R for {{PROJECT_NAME}}
# Created: {{DATE}}
# Author: {{AUTHOR}}
#
# This is the main targets pipeline file.
# Run targets::tar_make() to execute the pipeline.
# Run targets::tar_visnetwork() to visualize dependencies.

library(targets)

# Set target-level options
tar_option_set(
  packages = c("tidyverse"),
  format = "rds"
)

# Source all functions
tar_source("R/functions.R")

# Define the pipeline
list(
  # Track the raw data file
  tar_target(
    raw_data_file,
    "01_data/01_raw/data.csv",
    format = "file"
  ),

  # Load raw data
  tar_target(
    raw_data,
    read_csv(raw_data_file, show_col_types = FALSE)
  ),

  # Process/clean data
  tar_target(
    processed_data,
    process_data(raw_data)
  ),

  # Fit model
  tar_target(
    model,
    fit_model(processed_data)
  ),

  # Generate results
  tar_target(
    results,
    summarize_results(model)
  ),

  # Create visualization
  tar_target(
    figure,
    create_figure(processed_data),
    format = "file"
  )
)

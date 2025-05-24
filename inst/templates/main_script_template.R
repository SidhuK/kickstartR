# Main analysis script for {{PROJECT_NAME}}
# Created: {{DATE}}
# Author: [Your Name]

# Load libraries ----
# Uncomment and add libraries as needed
# library(tidyverse)  # For data manipulation and visualization
# library(here)       # For robust file path management
# library(readr)      # For reading data files
# library(ggplot2)    # For data visualization
# library(dplyr)      # For data manipulation

# Set up environment ----
# Set base directory using here (recommended)
# here::i_am("02_scripts/00_main_script.R")

# Optional: Set random seed for reproducibility
# set.seed(123)

# Define custom functions ----
# Add any custom functions here

# Load data ----
# Example: Load raw data
# raw_data <- read.csv(here::here("01_data", "01_raw", "your_raw_data.csv"))
#
# Or using readr for better performance and options:
# raw_data <- read_csv(here::here("01_data", "01_raw", "your_raw_data.csv"))

# Data processing ----
# Example data cleaning and transformation steps
# processed_data <- raw_data %>%
#   filter(!is.na(important_column)) %>%
#   mutate(new_column = old_column * 2) %>%
#   select(relevant_columns)

# Save processed data ----
# write.csv(processed_data,
#           here::here("01_data", "02_processed", "processed_data.csv"),
#           row.names = FALSE)
#
# Or using readr:
# write_csv(processed_data,
#           here::here("01_data", "02_processed", "processed_data.csv"))

# Analysis / Modeling ----
# Perform your statistical analysis or modeling here
# model <- lm(dependent_var ~ independent_var, data = processed_data)
# summary(model)

# Save model objects (if applicable) ----
# saveRDS(model, here::here("04_models", "my_model.rds"))

# Create visualizations ----
# my_plot <- ggplot(processed_data, aes(x = x_var, y = y_var)) +
#   geom_point() +
#   labs(title = "{{PROJECT_NAME}} - Main Analysis",
#        x = "X Variable",
#        y = "Y Variable") +
#   theme_minimal()

# Save outputs ----
# Save figures
# ggsave(here::here("03_output", "01_figures", "main_analysis_plot.png"),
#        my_plot,
#        width = 10, height = 6, dpi = 300)

# Save tables/results
# write.csv(summary_table,
#           here::here("03_output", "02_tables", "summary_results.csv"),
#           row.names = FALSE)

# Session info (for reproducibility) ----
# Uncomment to save session information
# writeLines(capture.output(sessionInfo()),
#            here::here("03_output", "session_info.txt"))

message("Main script for {{PROJECT_NAME}} executed successfully.")
print(paste("Analysis completed at:", Sys.time()))

test_that("initialize_project creates basic directory structure", {
    # Create a temporary directory for testing
    temp_dir <- tempdir()
    project_name <- "TestProject"
    project_path <- file.path(temp_dir, project_name)

    # Clean up any existing test directory
    if (dir.exists(project_path)) {
        unlink(project_path, recursive = TRUE)
    }

    # Test the function
    result <- initialize_project(project_name, path = temp_dir)

    # Check that the function returns the correct path
    expect_equal(result, project_path)

    # Check that main project directory exists
    expect_true(dir.exists(project_path))

    # Check that all expected subdirectories exist
    expected_dirs <- c(
        "01_data",
        "01_data/01_raw",
        "01_data/02_processed",
        "01_data/03_external",
        "02_scripts",
        "03_output",
        "03_output/01_figures",
        "03_output/02_tables",
        "03_output/03_reports_rendered",
        "04_models",
        "05_notebooks"
    )

    for (dir in expected_dirs) {
        expect_true(dir.exists(file.path(project_path, dir)),
            info = paste("Directory", dir, "should exist")
        )
    }

    # Check that expected files exist
    expect_true(file.exists(file.path(project_path, "README.md")))
    expect_true(file.exists(file.path(project_path, ".gitignore")))
    expect_true(file.exists(file.path(project_path, ".here")))
    expect_true(file.exists(file.path(project_path, "02_scripts", "00_main_script.R")))
    expect_true(file.exists(file.path(project_path, paste0(project_name, ".Rproj"))))

    # Clean up
    unlink(project_path, recursive = TRUE)
})

test_that("initialize_project respects include_models parameter", {
    temp_dir <- tempdir()
    project_name <- "TestProjectNoModels"
    project_path <- file.path(temp_dir, project_name)

    # Clean up any existing test directory
    if (dir.exists(project_path)) {
        unlink(project_path, recursive = TRUE)
    }

    # Test with include_models = FALSE
    initialize_project(project_name, path = temp_dir, include_models = FALSE)

    # Check that models directory does NOT exist
    expect_false(dir.exists(file.path(project_path, "04_models")))

    # Clean up
    unlink(project_path, recursive = TRUE)
})

test_that("initialize_project respects include_notebooks parameter", {
    temp_dir <- tempdir()
    project_name <- "TestProjectNoNotebooks"
    project_path <- file.path(temp_dir, project_name)

    # Clean up any existing test directory
    if (dir.exists(project_path)) {
        unlink(project_path, recursive = TRUE)
    }

    # Test with include_notebooks = FALSE
    initialize_project(project_name, path = temp_dir, include_notebooks = FALSE)

    # Check that notebooks directory does NOT exist
    expect_false(dir.exists(file.path(project_path, "05_notebooks")))

    # Clean up
    unlink(project_path, recursive = TRUE)
})

test_that("initialize_project respects create_rproj parameter", {
    temp_dir <- tempdir()
    project_name <- "TestProjectNoRproj"
    project_path <- file.path(temp_dir, project_name)

    # Clean up any existing test directory
    if (dir.exists(project_path)) {
        unlink(project_path, recursive = TRUE)
    }

    # Test with create_rproj = FALSE
    initialize_project(project_name, path = temp_dir, create_rproj = FALSE)

    # Check that .Rproj file does NOT exist
    expect_false(file.exists(file.path(project_path, paste0(project_name, ".Rproj"))))

    # Clean up
    unlink(project_path, recursive = TRUE)
})

test_that("initialize_project handles existing directories correctly", {
    temp_dir <- tempdir()
    project_name <- "TestProjectExists"
    project_path <- file.path(temp_dir, project_name)

    # Create the directory first
    dir.create(project_path, showWarnings = FALSE)

    # Test that it throws an error without overwrite
    expect_error(
        initialize_project(project_name, path = temp_dir, overwrite = FALSE),
        "already exists"
    )

    # Test that it works with overwrite = TRUE (expect messages, not silence)
    expect_message(initialize_project(project_name, path = temp_dir, overwrite = TRUE))
    expect_true(dir.exists(project_path))

    # Clean up
    unlink(project_path, recursive = TRUE)
})

test_that("initialize_project validates project_name input", {
    temp_dir <- tempdir()

    # Test empty string
    expect_error(
        initialize_project("", path = temp_dir),
        "must be a non-empty character string"
    )

    # Test NULL
    expect_error(
        initialize_project(NULL, path = temp_dir),
        "must be a non-empty character string"
    )

    # Test numeric input
    expect_error(
        initialize_project(123, path = temp_dir),
        "must be a non-empty character string"
    )

    # Test multiple strings
    expect_error(
        initialize_project(c("test1", "test2"), path = temp_dir),
        "must be a non-empty character string"
    )
})

#' Null-coalescing operator
#'
#' Returns x if not NULL, otherwise y.
#'
#' @param x First value
#' @param y Default value if x is NULL
#' @return x if not NULL, otherwise y
#' @noRd
`%||%` <- function(x, y) {
  if (is.null(x)) y else x
}

#' Read Template File
#' @param template_name Name of the template file
#' @return Character vector of template contents
#' @keywords internal
read_template <- function(template_name) {

  template_path <- system.file("templates", template_name, package = "kickstartR")
  if (template_path == "" || !file.exists(template_path)) {
    stop("Template not found: ", template_name)
  }
  readLines(template_path, warn = FALSE)
}

#' Apply Template Substitutions
#' @param content Character vector of content
#' @param substitutions Named list of substitutions
#' @return Character vector with substitutions applied
#' @keywords internal
apply_substitutions <- function(content, substitutions) {
  result <- paste(content, collapse = "\n")
  for (name in names(substitutions)) {
    pattern <- paste0("\\{\\{", name, "\\}\\}")
    result <- gsub(pattern, substitutions[[name]], result)
  }
  strsplit(result, "\n")[[1]]
}

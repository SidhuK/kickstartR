#' Generate License File
#'
#' Creates a LICENSE file in the specified directory based on the license type.
#'
#' @param license License type. One of "MIT", "GPL-3", "GPL-2", "CC-BY-4.0", "CC0".
#' @param author Author name for the license. Defaults to system username.
#' @param path Directory where LICENSE file should be created.
#' @return Invisibly returns the license text, or NULL if no license specified.
#' @keywords internal
generate_license <- function(license, author = NULL, path) {
  if (is.null(license)) return(invisible(NULL))

  year <- format(Sys.Date(), "%Y")
  author <- author %||% Sys.info()[["user"]]

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
#'
#' Returns a character vector of available license identifiers that can be
#' used with the `license` parameter in `initialize_project()`.
#'
#' @return Character vector of available license identifiers.
#' @export
#' @examples
#' available_licenses()
available_licenses <- function() {
  c("MIT", "GPL-3", "GPL-2", "CC-BY-4.0", "CC0")
}

packages <- c(
  "dplyr",
  "readr",
  "stringr",
  "visNetwork",
  "htmltools",
  "jsonlite",
  "yaml",
  "tibble"
)

missing <- packages[!vapply(packages, requireNamespace, logical(1), quietly = TRUE)]

if (length(missing) > 0) {
  install.packages(missing)
} else {
  message("All required packages are already installed.")
}

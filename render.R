# Canonical renderer for the interactive network.
#
# Keeping responsive UI behavior as a render include means the project source
# owns the mobile controls directly. GitHub Actions and local renders use the
# same render entry point; no generated HTML is patched after rendering.

rmarkdown::render(
  "2025_Congressional_Stock_Network.Rmd",
  output_file = "index.html",
  output_options = list(
    includes = rmarkdown::includes(
      after_body = "mobile-network-controls.html"
    )
  ),
  quiet = FALSE
)

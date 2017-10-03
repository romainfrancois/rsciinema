library(css)
library(glue)


theme_css <- function(theme) {
  glue(
    "https://raw.githubusercontent.com/rstudio/rstudio/",
    "0d9d49aa8671527370c6c261fc031ae8a8081c45/src/gwt/src/",
    "org/rstudio/studio/client/workbench/views/source/editors/text/themes/{theme}.css"
  ) %>%
    read_css()
}

data <- theme_css("textmate")


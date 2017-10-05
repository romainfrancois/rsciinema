library(css)
library(glue)
library(rvest)
library(stringr)
library(dplyr)
library(purrr)

directory <- "https://github.com/rstudio/rstudio/blob/master/src/gwt/src/org/rstudio/studio/client/workbench/views/source/editors/text/themes"
raw_directory <- "https://raw.githubusercontent.com/rstudio/rstudio/master/src/gwt/src/org/rstudio/studio/client/workbench/views/source/editors/text/themes"
rstudio_theme_names <- read_html(directory) %>%
  html_nodes("a[title$='css']") %>%
  html_text() %>%
  str_replace( "[.]css$", "")

rstudio_themes <- map_df( rstudio_theme_names, ~{
  theme <- .
  read_css(glue("{raw_directory}/{theme}.css")) %>%
    mutate( theme = theme )
})

rstudio_themes <- mutate( rstudio_themes,
  dark =
  )


use_data( rstudio_themes, overwrite = TRUE)

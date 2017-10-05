library(css)
library(glue)
library(rvest)
library(stringr)

directory <- "https://github.com/rstudio/rstudio/blob/master/src/gwt/src/org/rstudio/studio/client/workbench/views/source/editors/text/themes"
themes <- read_html(directory) %>%
  html_nodes("a[title$='css']") %>%
  html_text() %>%
  str_replace( "[.]css$", "")


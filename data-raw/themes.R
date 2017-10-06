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
  str_replace( "[.]css$", "") %>%
  set_names(.)

rstudio_themes <- map( rstudio_theme_names, ~{
  read_css(glue("{raw_directory}/{.}.css"))
})

use_data( rstudio_themes, overwrite = TRUE)

ascii_css <- read_css("inst/htmlwidgets/lib/asciinema-player-2.5.0/asciinema-player.css")

default_fg_color <- function(rs_theme){
  filter(rs_theme, str_detect(rule, "^.ace_editor"), property == "color" ) %>% pull(value)
}
default_bg_color <- function(rs_theme){
  filter(rs_theme, str_detect(rule, "^.ace_editor"), property == "color" ) %>% pull(value)
}

kw <- function(rs_theme){
  filter(rs_theme, str_detect(rule, "^.ace_keyword") )
}
map_df( rstudio_themes, kw, .id = "themes") %>% select(-property)



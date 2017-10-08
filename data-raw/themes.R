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

to_hex_color <- function(x){
  case_when(
    str_detect(x, "^rgb") ~ {
      rx <- "^.*([[:digit:]]+).*([[:digit:]]+).*([[:digit:]]+).*$"
      r  <- as.integer(str_replace(x, rx, "\\1"))
      g  <- as.integer(str_replace(x, rx, "\\2"))
      b  <- as.integer(str_replace(x, rx, "\\3"))
      sprintf( "#%02X%02X%02X", r, g, b )
    } ,
    TRUE ~ x
  )
}

default_color <- function(rs_theme){
  rs_theme %>%
    filter(str_detect(rule, "^.ace_editor") ) %>%
    mutate( rule = "default" )
}
operator <- function(rs_theme){
  rs_theme %>%
    filter( str_detect(rule, ".ace_keyword.ace_operator" ) ) %>%
    filter( row_number() == n() ) %>%
    mutate( value = str_replace(value, " !important", "")) %>%
    mutate( value = to_hex_color(value) ) %>%
    mutate( rule = "operator")
}
paren <- function(rs_theme){
  data <- rs_theme %>%
    filter( str_detect(rule, ".ace_paren" ) ) %>%
    mutate( value = str_replace(value, " !important", "")) %>%
    mutate( value = to_hex_color(value) )

  if( !nrow(data) ){
    data <- operator(rs_theme)
  }
  mutate( data, rule = "paren")
}

extract_theme <- function(rs_theme){
  funs <- list(default_color, operator, paren)
  map_df( funs,  ~ .(rs_theme))
}



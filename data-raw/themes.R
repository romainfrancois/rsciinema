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

comment <- function(rs_theme){
  data <- filter( rs_theme, str_detect(rule, "^.ace_comment$" ) )
  if( !nrow(data)){
    data <- filter( rs_theme, str_detect(rule, ".ace_comment" ) )
  }
  mutate( data, rule = "comment")
}

keyword <- function(rs_theme){
  data <- filter( rs_theme, str_detect(rule, "^.ace_keyword$" ) )
  if( !nrow(data)){
    data <- filter( rs_theme, str_detect(rule, ".ace_keyword," ) )
  }
  if( !nrow(data)){
    data <- filter( rs_theme, str_detect(rule, ", .ace_keyword" ) )
  }
  mutate( data, rule = "keyword")
}


extract_theme <- function(rs_theme){
  funs <- list(default_color, operator, paren, comment)
  map_df( funs,  ~ .(rs_theme))
}

asciinema_theme <- function( rs_theme, name ){
  default <- default_color(rs_theme)
  fg <- filter( default, property == "color" ) %>% pull(value) %>% tail(1)
  bg <- filter( default, property == "background-color" ) %>% pull(value) %>% tail(1)

  colors16 <- slice( rs_theme,
      seq( which( rule == ".xtermColor0" ), which(rule == ".xtermBgColor15") )
    ) %>%
    pull(value)
  length(colors16)

  theme <- ascii_css %>%
    filter( str_detect(rule, "theme[-]asciinema")) %>%
    mutate(
      value = case_when(
        rule == ".asciinema-theme-asciinema .asciinema-terminal" & property == "color" ~ fg,
        rule == ".asciinema-theme-asciinema .asciinema-terminal" & property == "background-color" ~ bg,
        rule == ".asciinema-theme-asciinema .asciinema-terminal" & property == "border-color" ~ bg,
        rule == ".asciinema-theme-asciinema .fg-bg" & property == "color" ~ bg,
        rule == ".asciinema-theme-asciinema .bg-fg" & property == "color" ~ fg,
        TRUE ~ value
      )
    )

  idx <- seq(
    which(theme$rule == ".asciinema-theme-asciinema .fg-0"),
    which(theme$rule == ".asciinema-theme-asciinema .bg-15")
  )
  theme[ idx, "value"] <- colors16
  theme %>%
    mutate( rule = str_replace_all( rule,  "theme[-]asciinema", paste0("theme-", name) ) )

}

rsciinema_themes <- map2_df( rstudio_themes, names( rstudio_themes), asciinema_theme  )
write_css( rsciinema_themes, "inst/htmlwidgets/lib/asciinema-player-2.5.0/rsciinema-rstudio-themes.css" )



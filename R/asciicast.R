#' @importFrom stats runif
rtime <- function(n, speed){
  runif(n, min = speed*0.5, max = speed*1.5)
}

#' @export
asciibble <- function(x, speed, width){
  UseMethod("asciibble", x)
}

#' @export
asciibble.default <- function(x, speed, width){
  tibble( time = numeric(), text=character())
}

#' @importFrom stringr str_replace_all
#' @importFrom magrittr %>%
#' @importFrom crayon make_style
#' @export
asciibble.character <- function(x, speed, width){
  text <- str_split(x, "\n") %>%
    pluck(1) %>%
    head(-1) %>%
    str_replace_all( "^", "## ") %>%
    paste( collapse = "\r\n")

  discreet <-  make_style( "#444444" )
  tibble( time = rtime(1,speed), text = discreet(paste0( text, "\r\n")) )
}

#' @importFrom crayon red bold magenta
#' @export
asciibble.warning <- function(x, speed, width){
  x <- magenta(bold(paste0("Warning message:\r\n", conditionMessage(x))))
  tibble( time = rtime(1,speed), text = x )
}

#' @importFrom crayon red bold
#' @export
asciibble.error <- function(x, speed, width){
  call <- conditionCall(x)
  message <- conditionMessage(x)
  prefix <- if( is.null(x) ){
    "Error"
  } else {
    glue( "Error in {deparse}", deparse = deparse(call))
  }
  x <- red(bold(glue("{prefix}:\r\n{message}\r\n")))
  tibble( time = rtime(1,speed), text = x )
}

#' @importFrom purrr pluck flatten_chr map2
#' @importFrom stringr str_split str_replace
#' @importFrom tibble tibble
#' @export
asciibble.source <- function(x, speed, width){

  data  <- highlight_data(x)
  chars <- .Call(split_chars,
    min(data$line1), max(data$line2) ,
    data$line1, data$col1,
    data$line2, data$col2,
    data$text, data$class
  )
  data <- tibble( text = chars[[1]], class=chars[[2]] ) %>%
    filter( text != "" )
  tokens <- flatten_chr(map2(data$text, data$class, ~{
    if( .y == "SPACE" ){
      str_replace_all( .x, "\n", "\r\n")
    } else {
      txt <- str_split(.x, "")[[1]] %>%
        str_replace_all( "\n", "\r\n")

      if( .y == "functioncall" ){
        crayon::red(txt)
      } else {
        txt
      }
    }
  }))
  tibble( time = rtime(1+length(tokens),speed), text = c(tokens, "\r\n") )
}

#' Simulate evaluation of code
#'
#' @param input see [evaluate::evaluate()]
#' @param envir see [evaluate::evaluate()]
#' @param speed average number of seconds used to type 1 character
#' @param version version of the asciicast format
#' @param cols terminal output width
#' @param rows terminal output height
#' @param title title of the ascii cast
#'
#' @examples
#' \dontrun{
#' asciicast( "# a comment\niris %>% \n  dplyr::group_by(Species) %>%\n  dplyr::summarise_all(mean)" )
#' }
#'
#'
#' @importFrom purrr map_df
#' @importFrom evaluate evaluate
#' @export
asciicast <- function(
  input,
  envir = parent.frame(),
  speed = .1,
  version = 1,
  cols = 80,
  rows = 24,
  title = ""

){

  data <- map_df( evaluate(input, envir=envir ), asciibble,
    speed = speed, width = cols
  )

  structure(
    data,
    class = c("asciicast", class(data)),
    version = version,
    width   = cols,
    height  = rows,
    duration = sum(pull(data, time)),
    command = "R",
    title = title,
    env = list(TERM = "xterm-256color", SHELL = "/bin/bash")
  )
}

#' convert an asciicast tibble to its json representation
#'
#' @param data an asciicast tibble
#' @return json formatted asciicast
#'
#' @importFrom purrr map2
#' @importFrom dplyr pull mutate
#' @importFrom jsonlite toJSON write_json
#' @export
json_asciicast <- function(data){
  obj <- list(
    version = attr(data, "version"),
    width = attr(data, "width"),
    height = attr(data, "height"),
    command = attr(data, "command"),
    title = attr(data, "title"),
    env = attr(data, "env"),
    stdout = data %>% mutate( map2(time,text,list) ) %>% pull()
  )
  toJSON(obj, auto_unbox = TRUE)
}

#' write ascii cast tibble to a json file
#'
#' @param data asciicast tibble
#' @param path output file
#'
#' @export
write_asciicast <- function(data, path){
  writeLines( json_asciicast(data), path )
}



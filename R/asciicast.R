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


#' @importFrom crayon make_style
#' @export
asciibble.character <- function(x, speed, width){
  text <- str_split(x, "\n") %>%
    pluck(1) %>%
    str_replace_all( "^", "## ") %>%
    paste( collapse = "\r\n")

  discreet <-  make_style( grey(.3) )
  tibble( time = rtime(1,speed), text = discreet(paste0( "\r\n", text)) )
}

#' @importFrom crayon red bold magenta
#' @export
asciibble.warning <- function(x, speed, width){
  x <- magenta(bold(paste0("\r\nWarning message:\r\n", conditionMessage(x))))
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
  x <- red(bold(glue("\r\n{prefix}:\r\n{message}")))
  tibble( time = rtime(1,speed), text = x )
}

#' @importFrom purrr pluck
#' @importFrom stringr str_split str_replace
#' @importFrom tibble tibble
#' @export
asciibble.source <- function(x, speed, width){
  str_split(x, "") %>%
    pluck(1) %>%
    str_replace( "\n", "\r\n") %>%
    tibble( time = rtime(length(.),speed), text = . )
}

#' Simulate evaluation of code
#'
#' @param input see [evaluate::evaluate()]
#' @param envir see [evaluate::evaluate()]
#' @param speed average number of seconds used to type 1 character
#' @param version version of the asciicast format
#' @param width terminal output width
#' @param height terminal output height
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
  width = 80,
  height = 24,
  title = ""
){

  x <- evaluate(input, envir=envir )

  data <- map_df( x, asciibble, speed = speed, width = width )

  structure(
    data,
    class = c("asciicast", class(data)),
    version = version,
    width   = width,
    height  = height,
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



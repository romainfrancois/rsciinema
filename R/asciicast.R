rtime <- function(n, speed){
  runif(n, min = speed*0.5, max = speed*1.5)
}

#' @export
asciibble <- function(x, speed){
  UseMethod("asciibble", x)
}

#' @export
asciibble.default <- function(x, speed){
  tibble( time = numeric(), text=character())
}

#' @export
asciibble.character <- function(x, speed){
  tibble( time = rtime(1,speed), text = paste0("\r\n", str_replace_all(x, "\n", "\r\n")))
}

#' @importFrom crayon red bold magenta
#' @export
asciibble.warning <- function(x, speed){
  x <- magenta(bold(paste0("\r\nWarning message:\r\n", conditionMessage(x))))
  tibble( time = rtime(1,speed), text = x )
}

#' @importFrom crayon red bold
#' @export
asciibble.error <- function(x, speed){
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
asciibble.source <- function(x, speed){
  str_split(x, "") %>%
    pluck(1) %>%
    str_replace( "\n", "\r\n") %>%
    tibble( time = rtime(length(.),speed), text = . ) %>%
    bind_rows( tibble(time = rtime(1, speed), text = "\r\n"), . )
}


#' @importFrom purrr map_df
#' @importFrom evaluate evaluate
#' @export
asciicast <- function(
  input,
  envir = parent.frame(),
  speed = .2,
  version = 1,
  width = 80,
  height = 24,
  title = ""
){

  x <- evaluate(input, envir=envir )

  data <- map_df( x, asciibble, speed = speed )

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

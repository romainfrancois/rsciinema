#' read an asciicast file
#'
#' @param file asciicast file
#' @return a tibble with columns time and text, and attributes
#'
#' @examples
#' \dontrun{
#'  read_asciicast( system.file("resources", "mapscii.json", package = "rsciinema") )
#' }
#'
#' @importFrom jsonlite fromJSON
#' @importFrom tibble tibble
#' @importFrom purrr map_dbl map_chr pluck
#' @export
read_asciicast <- function(file){
  json <- fromJSON(file, simplifyVector = FALSE)

  data <- tibble(
    time = map_dbl(json$stdout, 1),
    text = map_chr(json$stdout, 2)
  )
  structure(data,
    class = c("asciicast", class(data)),
    version = pluck(json, "version"),
    width   = pluck(json, "width"),
    height  = pluck(json, "height"),
    duration = pluck(json, "duration"),
    command = pluck(json, "command"),
    title = pluck(json, "title"),
    env = pluck(json, "env")
  )
}

#' @importFrom crayon silver
#' @export
print.asciicast <- function(x, ...){
  cat( silver( glue(
    "<ascii cast duration={duration}>",duration = round(attr(x, "duration"), 2)
  )), "\n" )
  NextMethod()
}

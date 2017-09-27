
#' encode a -n asciicast json file in base64
#'
#' @param file asciicast file
#' @return the file encoded in base64 with content type `application/json`
#'
#' @importFrom httpuv rawToBase64
#' @export
asciicast_base64 <- function(file){
  bytes <- file.info(file)$size
  b64 <- rawToBase64(readBin(file, "raw", n = bytes))
  paste0("data:application/json;base64,", b64)
}

#' @import rlang %||%
get_poster <- function(poster_text = NULL, poster_frame = NULL, secs = 0 ){
  if( !is.null(poster_text) ){
    glue("data:text/plain,{poster_text}")
  } else {
    glue("npt:{seconds}", seconds = poster_frame %||% secs )
  }
}

#' player for asciicasts
#'
#' @param file asciicast json file
#' @param src source asciicast
#' @param cols number of columns of players terminal
#' @param rows number of rows of players terminal
#' @param autoplay if `TRUE` it autoplays
#' @param loop if `TRUE` it loops
#' @param start_at a number of seconds or a `Period` created by e.g. [lubridate::seconds()]
#' @param speed speed, 2 means twice as fast
#'
#' @param width width
#' @param height height
#' @param elementId id
#'
#' @examples
#' \dontrun{
#'   asciinema( system.file("resources", "mapscii.json", package = "rsciinema") )
#' }
#'
#' @importFrom lubridate seconds
#' @importFrom htmlwidgets createWidget
#' @export
asciinema <- function(
  file,
  cols = 80, rows = 24, autoplay = FALSE, loop = FALSE,
  start_at = 0, speed = 1,
  poster_text = NULL, poster_frame = NULL,
  src = asciicast_base64(file),
  width = NULL, height = NULL, elementId = NULL
) {

  secs <- as.numeric(seconds(start_at))
  poster <- get_poster( poster_text, poster_frame, secs )

  createWidget(
    name = 'asciinema',
    list(
      src = src, cols = cols, rows = rows,
      autoplay = autoplay, loop = loop,
      start_at = secs,
      speed = speed,
      poster = poster
    ),
    width = width,
    height = height,
    package = 'rsciinema',
    elementId = elementId
  )
}

#' Shiny bindings for asciinema
#'
#' Output and render functions for using asciinema within Shiny
#' applications and interactive Rmd documents.
#'
#' @param outputId output variable to read from
#' @param width,height Must be a valid CSS unit (like \code{'100\%'},
#'   \code{'400px'}, \code{'auto'}) or a number, which will be coerced to a
#'   string and have \code{'px'} appended.
#' @param expr An expression that generates a asciinema
#' @param env The environment in which to evaluate \code{expr}.
#' @param quoted Is \code{expr} a quoted expression (with \code{quote()})? This
#'   is useful if you want to save an expression in a variable.
#'
#' @name asciinema-shiny
#'
#' @importFrom htmlwidgets shinyWidgetOutput
#' @export
asciinemaOutput <- function(outputId, width = '100%', height = '400px'){
  shinyWidgetOutput(outputId, 'asciinema', width, height, package = 'rsciinema')
}

#' @rdname asciinema-shiny
#' @importFrom htmlwidgets shinyRenderWidget
#' @export
renderAsciinema <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) { expr <- substitute(expr) } # force quoted
  shinyRenderWidget(expr, asciinemaOutput, env, quoted = TRUE)
}

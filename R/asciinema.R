
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

#' @importFrom glue glue
poster <- function(poster_text = NULL, poster_frame = NULL, secs = 0 ){
  if( !is.null(poster_text) ){
    glue("data:text/plain,{poster_text}")
  } else {
    glue("npt:{seconds}", seconds = if(is.null(poster_frame)) secs else as.numeric(seconds(poster_frame)) )
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
#' @param poster_frame if not `NULL`, used as the
#' @param poster_text if not `NULL`, used as the text of the poster (preview)
#' @param font_size size of terminal font. Possible values: small, medium, big, any css `font-size` value (e.g. 15px)
#' @param theme theme.
#' @param title Title of the asciicast, displayed in the titlebar in fullscreen mode
#' @param author Author of the asciicast, displayed in the titlebar in fullscreen mode
#' @param author_url URL of the author's homepage/profile. Author name (`author` above) is linked to this URL
#' @param author_img_url URL of the author's image, displayed in the titlebar in fullscreen mode.
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
  font_size  = "small",
  theme= c("asciinema", "tango", "solarized-dark", "solarized-light", "monokai"),
  title="", author = "",
  author_url = "", author_img_url = "",
  src = asciicast_base64(file),
  width = NULL, height = NULL, elementId = NULL
) {

  secs <- as.numeric(seconds(start_at))

  createWidget(
    name = 'asciinema',
    list(
      src = src, cols = cols, rows = rows,
      autoplay = autoplay, loop = loop,
      start_at = secs,
      speed = speed,
      poster = poster( poster_text, poster_frame, secs ),
      theme = match.arg(theme),
      font_size = font_size,
      title = title,
      author = author,
      author_url = author_url,
      author_img_url = author_img_url
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

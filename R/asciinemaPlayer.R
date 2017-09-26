
#' player for asciicasts
#'
#' @param file asciicast json file
#'
#' @param width width
#' @param height height
#' @param elementId id
#'
#' @examples
#' \dontrun{
#'   asciinemaPlayer( system.file("resources", "mapscii.json", package = "rsciinema") )
#' }
#'
#' @importFrom htmlwidgets createWidget
#' @importFrom httpuv rawToBase64
#' @export
asciinemaPlayer <- function(file, width = NULL, height = NULL, elementId = NULL) {

  bytes <- file.info(file)$size
  b64 <- rawToBase64(readBin(file, "raw", n = bytes))
  src <- paste0("data:application/json;base64,", b64)

  createWidget(
    name = 'asciinemaPlayer',
    list( src = src ),
    width = width,
    height = height,
    package = 'rsciinema',
    elementId = elementId
  )
}

#' Shiny bindings for asciinemaPlayer
#'
#' Output and render functions for using asciinemaPlayer within Shiny
#' applications and interactive Rmd documents.
#'
#' @param outputId output variable to read from
#' @param width,height Must be a valid CSS unit (like \code{'100\%'},
#'   \code{'400px'}, \code{'auto'}) or a number, which will be coerced to a
#'   string and have \code{'px'} appended.
#' @param expr An expression that generates a asciinemaPlayer
#' @param env The environment in which to evaluate \code{expr}.
#' @param quoted Is \code{expr} a quoted expression (with \code{quote()})? This
#'   is useful if you want to save an expression in a variable.
#'
#' @name asciinemaPlayer-shiny
#'
#' @importFrom htmlwidgets shinyWidgetOutput
#' @export
asciinemaPlayerOutput <- function(outputId, width = '100%', height = '400px'){
  shinyWidgetOutput(outputId, 'asciinemaPlayer', width, height, package = 'rsciinema')
}

#' @rdname asciinemaPlayer-shiny
#' @importFrom htmlwidgets shinyRenderWidget
#' @export
renderAsciinemaPlayer <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) { expr <- substitute(expr) } # force quoted
  shinyRenderWidget(expr, asciinemaPlayerOutput, env, quoted = TRUE)
}

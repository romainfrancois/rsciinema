#' @import htmlwidgets
#' @export
asciinemaPlayer <- function(src, width = NULL, height = NULL, elementId = NULL) {

  # forward options using x
  x = list(
    src = src
  )

  # create widget
  htmlwidgets::createWidget(
    name = 'asciinemaPlayer',
    x,
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
#' @export
asciinemaPlayerOutput <- function(outputId, width = '100%', height = '400px'){
  htmlwidgets::shinyWidgetOutput(outputId, 'asciinemaPlayer', width, height, package = 'rsciinema')
}

#' @rdname asciinemaPlayer-shiny
#' @export
renderAsciinemaPlayer <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) { expr <- substitute(expr) } # force quoted
  htmlwidgets::shinyRenderWidget(expr, asciinemaPlayerOutput, env, quoted = TRUE)
}

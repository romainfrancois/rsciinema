
#' Format adapter to embed asciicast into html documents
#'
#' @param format base format, e.g. [rmarkdown::html_document()]
#' @param width Number of columns of player's terminal
#' @param height Number of lines of player's terminal
#' @param speed Typing speed in seconds. The average number of seconds it takes to type one character
#' @param ... passed to the base format
#'
#' @importFrom glue glue
#' @importFrom rlang %||% quo_text enquo
#' @export
asciinema_document <- function(format = rmarkdown::html_document, width = 80, height = 24, speed = .1, ...){
  fmt <- format(...)

  asciicast_hook <- function(options){
    opt <- function(op){
      name <- quo_text(enquo(op))
      opts <- options$asciicast
      if( !is.list(opts) || !name %in% names(opts) ) op else opts[[name]]
    }

    # prefer the values from the chunk options
    # these options are used to simulate the typing,
    # i.e. by the asciicast function
    width  <- opt(width)
    height <- opt(height)
    speed  <- opt(speed)
    title  <- opt(title)

    # other options just control the widget
    form <- formals(asciinema)
    opt_asciinema <- function(name){
      opts <- options$asciicast
      if( !is.list(opts) || !name %in% names(opts) ){
        form[[name]] %||% ""
      } else {
        opts[[name]]
      }
    }
    autoplay       <- opt_asciinema("autoplay")
    start_at       <- opt_asciinema("start_at")
    loop           <- opt_asciinema("loop")
    font_size      <- opt_asciinema("font_size")
    theme          <- opt_asciinema("theme")
    title          <- opt_asciinema("title")
    author         <- opt_asciinema("author")
    author_url     <- opt_asciinema("author_url")
    author_img_url <- opt_asciinema("author_img_url")
    poster_text    <- opt_asciinema("poster_text")
    poster_frame   <- opt_asciinema("poster_frame")

    # replace the code by a call to asciinema and hide it
    options$echo <- FALSE
    options$results <- "markup"

    tf <- tempfile()
    writeLines(options$code, tf)

    options$code <- glue(
      '
       rsciinema::asciinema( data =
          rsciinema::asciicast(
            file("{tf}", open = "r"),
            width = {width}, height = {height}, speed = {speed}, title = "{title}"
          ),
         cols = {width}, rows = {height}, autoplay = {autoplay},
         start_at = {start_at}, loop = {loop}, font_size = "{font_size}",
         theme = "{theme}", title = "{title}", author = "{author}",
         author_url = "{author_url}",
         author_img_url = "{author_img_url}",
         poster_text = "{poster_text}",
         poster_frame = "{poster_frame}"
      )
      '
    )
    writeLines( options$code)

    options
  }

  fmt$knitr$opts_hooks <- append(
    fmt$knitr$opts_hooks,
    list( asciicast = asciicast_hook )
  )
  fmt
}

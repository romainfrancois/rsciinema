
#' Format adapter to embed asciicast into html documents
#'
#' @param format base format, e.g. [rmarkdown::html_document()]
#' @param cols Number of columns of player's terminal
#' @param rows Number of lines of player's terminal
#' @param speed Typing speed in seconds. The average number of seconds it takes to type one character
#' @param autoplay if TRUE the player will start automatically
#' @param loop if TRUE the player loops
#' @param theme theme. One of asciinema, tango, solarized-dark, solarized-light or tango
#' @param font_size font size. One of small, medium, big or any CSS that is valid for a `font-size`
#'
#' @param ... passed to the base format
#'
#' @importFrom glue glue
#' @importFrom rlang %||% quo_text enquo
#' @export
asciinema_document <- function(
  format = rmarkdown::html_document,
  cols = 80, rows = 24, speed = .1,
  autoplay = FALSE, loop = FALSE,
  theme = "asciinema",
  font_size = "small",
  ...){
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
    cols  <- opt(cols)
    rows <- opt(rows)
    speed  <- opt(speed)
    title  <- opt(title)
    autoplay       <- opt(autoplay)
    loop           <- opt(loop)
    theme <- opt(theme)
    font_size      <- opt(font_size)

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
    start_at       <- opt_asciinema("start_at")
    title          <- opt_asciinema("title")
    author         <- opt_asciinema("author")
    author_url     <- opt_asciinema("author_url")
    author_img_url <- opt_asciinema("author_img_url")
    poster_text    <- opt_asciinema("poster_text")
    poster_frame   <- opt_asciinema("poster_frame")

    # replace the code by a call to asciinema and hide it
    options$echo <- FALSE
    options$results <- "markup"

    options$code <- glue(
      '
       rsciinema::asciinema( data =
          rsciinema::asciicast(
            "{code}",
            rows = {rows}, cols = {rows}, speed = {speed}, title = "{title}"
          ),
         cols = {cols}, rows = {rows}, autoplay = {autoplay},
         start_at = {start_at}, loop = {loop}, font_size = "{font_size}",
         theme = "{theme}", title = "{title}", author = "{author}",
         author_url = "{author_url}",
         author_img_url = "{author_img_url}",
         poster_text = "{poster_text}",
         poster_frame = "{poster_frame}"
      )
      ', code = str_replace_all(paste(options$code, collapse = "\n" ), '"', '\\\\"' )
    )

    options
  }

  fmt$knitr$opts_hooks <- append(
    fmt$knitr$opts_hooks,
    list( asciicast = asciicast_hook )
  )
  fmt
}


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
#' @param author Author of the asciicast, displayed in the titlebar in fullscreen mode
#' @param author_url URL of the author's homepage/profile. Author name (`author` above) is linked to this URL
#' @param author_img_url URL of the author's image, displayed in the titlebar in fullscreen mode.
#' @inheritParams asciinema
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
  author = "",
  author_url = "",
  author_img_url = "",
  start_at = 0,
  title = "",
  poster_text = "",
  poster_frame = "",
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
    author         <- opt(author)
    author_url     <- opt(author_url)
    author_img_url <- opt(author_img_url)
    start_at <- opt(start_at)
    title <- opt(title)
    poster_text <- opt(poster_text)
    poster_frame <- opt(poster_frame)

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


#' asciicast hook
#'
#' Use this option hook to produce an asciicast
#' with the R code in the chunk
#'
#' @param options chunk options
#' @importFrom glue glue
#' @export
asciicast_hook <- function(options){
  # run the code with asciicast and save the asciicast to
  # a temporary file
  tf <- tempfile(fileext = ".json")
  write_asciicast(asciicast(input = options$code ), tf)

  # replace the code by a call to asciinema and hide it
  options$echo <- FALSE
  options$results <- "markup"
  options$code <- glue('rsciinema::asciinema("{tf}")')

  options
}

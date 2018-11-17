#' Backspace character for Casting
#'
#' @param n Number of backspaces to put in
#'
#' @return A character vector
#' @export
#'
#' @examples
#' backspace(4)
backspace = function(n = 1) {
  rep("\b\u001b[K", n)
}

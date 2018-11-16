# this is borrowed from highlight which is
# changing too rapidly at the moment

#' @importFrom utils getParseData
#' @importFrom tibble as_tibble
#' @importFrom dplyr case_when pull
#' @importFrom stringr str_detect
#' @importFrom utils installed.packages
lestrade <- function( data, ... ){

  keywords <- c( "FUNCTION", "FOR", "IN", "IF",
    "ELSE", "WHILE", "NEXT", "BREAK", "REPEAT",
    "AND", "AND2", "OR", "OR2", "GT",
    "LT", "GE", "LBB", "NE",
    "NS_GET_INT", "NS_GET")
  assigns <- c("EQ_ASSIGN", "LEFT_ASSIGN" )

  magrittr_pipes <- c("%>%", "%<>%", "%T>%")

  data %>%
    mutate(
      token = case_when(
        token == "COMMENT" & grepl( "^#'", text) ~ "ROXYGENCOMMENT",
        TRUE ~ token
      ),
      class = case_when(
        !terminal ~ "",
        text %in% magrittr_pipes               ~ "magrittr_pipe special",
        text == "return"                       ~ "keyword",
        token == "SPECIAL"                     ~ "special",
        str_detect(token, "^'.*?'$")           ~ "keyword",
        token == "COMMENT"                     ~ "comment",
        token == "ROXYGENCOMMENT"              ~ "roxygencomment",
        token %in% keywords                    ~ "keyword",
        token == "STR_CONST"                   ~ "string",
        token == "NUM_CONST"                   ~ "number",
        token == "SYMBOL_FUNCTION_CALL"        ~ "functioncall",
        token == "SYMBOL_SUB"                  ~ "symbol_argument",
        token == "EQ_SUB"                      ~ "argument",

        token == "SYMBOL_PACKAGE" & text %in% base  ~ "base_package package",
        token == "SYMBOL_PACKAGE" & text %in% recommended  ~ "recommended_package package",
        token == "SYMBOL_PACKAGE" & text %in% tidyverse  ~ "tidyverse_package package",
        token == "SYMBOL_PACKAGE" ~ "package",

        token == "SYMBOL_FORMALS"              ~ "symbol_formalargs",
        token == "EQ_FORMALS"                  ~ "eqformalargs",
        token %in% assigns                     ~ "assignment",
        token == "SYMBOL"                      ~ "symbol",
        token == "SLOT"                        ~ "slot"
      ),
      style = ""
    )

}

highlight_data <- function(x){
  terminal = NULL
  rm(list = "terminal")
  getParseData( parse(text = x, keep.source = TRUE) ) %>%
    lestrade() %>%
    filter(terminal)
}

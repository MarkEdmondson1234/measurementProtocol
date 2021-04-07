#' A helper function that tests whether an object is either NULL _or_
#' a list of NULLs
#'
#' @keywords internal
#' @noRd
is.NullOb <- function(x) is.null(x) | all(sapply(x, is.null))

#' Recursively step down into list, removing all such objects
#'
#' @keywords internal
#' @noRd
rmNullObs <- function(x) {
  x <- Filter(Negate(is.NullOb), x)
  lapply(x, function(x) if (is.list(x)) rmNullObs(x) else x)
}


#' Custom message log level
#'
#' @param ... The message(s)
#' @param level The severity
#'
#' @details 0 = everything, 1 = debug, 2=normal, 3=important
#' @keywords internal
#' @noRd
#' @import cli
myMessage <- function(..., level = 2){

  # implement level?

  time <- paste(Sys.time(),">")
  mm <- paste(...)
  if(grepl("^#", mm)){
    cli::cli_h1(mm)
  } else {
    cli::cli_div(theme = list(span.time = list(color = "grey")))
    cli::cli_alert_info("{.time {time}} {mm}")
    cli::cli_end()
  }


}

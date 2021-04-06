#' Opt in or out of package usage tracking
#'
#' You can opt-in or out to sending a measurement protocol hit when you load the package for use in the package's statistics via this function.  No personal data is collected.
#'
#' @export
#' @rdname mp_trackme_event
#' @param package_name The package you want to write in the setup messages
#'
#' @examples
#'
#' # control your tracking choices via a menu if in interactive session
#' if(interactive()){
#'   mp_trackme()
#' }
#' @importFrom usethis ui_yeah
#' @import assertthat
#' @importFrom cli cli_h1 cli_alert_info
mp_trackme <- function(package){

  assert_that(is.string(package))

  cli_h1("Tracking Consent for {package} usage")
  cli_alert_info("This function opts you in or out of sending a tracking hit each time the library loads.  It is done using ga_trackme_event().")
  opt_in <- usethis::ui_yeah(
    sprintf("Do you opt in to tracking each time you load %s?", package)
  )

  # this folder should exist as its used for gargle
  the_file <- .trackme$filepath

  if(opt_in){
    if(file.exists(the_file)){
      cli::cli_alert_info("Opt-in file {the_file} already found - no more action needed")
      return(invisible(NULL))
    }

    cli::cli_alert_success(
      "Thanks! Your consent and an ID will be marked by the presence of the file {the_file}.  Delete it or run this function again to remove consent.")

    dir.create(rappdirs::user_config_dir(package), showWarnings = FALSE)
    file.create(the_file)
    cid <- mp_cid()
    write(cid, the_file)

    return(invisible(NULL))
  }

  if(file.exists(the_file)){
    cli::cli_alert_info("Found {the_file} - deleting as you have opted-out")
    unlink(the_file)
  }

  cli::cli_alert_info(
    "No worries! If you change your mind run this function again.")
}

.trackme <- new.env()
.trackme$measurement_id <- "G-43MDXK6CLZ"
.trackme$api <- "_hS_7VJARhqbCq9mF3oiNg"
.trackme$filepath <- file.path(rappdirs::user_config_dir("googleAnalyticsR"),
                               "optin-googleanalyticsr")

#' Send a tracking hit for googleAnalyticsR package statistics
#'
#' If you opt in, `mp_trackme_event()` is the function that fires.  You can use `debug_call=TRUE` to see what would be sent before opting in or out.
#'
#' Running `mp_trackme_event()` function will send a Measurement Protocol hit via [ga_mp_send] only if the `~/.R/optin-googleanalyticsr` file is present
#'
#' @param debug_call Set as a debug event to see what would be sent
#' @param say_hello If you want to add your own custom message to the event sent, add it here!
#'
#' @export
#'
#' @examples
#'
#' # this only works with a valid opt-in file present
#' mp_trackme_event()
#'
#' # see what data is sent
#' mp_trackme_event(debug_call=TRUE)
#'
#' # add your own message!
#' mp_trackme_event(debug_call = TRUE, say_hello = "err hello Mark")
#' @import assertthat
mp_trackme_event <- function(debug_call = FALSE, say_hello = NULL){

  if(!is.null(say_hello)){
    assert_that(is.string(say_hello))
  }

  the_file <- .trackme$filepath
  if(!file.exists(the_file) & !debug_call){
    myMessage("No consent file found", level = 2)
    return(FALSE)
  }

  ss <- utils::sessionInfo()
  event <- mp_event(
    "googleanalyticsr_loaded",
    params = list(
      r_version = ss$R.version$version.string,
      r_platform = ss$platform,
      r_locale = ss$locale,
      r_system = ss$running,
      say_hello = say_hello,
      package = paste("googleAnalyticsR",  utils::packageVersion("googleAnalyticsR"))
    )
  )

  if(debug_call){
    cid <- tryCatch(cid <- readLines(the_file)[[1]],
                    error = function(e) "12345678.987654")
  } else {
    cid <- readLines(the_file)[[1]]
  }


  if(is.null(.trackme$measurement_id) | is.null(.trackme$api)){
    myMessage("No tracking parameters found, setting dummy values", level = 3)
    m_id = "Measurement_ID"
    api = "API_secret"
  } else {
    m_id = .trackme$measurement_id
    api = .trackme$api
  }

  my_conn <- mp_connection(measurement_id = m_id, api_secret = api)

  if(debug_call){
    return(mp_send(event, client_id = cid,
                      connection = my_conn,
                      debug_call = TRUE))
  }
  suppressMessages(
    mp_send(event, client_id = cid,
               connection = my_conn,
               debug_call = debug_call)
    )

  cli::cli_alert_success("Sent library load tracking event")

}

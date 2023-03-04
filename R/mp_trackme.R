.trackme <- new.env()
.trackme$measurement_id <- "G-43MDXK6CLZ"
.trackme$api <- "_hS_7VJARhqbCq9mF3oiNg"

#' Tracking opt-in for this package
#'
#' This is the opt-in function for this package, using [mp_trackme]
#' @returns No return value, called for side effects
#' @export
mp_opt_in <- function(){ # nocov start
  mp_trackme("measurementProtocol")
} # nocov end

get_trackme_file <- function(package){
  file.path(rappdirs::user_config_dir(package), "optin-tracking")
}

#' Opt in or out of package usage tracking
#'
#' You can opt-in or out to sending a measurement protocol hit when you load the package for use in the package's statistics via this function.  No personal data is collected.
#'
#' @export
#' @rdname mp_trackme_event
#' @param package The package you want to track
#'
#'
#' @examples
#'
#' # control your tracking choices via a menu if in interactive session
#' if(interactive()){
#'   mp_trackme()
#' }
#' @import assertthat
#' @importFrom cli cli_h1 cli_alert_info
#' @importFrom utils menu
mp_trackme <- function(package){ # nocov start

  assert_that(is.string(package), nzchar(package))

  cli_h1("Tracking Consent for {package} usage")
  cli_alert_info("This function opts you in or out of sending a tracking hit each time the library loads.")

  opt_in <- menu(
    title = sprintf("Do you opt in to tracking each time you load %s?", package),
    choices = c("Yes","No")
  )

  answer <- FALSE
  if(opt_in == 1){
    answer <- TRUE
  }

  the_file <- get_trackme_file(package)

  if(answer){
    # opt-in
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

  # opt-out

  if(file.exists(the_file)){
    cli::cli_alert_info("Found {the_file} - deleting as you have opted-out")
    unlink(the_file)
  }

  cli::cli_alert_info(
    "No worries! If you change your mind run this function again.")
} # nocov end

#' Package tracking opt-in start-up message
#'
#' Place in .onAttach to have a message appear on first start-up
#' @param package The package to set-up tracking for
#' @param opt_in_function The name of the function for a user to opt-in
#' @returns No return value, called for side effects
#' @import assertthat
#' @noRd
mp_trackme_startup <- function(package, opt_in_function){ # nocov start

  if(is.null(opt_in_function)){
    opt_in_function <- "measurementProtocol::mp_trackme"
  }

  assert_that(
    is.string(package), nzchar(package),
    is.string(opt_in_function)
  )

  if(!file.exists(get_trackme_file(package)) && interactive()){
    packageStartupMessage(
      sprintf("You can opt in to tracking of your use of %s - see ?%s for details.",
              package, opt_in_function)
    )
  }
} # nocov end

#' Send a tracking hit for R package statistics
#'
#' If you opt in, this is the function that fires.  You can use `debug_call=TRUE` to see what would be sent before opting in or out.
#'
#' Running this function will send a Measurement Protocol hit via [mp_send] only if the cache file is present
#' @param package The package name
#' @param opt_in_function The name of the function for a user to opt-in
#' @param debug_call Set as a debug event to see what would be sent
#' @param say_hello If you want to add your own custom message to the event sent, add it here!
#' @returns No return value, called for side effects
#' @export
#'
#' @examples
#'
#' # this only works with a valid opt-in file present
#' mp_trackme_event("googleAnalyticsR")
#'
#' # see what data is sent
#' mp_trackme_event("googleAnalyticsR", debug_call=TRUE)
#'
#' # add your own message!
#' mp_trackme_event("googleAnalyticsR",
#'                  debug_call = TRUE,
#'                  say_hello = "err hello Mark")
#'
#' # placed in .onAttach with function name
#' .onAttach <- function(libname, pkgname){
#'   measurementProtocol::mp_trackme_event(pkgname, opt_in_function = "mp_opt_in")
#'  }
#'
#' @import assertthat
mp_trackme_event <- function(package,
                             debug_call = FALSE,
                             say_hello = NULL,
                             opt_in_function = NULL){

  # extra cautious as this function can prevent package load
  tryCatch(
    trackme_event(package = package,
                  debug_call = debug_call,
                  say_hello = say_hello,
                  opt_in_function = opt_in_function),
    error = function(err){
      warning("Error on package load with mp_trackme_event: ", err$message)
      NULL
    }
  )

}

#' @import assertthat
trackme_event <- function(package,
                          debug_call = FALSE,
                          say_hello = NULL,
                          opt_in_function = NULL){
  assert_that(
    is.string(package), nzchar(package)
  )

  if(!is.null(say_hello)){
    assert_that(is.string(say_hello))
  }

  the_file <- get_trackme_file(package)
  if(!file.exists(the_file) & !debug_call){
    mp_trackme_startup(package, opt_in_function = opt_in_function)
    return(FALSE)
  }

  ss <- utils::sessionInfo()
  event <- mp_event(
    "r_package_loaded",
    params = list(
      r_version = ss$R.version$version.string,
      r_platform = ss$platform,
      r_locale = ss$locale,
      r_system = ss$running,
      say_hello = say_hello,
      package = paste(package,  utils::packageVersion(package))
    )
  )

  if(debug_call){
    cid <- tryCatch(cid <- readLines(the_file)[[1]],
                    error = function(e) "12345678.987654")
  } else {
    cid <- readLines(the_file)[[1]]
  }


  if(any(
    is.null(.trackme$measurement_id),
    is.null(.trackme$api))
  ){
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
  } # nocov start
  suppressMessages(
    mp_send(event, client_id = cid,
            connection = my_conn,
            debug_call = debug_call)
  )

  cli::cli_alert_success("Sent library load tracking event")
  # nocov end
}

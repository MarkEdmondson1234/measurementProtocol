#' Make a Measurement Protocol v2 request
#'
#' @description
#' `r lifecycle::badge("experimental")`
#' Create a server side call to Google Analytics 4 via its Measurement Protocol
#'
#' @param events The events to send
#' @param client_id The client_id to associate with the event
#' @param connection The connection details created by [mp_connection]
#' @param debug_call Send hits to the Google debug endpoint to validate hits.
#' @param user_id Optional. Unique id for the user
#' @param timestamp_micros Optional. A Unix timestamp (in microseconds) for the time to associate with the event.
#' @param user_properties Optional. The user properties for the measurement sent in as a named list.
#' @param non_personalized_ads Optional. Set to true to indicate these events should not be used for personalized ads.
#'
#' @returns \code{TRUE} if successfully sent the hit.  If \code{debug_call=TRUE} then the JSON response from the debugger endpoint
#'
#' @details
#'
#' Create an API secret via `Admin > Data Streams > choose your stream > Measurement Protocol > Create`
#'
#' To see event parameters, create custom fields in your GA4 account first, to see them in your reports 24hrs after you send them in with this function via `Custom definitions > Create custom dimensions` - `dimension name` will be how it looks like in the reports, `event parameter` will be the parameter you have sent in with the event.
#'
#' `user_id` can be used for [cross-platform analysis](https://support.google.com/analytics/answer/9213390)
#'
#' `timestamp_micros` should only be set to record events that happened in the past. This value can be overridden via user_property or event timestamps. Events can be backdated up to 48 hours. Note microseconds, not milliseconds.
#'
#' `user_properties` - describe segments of your user base, such as language preference or geographic location.  See [User properties](https://developers.google.com/analytics/devguides/collection/protocol/ga4/user-properties?client_type=gtag)
#'
#' Ensure you also have user permission as specified in the [feature policy](https://developers.google.com/analytics/devguides/collection/protocol/ga4/policy)
#'
#' Invalid events are silently rejected with a 204 response, so use `debug_call=TRUE` to validate your events first.
#'
#' @seealso [Measurement Protocol (Google Analytics 4)](https://developers.google.com/analytics/devguides/collection/protocol/ga4)
#'
#' @export
#' @family Measurement Protocol functions
#' @return `TRUE` if successful, if `debug_call=TRUE` then validation messages if not a valid hit.
#' @examples
#' # preferably set this in .Renviron
#' Sys.setenv(MP_SECRET="MY_SECRET")
#'
#' # your GA4 settings
#' my_measurement_id <- "G-1234"
#'
#' my_connection <- mp_connection(my_measurement_id)
#'
#' a_client_id <- 123.456
#' event <- mp_event("an_event")
#' mp_send(event, a_client_id, my_connection, debug_call = TRUE)
#'
#' # multiple events at same time in a batch
#' another <- mp_event("another_event")
#'
#' mp_send(list(event, another),
#'            a_client_id,
#'            my_connection,
#'            debug_call = TRUE)
#' \dontrun{
#' # you can see sent events in the real-time reports
#' library(googleAnalyticsR)
#' my_property_id <- 206670707
#' ga_data(my_property_id,
#'         dimensions = "eventName",
#'         metrics = "eventCount",
#'         dim_filters = ga_data_filter(
#'            eventName == c("an_event","another_event")),
#'         realtime = TRUE)
#'
#' }
#' @importFrom jsonlite toJSON fromJSON
#' @importFrom httr content POST verbose add_headers
#' @import assertthat
mp_send <- function(
  events,
  client_id,
  connection,
  user_id = NULL,
  debug_call = FALSE,
  timestamp_micros = NULL,
  user_properties = NULL,
  non_personalized_ads = TRUE){

  assert_that(
    is.mp_connection(connection),
    is.flag(debug_call),
    is.flag(non_personalized_ads)
  )

  if(length(events) > 0 &&
     !is.mp_event(events) &&
     !all(unlist(lapply(events, is.mp_event)))){
    stop("Must supply a mp_event object or a list of mp_event objects",
         call. = FALSE)
  }

  # a single event - wrap in a list to make a json array
  if(is.mp_event(events)){
    events <- list(events)
  }

  endpoint <- connection$endpoint
  if(debug_call) endpoint <- "https://www.google-analytics.com/debug/mp/collect"
  my_headers <- connection$preview_header

  the_url <- sprintf(
    "%s?measurement_id=%s&api_secret=%s",
    endpoint, connection$measurement_id, connection$api_secret
  )

  the_body <- rmNullObs(list(
    client_id = as.character(client_id),
    user_id = as.character(user_id),
    timestamp_micros = timestamp_micros,
    user_properties = user_properties,
    non_personalized_ads = non_personalized_ads,
    events = events
  ))

  my_verbose <- NULL
  if(debug_call){
    myMessage("MP Request:",
              the_url,"\n",
              toJSON(the_body,
                     auto_unbox = TRUE,
                     pretty = TRUE),
              level = 3)

    my_verbose <- verbose()

  }

  res <- POST(
    the_url,
    body = the_body,
    connection$preview_header,
    my_verbose,
    encode = "json"
  )

  myMessage("Response: ", res$status, level = 3)

  parsed <- content(res, as = "text", encoding = "UTF-8")

  if(nzchar(parsed) && debug_call){
    o <- fromJSON(parsed)
    if(length(o$validationMessages) > 0) return(o$validationMessages)
    myMessage("No validation messages found", level = 3)
  }

  TRUE
}

#' Create a connection for Measurement Protocol v2
#'
#' Use [mp_connection] to set up the Measurement Protocol connections to pass to [mp_send].  If using Google Tag Manager Server-Side, you can also set up a custom endpoint.
#'
#' @param api_secret The secret generated in the GA4 UI - by default will look for environment arg `MP_SECRET`
#' @param measurement_id The measurement ID associated with a stream
#' @param endpoint If NULL will use Google default, otherwise set to the URL of your Measurement Protocol custom endpoint
#' @param preview_header Only needed for custom endpoints. The `X-Gtm-Server-Preview` HTTP Header found in your GTM debugger
#'
#' @returns An \code{mp_connection} class object
#'
#' @export
#' @examples
#'
#' # custom GTM server side endpoint
#' my_custom_connection <- mp_connection(
#'    my_measurement_id,
#'    endpoint = "https://gtm.example.com",
#'    preview_header = "ZW52LTV8OWdPOExNWFkYjA0Njk4NmQ="
#'  )
#'
#' @rdname mp_send
#' @import assertthat
mp_connection <- function(measurement_id,
                          api_secret = Sys.getenv("MP_SECRET"),
                          endpoint = NULL,
                          preview_header = NULL){
  assert_that(
    is.string(measurement_id),
    is.string(api_secret),
    nzchar(api_secret)
  )

  the_endpoint <- "https://www.google-analytics.com/mp/collect"
  my_headers <- NULL

  if(!is.null(endpoint)){
    assert_that(
      is.string(endpoint),
      grepl("^http", endpoint, ignore.case = TRUE))

    the_endpoint <- endpoint
  }

  if(!is.null(preview_header)){
    assert_that(
      is.string(preview_header),
      nzchar(preview_header))

    my_headers <- add_headers("X-Gtm-Server-Preview" = preview_header)
  }

  structure(list(
    measurement_id = measurement_id,
    api_secret = api_secret,
    endpoint = the_endpoint,
    preview_header = my_headers
  ),
  class = "mp_connection")
}

is.mp_connection <- function(x){
  inherits(x, "mp_connection")
}

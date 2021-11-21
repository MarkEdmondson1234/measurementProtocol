#' Parse out objects into the Measurement Protocol v2 format for sending
#'
#' This function helps take HTTP events and rearranges its structure so it will work in a MP measurement protocol hit.  This enables HTTP events from say Pub/Sub to be translated into MP hits.
#'
#' @param json The location of a json file or a json string or an R list that has been parsed from json via `jsonlite::fromJSON`
#' @param name_f The function that extracts the event name out of `json`
#' @param params_f An optional function that extracts parameters for the event from `json`
#' @param items_f An optional function that extracts e-commerce items from `json`. Must return a [mp_event_item] object.  you may not need this if the `params_f` includes parsing of e-commerce items
#'
#' @param client_id_f An optional function to extract the client.id.  You will need to supply cid though if using downstream in `mp_send` so it usually is necessary
#' @param user_id_f Optionally include a function that will parse out user_id
#' @param user_properties_f Optionally include a function that will parse out user properties
#'
#' @returns An `mp_parse_json` object that is a list of an `mp_event` object, and `user` fields including client.id, user.id and user properties
#' @export
#' @import jsonlite
#' @import assertthat
#'
#' @details
#'
#' The passed in functions should return NULL if they don't find any entries
#' @examples
#'
#' demo_json <- system.file("example", "pubsub-ga4.json", package = "measurementProtocol")
#' demo_list <- jsonlite::fromJSON(demo_json)
#'
#'
#' # extract the event_name
#' name_f <- function(x) x[["event_name"]]
#'
#' # extract client_id
#' client_id_f <- function(x) x[["client_id"]]
#'
#' # extract user_id
#' user_id_f <- function(x) x[["user_id"]]
#'
#' # simple event
#' mp_parse_json(demo_list,
#'               name_f,
#'               client_id_f = client_id_f,
#'               user_id_f = user_id_f)
#'
#' # params could be assumed to be everything not a event_name of client_id
#' # also not allowed any starting with reserved 'ga_'
#' params_f <- function(x){
#'   x_names <- names(x)[grepl("^x-", names(x))]
#'   ga_names <- names(x)[grepl("^ga_", names(x))]
#'   x[setdiff(names(x), c("client_id","user_id" ,"event_name", x_names, ga_names))]
#'   }
#'
#' # parse including params (could include items as well)
#' parsed_event <- mp_parse_json(demo_list,
#'                               name_f,
#'                               params_f = params_f,
#'                               client_id_f = client_id_f,
#'                               user_id_f = user_id_f)
#' parsed_event
#'
#' # sending to a debug endpoint
#' # preferably set this in .Renviron
#' Sys.setenv(MP_SECRET="MY_SECRET")
#'
#' # replace with your GA4 settings
#' my_measurement_id <- "G-1234"
#' my_connection <- mp_connection(my_measurement_id)
#' mp_send(parsed_event$mp_event,
#'         client_id = parsed_event$user$client_id,
#'         user_id = parsed_event$user$user_id,
#'         user_properties = parsed_event$user$user_properties,
#'         connection = my_connection,
#'         debug_call = TRUE)
#'
#'
mp_parse_json <- function(json,
                          name_f,
                          params_f = NULL,
                          items_f = NULL,
                          client_id_f = NULL,
                          user_id_f = NULL,
                          user_properties_f = NULL
                          ){

  if(!is.list(json)){
    json <- jsonlite::fromJSON(json, simplifyVector = FALSE)
  }

  myMessage("Received JSON:",
            jsonlite::toJSON(json, pretty = TRUE, auto_unbox = TRUE),
            level = 2)

  assert_that(is.function(name_f))

  name <- name_f(json)
  assert_that(is.string(name))

  params <- NULL
  items <- NULL
  client_id <- NULL
  user_id <- NULL
  user_properties <- NULL

  if(!is.null(params_f)){
    params <- params_f(json)
    if(!is.null(params)) assert_that(is.list(params))
  }

  if(!is.null(items_f)){
    items <- items_f(json)
    if(!is.null(items)){
      item_checks <- unlist(lapply(items, is.mp_event_item))
      assert_that(all(item_checks))
    }

  }

  if(!is.null(client_id_f)){
    client_id <-client_id_f(json)

    if(!is.null(client_id)) assert_that(is.string(client_id))
  }

  if(!is.null(user_id_f)){
    user_id <- user_id_f(json)
    if(!is.null(user_id)) assert_that(is.string(user_id))
  }

  if(!is.null(user_properties_f)){
    user_properties <- user_properties_f(json)
    if(!is.null(user_properties)) assert_that(is.list(user_properties))
  }

  structure(list(
    raw = json,
    mp_event = mp_event(
      name = name,
      params = params,
      items = items
    ),
    user = list(
      client_id = client_id,
      user_id = user_id,
      user_properties = user_properties
    )
  ), class = c("mp_parse_json","list"))

}

#' @rdname mp_parse_json
#' @export
#' @examples
#'
#' # mp_parse_gtm internally uses functions demonstrated with mp_parse_json
#' pubsub_event <- mp_parse_gtm(demo_json)
#'
#' mp_send(pubsub_event$mp_event,
#'         client_id = pubsub_event$user$client_id,
#'         user_id = pubsub_event$user$user_id,
#'         user_properties = pubsub_event$user$user_properties,
#'         connection = my_connection,
#'         debug_call = TRUE)
mp_parse_gtm <- function(json){

  name_f <- function(x) x[["event_name"]]
  client_id_f <- function(x) x[["client_id"]]
  user_id_f <- function(x) x[["user_id"]]

  # params could be assumed to be everything not a event_name of client_id
  # also not allowed any starting with reserved 'ga_'
  params_f <- function(x){
    x_names <- names(x)[grepl("^x-", names(x))]
    ga_names <- names(x)[grepl("^ga_", names(x))]
    x[setdiff(names(x), c("client_id","user_id" ,"event_name", x_names, ga_names))]
  }

  mp_parse_json(json,
                name_f,
                params_f = params_f,
                client_id_f = client_id_f,
                user_id_f = user_id_f)

}

#' Parse Pub/Sub responses in plumber files
#'
#' @param pubsub_body The req$postBody of a plumber request
#'
#' @return The Pub/Sub message "data" attribute unencoded into a json string
#' @export
#' @rdname mp_parse_json
#' @examples
#'
#' \dontrun{
#'
#' #* Send forward a measurement protocol hit
#' #* @post /gtm
#' #* @serializer unboxedJSON
#' #* @parser json
#' function(req, res, ga_id) {
#'
#'   pubsub_data <- mp_pubsub_parse(req$postBody)
#'
#'   parsed <- mp_parse_gtm(pubsub_data)
#'
#'   my_connection <- mp_connection(ga_id)
#'
#'   mp_send(parsed$mp_event,
#'           client_id = parsed$user$client_id,
#'           user_id = parsed$user$user_id,
#'           user_properties = parsed$user$user_properties,
#'           connection = my_connection)
#'
#'   "OK"
#'   }
#'
#'
#' }
mp_pubsub <- function(pubsub_body){
  pubsub_data <- NULL
  if(!is.null(pubsub_body) && nzchar(pubsub_body)){
    pubsub_data <- jsonlite::fromJSON(pubsub_body)
  }

  if(is.null(pubsub_data$message) ||
     is.null(pubsub_data$message$data)){
    message("Pub/Sub Message Data was invalid")
    return(FALSE)
  }

  message <- pubsub_data$message

  cat(as.character(Sys.time()),
      "-pubsub-message_id-",
      message$message_id,"-",
      message$publish_time,"-\n")

  rawToChar(jsonlite::base64_dec(message$data))

}

library(measurementProtocol)

# get mp_secret from env MP_SECRET

#* Home page
#* @get /
#* @serializer html
function() {
  "<html>
    <h1>measurementProtocol + plumber</h1>
    <p>POST to /gtm?ga_id=G-123456<p>
    <p>Debug via /gtm?ga_id=G-123456&debug=1<p>
    <p><a href=/__docs__/>Swagger docs</a>
  </html>"
}

# For parsing Pub/Sub messages
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

#* Send forward a measurement protocol hit
#* @post /gtm
#* @serializer unboxedJSON
#* @parser json
function(req, res, ga_id, debug = 0) {

  pubsub_data <- mp_pubsub(req$postBody)

  if(isFALSE(pubsub_data)){
    res$status <- 400
    return(list(error="Pub/Sub data parsing error"))
  }

  parsed <- suppressMessages(
    mp_parse_gtm(pubsub_data)
    )

  my_connection <- mp_connection(ga_id)

  message(
    sprintf("Sending event: %s for client.id %s",
            parsed$mp_event$name,
            parsed$user$client_id)
  )

  sent <- mp_send(parsed$mp_event,
                  client_id = parsed$user$client_id,
                  user_id = parsed$user$user_id,
                  user_properties = parsed$user$user_properties,
                  connection = my_connection,
                  debug_call = if(debug != 0) TRUE else FALSE)

  if(!isTRUE(sent)){
    res$status <- 400
    return(list(error="MP hit failed to send"))
  }

  "OK"
}

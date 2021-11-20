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

#* Send forward a measurement protocol hit
#* @post /gtm
#* @serializer unboxedJSON
#* @parser json
function(req, ga_id, debug = 0) {

  pubsub_data <- jsonlite::fromJSON(req$postBody)

  if(is.null(pubsub_data$message) ||
     is.null(pubsub_data$message$data)){
       res$status <- 400 # bad request
       return(list(error="Pub/Sub Message Data was invalid"))
     }

  message <- pubsub_data$message

  the_data <- rawToChar(jsonlite::base64_dec(message$data))

  parsed <- suppressMessages(mp_parse_gtm(the_data))

  my_connection <- mp_connection(ga_id)

  sent <- mp_send(parsed$mp_event,
                  client_id = parsed$user$client_id,
                  user_id = parsed$user$user_id,
                  user_properties = parsed$user$user_properties,
                  connection = my_connection,
                  debug_call = if(debug != 0) TRUE else FALSE)

  message(
    sprintf("Sending event: %s for client.id %s",
            parsed_event$mp_event$name,
            parsed_event$user$client_id)
    )

  if(!isTRUE(sent)){
    res$status <- 400 # bad request
    return(list(error="MP hit failed to send"))
  }

  "OK"
}

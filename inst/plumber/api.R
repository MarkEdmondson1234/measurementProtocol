library(measurementProtocol)

# get mp_secret from env MP_SECRET

#* Home page
#* @get /
#* @serializer html
function() {
  "<html>
    <h1>measurementProtocol + plumber</h1>
    <p>POST to /gtm?gtm_id=G-123456<p>
    <p>Debug via /gtm?gtm_id=G-123456&debug=1<p>
  </html>"
}

#* Send forward a measurement protocol hit
#* @post /gtm
#* @serializer json
#* @parser json
function(req, ga_id, debug = 0) {

  pubsub_data <- req$postBody

  if(is.null(pubsub_data$message)) stop("No message found in pub/sub event")

  the_data <- rawToChar(jsonlite::base64_dec(message$data))

  parsed <- mp_parse_gtm(the_data)

  my_connection <- mp_connection(ga_id)

  sent <- mp_send(parsed$mp_event,
                  client_id = parsed$user$client_id,
                  user_id = parsed$user$user_id,
                  user_properties = parsed$user$user_properties,
                  connection = my_connection,
                  debug_call = if(debug != 0) TRUE else FALSE)

  # curl -X POST "http://127.0.0.1:3932/gtm?gtm_id=dfdsfsf" \
  #     -H "accept: application/json" -d '{"event_name":"hi"}'

  parsed
}

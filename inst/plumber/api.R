library(measurementProtocol)

# get mp_secret from env MP_SECRET

#* Echo back the input
#* @param msg The message to echo
#* @get /
function(msg="") {
  list(msg = paste0("The message is: '", msg, "'"))
}

#* Send forward a measurement protocol hit
#* @post /gtm
#* @serializer json
#* @parser json
function(req, gtm_id, debug = 0) {
  parsed <- mp_parse_gtm(req$postBody)

  my_connection <- mp_connection(gtm_id)

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

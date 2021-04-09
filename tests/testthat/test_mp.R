test_that("Measurement Protocol Hits",{

  # preferably set this in .Renviron
  Sys.setenv(MP_SECRET="MY_SECRET")

  # your GA4 settings
  my_measurement_id <- "G-43MDXK6CLZ"

  my_connection <- mp_connection(my_measurement_id)
  a_client_id <- 1234567

  event <- mp_event("an_event")
  mp1 <- mp_send(event, a_client_id, my_connection, debug_call = TRUE)
  expect_true(mp1)

  event_error <- mp_event("_an_event")
  mp3 <- mp_send(event_error, a_client_id, my_connection, debug_call = TRUE)
  expect_snapshot(mp3)

  another <- mp_event("another_event")
  mp2 <- mp_send(list(event, another),
             a_client_id, my_connection,
             debug_call = TRUE)
  expect_true(mp2)

  # one item
  it1 <- mp_event_item(item_name = "jeggings",
                   price = 8.88,
                   item_variant = "Black")
  expect_snapshot(it1)

  # many items in a list
  items <- list(
    mp_event_item(item_id = "SKU_12345",
                     price = 9.99,
                     item_brand = "Gucci"),
    it1)
  expect_snapshot(items)

  # construct an event with its own fields
  event1 <- mp_event("add_payment_info",
              params = list(coupon = "SUMMER_FUN",
                            payment_type = "Credit Card",
                            value = 7.77,
                            currency = "USD"),
              items = items)
  expect_snapshot(event1)

  # error item
  expect_error(
    mp_event_item(coupon = "this_will_error")
  )

  expect_equal(class(mp_cid(1)), "character")

  a_trackme_event <- mp_trackme_event("measurementProtocol",
                                      debug_call = TRUE,
                                      say_hello = "hello")
  expect_true(a_trackme_event)

  expect_message(mp_trackme_event("measurementProtocol",
                                  debug_call = TRUE, say_hello = "hello"),
                 "MP Request")

  # custom connection
  custom_connection <- mp_connection(
    my_measurement_id,
    endpoint = "https://gtm.custom.com",
    preview_header = "XXXX"
  )
  expect_snapshot(custom_connection)

  expect_error(
    mp_connection(
      my_measurement_id,
      endpoint = "gtm.custom.com",
      preview_header = "XXXX"
    )
  )

  # error send
  expect_error(
    mp_send(list("error"), client_id = 12324, connection = my_connection)
  )



})

test_that("Measurement Protocol Hits",{

  # preferably set this in .Renviron
  Sys.setenv(GA_MP_SECRET="MY_SECRET")

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


})
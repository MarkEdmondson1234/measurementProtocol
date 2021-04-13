#' Create a Measurement Protocol Event
#'
#' @description
#' `r lifecycle::badge("experimental")`
#' This creates an event to send via [mp_send]
#'
#' @param name The event name to send in
#' @param params Optional event parameters sent in as a named list
#' @param items Optional items created via [mp_event_item]
#'
#' @returns An \code{mp_event} object
#'
#' @export
#' @family Measurement Protocol functions
#' @import assertthat
#' @examples
#'
#' mp_event("custom_event")
#' mp_event("custom_event", params = list(my_param = "SUPER"))
mp_event <- function(name, params = NULL, items = NULL){

  if(!is.null(items)){
    item_checks <- unlist(lapply(items, is.mp_event_item))
    assert_that(all(item_checks))

    params <- c(params, list(items = items))
  }

  structure(
    rmNullObs(list(
      name = name,
      params = params
    )), class = c("mp_event","list")
  )
}

is.mp_event <- function(x){
  inherits(x, "mp_event")
}

#' @export
print.mp_event <- function(x, ...){
  cat("\n==GA4 MP Event\n")
  print(jsonlite::toJSON(x, pretty = TRUE, auto_unbox = TRUE))
}

#' Create an Measurement Protocol Item Property for an Event
#'
#' @description
#' `r lifecycle::badge("experimental")`
#' Some events work with item properties
#'
#' @param item_id Item ID
#' @param item_name Item Name
#' @param coupon Coupon
#' @param discount Discount
#' @param affiliation Affiliation
#' @param item_brand Brand
#' @param item_category Category
#' @param item_variant Variant
#' @param price Price
#' @param currency Currency
#'
#' @returns An \code{mp_event_item} object
#'
#' @export
#' @family Measurement Protocol functions
#' @examples
#' # one item
#' mp_event_item(item_name = "jeggings",
#'                  price = 8.88,
#'                  item_variant = "Black")
#'
#' # many items in a list
#' items <- list(
#'   mp_event_item(item_id = "SKU_12345",
#'                    price = 9.99,
#'                    item_brand = "Gucci"),
#'   mp_event_item(item_name = "jeggings",
#'                    price = 8.88,
#'                    item_variant = "Black"))
#'
#' # construct an event with its own fields
#' mp_event("add_payment_info",
#'             params = list(coupon = "SUMMER_FUN",
#'                           payment_type = "Credit Card",
#'                           value = 7.77,
#'                           currency = "USD"),
#'             items = items)
#'
mp_event_item <- function(
  item_id = NULL,
  item_name = NULL,
  coupon = NULL,
  discount = NULL,
  affiliation = NULL,
  item_brand = NULL,
  item_category = NULL,
  item_variant = NULL,
  price = NULL,
  currency = NULL
){

  if(all(is.null(item_id), is.null(item_name))){
    stop("One of item_id or item_name is required", call. = FALSE)
  }

  structure(
    rmNullObs(list(
      item_id = item_id,
      item_name = item_name,
      coupon = coupon,
      discount = discount,
      affiliation = affiliation,
      item_brand = item_brand,
      item_category = item_category,
      item_variant = item_variant,
      price = price,
      currency = currency
    )), class = c("mp_event_item","list")
  )

}

is.mp_event_item <- function(x){
  inherits(x, "mp_event_item")
}

#' @export
print.mp_event_item <- function(x, ...){
  cat("==GA4 MP Event Item\n")
  print(jsonlite::toJSON(x, pretty = TRUE, auto_unbox = TRUE))
}

#' Generate a random client_id
#'
#' This has a random number plus a timestamp
#'
#' @param seed If you set a seed, then the random number will be the same for each value
#' @returns A string suitable as an Id with a random number plus a timestamp delimited by a period.
#' @export
#' @family Measurement Protocol functions
#' @examples
#'
#' # random Id
#' mp_cid()
#'
#' # fix the random number (but not the timestamp)
#' mp_cid(1)
mp_cid <- function(seed = NULL){

  if(!is.null(seed)){
    set.seed(seed)
  }
  rand <- round(stats::runif(1, min = 1, max = 100000000))
  ts <- round(as.numeric(Sys.time()))

  paste0(rand,".",ts)

}

# measurementProtocol - an R library for sending server-side data to Google Analytics 4

The [Measurement Protocol v2](https://developers.google.com/analytics/devguides/collection/protocol/ga4) is for sending data to Google Analytics 4.

This library enables the ability to use the API from R.

It also includes functions to use the measurement protocol to track events such as R library loads for package usage analytics.  

Complement the package with [googleAnalyticsR](https://code.markedmondson.me/googleAnalyticsR) to read the data you send. 

## Install

Not yet on CRAN.  From GitHub:

```{r}
remotes::install_github("MarkEdmondson1234/measurementProtocol")
```

## Usage 

Documentation on `googleAnalyticsR` dev website: https://code.markedmondson.me/googleAnalyticsR/dev/articles/measurement-protocol-v2.html

## Package Tracking

To enable package tracking in your R package you need the following:

1. Add your API secret and measurementId to a `.trackme` environment within your package.  These are public so it is possible for people to use them to send data.

```r
.trackme <- new.env()
.trackme$measurement_id <- "G-1234"
.trackme$api <- "_hS_7VJXXXXXXX"
```
2. In an `.onAttach` startup function add two functions or functions that wrap them: `mp_trackme_startup()` which will check for an opt-in file and send a message if it is not present, and `mp_trackme_event()` with your package name that will send the tracking event if they have opted-in.

```r
.onAttach <- function(libname, pkgname){
  measurementProtocol::mp_trackme_startup(pkgname)

  measurementProtocol::mp_trackme_event(pkgname)

}

```

3. Document usage of `mp_trackme()` (or a wrapper function) that will let end-users opt in to tracking.

```r
mp_trackme("yourPackage")
```

Since you know the package name, it is recommended to wrap the functions above with the package filled in e.g.

```r
optin_tracking_mypackage <- function(){
  mp_trackme("yourPackage")
}
```


# measurementProtocol - an R library for sending server-side data to Google Analytics 4

<!-- badges: start -->
[![CRAN](http://www.r-pkg.org/badges/version/measurementProtocol)](https://CRAN.R-project.org/package=measurementProtocol)
![CloudBuild](https://badger-ewjogewawq-ew.a.run.app/build/status?project=mark-edmondson-gde&id=8d88c387-66f1-4ae4-a202-c1cace1fd71f)
[![codecov](https://codecov.io/gh/MarkEdmondson1234/measurementProtocol/branch/master/graph/badge.svg)](https://app.codecov.io/gh/MarkEdmondson1234/measurementProtocol)
<!-- badges: end -->

The [Measurement Protocol v2](https://developers.google.com/analytics/devguides/collection/protocol/ga4) is for sending data to Google Analytics 4.

This library enables the ability to use the API from R.

It also includes functions to use the measurement protocol to track events such as R library loads for package usage analytics.  

Complement the package with [googleAnalyticsR](https://code.markedmondson.me/googleAnalyticsR/) to read the data you send. 

## Install

Install from CRAN

```{r}
install.packages("measurementProtocol")
```

Dev version from GitHub:

```{r}
remotes::install_github("MarkEdmondson1234/measurementProtocol")
```

## Usage 

See the documentation on the `measurementProtocol` website: https://code.markedmondson.me/measurementProtocol/

You need a Google Analytics 4 account to send the hits to.


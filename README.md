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

Documentation on `googleAnalyticsR` dev website: https://code.markedmondson.me/googleAnalyticsR/dev/articles/measurement-protocol-v2.html


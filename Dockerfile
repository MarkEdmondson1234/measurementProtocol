FROM rocker/r-ver

RUN install2.r --error \
    -r 'http://cran.rstudio.com' \
    measurementProtocol plumber \
    ## install Github packages
    && installGithub.r MarkEdmondson1234/measurementProtocol \
    ## clean up
    && rm -rf /tmp/downloaded_packages/ /tmp/*.rds

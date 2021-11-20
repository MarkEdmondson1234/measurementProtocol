FROM rstudio/plumber

RUN install2.r --error \
    -r 'http://cran.rstudio.com' \
    measurementProtocol \
    ## install Github packages
    && installGithub.r MarkEdmondson1234/measurementProtocol \
    ## clean up
    && rm -rf /tmp/downloaded_packages/ /tmp/*.rds

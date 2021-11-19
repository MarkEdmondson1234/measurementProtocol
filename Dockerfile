FROM rocker/r-ver

RUN export DEBIAN_FRONTEND=noninteractive; apt-get -y update \
  && apt-get install -y \
  libcurl4-openssl-dev

RUN install2.r --error \
    -r 'http://cran.rstudio.com' \
    measurementProtocol plumber \
    ## install Github packages
    && installGithub.r MarkEdmondson1234/measurementProtocol \
    ## clean up
    && rm -rf /tmp/downloaded_packages/ /tmp/*.rds

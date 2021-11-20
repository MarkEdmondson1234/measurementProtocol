FROM gcr.io/gcer-public/measurementprotocol

COPY . ./api

ENTRYPOINT ["R", "-e", "pr <- plumber::plumb(rev(commandArgs())[1]); pr$run(host='0.0.0.0', port=as.numeric(Sys.getenv('PORT')), swagger=TRUE)"]

CMD ["/api/api.R"]

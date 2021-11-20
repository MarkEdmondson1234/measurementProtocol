library(googleCloudRunner)

repo <- "MarkEdmondson1234/measurementProtocol"

cr_deploy_pkgdown(repo,
                  secret = "github-ssh",
                  cloudbuild_file = "cloud_build/pkgdown.yml")

cr_deploy_packagetests(
  cloudbuild_file = "cloud_build/testthat.yml",
  trigger_repo = cr_buildtrigger_repo(repo,branch = "^master$")
)


cr_deploy_docker_trigger(
  repo = cr_buildtrigger_repo(repo),
  image = "measurementProtocol", # forced down to be lowercase
  projectId_target = "gcer-public",
  timeout = 3600
)

cr_deploy_plumber(
  "inst/plumber",
  remote = "measurement_protocol_proxy",
  env_vars = paste0("MP_SECRET=", Sys.getenv("MP_SECRET"))
)

# curl -X POST "https://measurement-protocol-proxy-ewjogewawq-ew.a.run.app/gtm?gtm_id=dfdsfsf" -H "accept: application/json" -d '{"event_name":"hi","client_id":"1234"}'


bs <- c(
  cr_buildstep_docker(
    "measurement-protocol-proxy",
    kaniko_cache = TRUE,
    dir = "inst/plumber"
  ),
  cr_buildstep_run(
    "measurement-protocol-proxy",
    image = "gcr.io/$PROJECT_ID/measurement-protocol-proxy$BUILD_ID",
    env_vars = paste0("MP_SECRET=", Sys.getenv("MP_SECRET"))
  )
)

yaml <- cr_build_yaml(bs)
build <- cr_build_make(yaml)

cr_buildtrigger(
  build,
  name = "measurement-protocol-proxy-build",
  trigger = cr_buildtrigger_repo(repo),
  includedFiles = "inst/plumber/**",
  overwrite = TRUE
)



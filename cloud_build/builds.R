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

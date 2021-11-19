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
  image = "measurementProtocol",
  projectId_target = "gcer-public"
)

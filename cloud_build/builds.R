library(googleCloudRunner)

cr_deploy_pkgdown("MarkEdmondson1234/measurementProtocol",
                  secret = "github-ssh",
                  cloudbuild_file = "cloud_build/pkgdown.yml")

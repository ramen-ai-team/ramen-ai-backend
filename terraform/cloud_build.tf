resource "google_cloudbuild_trigger" "deploy" {
  project     = var.project_id
  name        = "ramen-ai-backend-service-asia-northeast1-ramen-ai"
  description = "Build and deploy to Cloud Run service ramen-ai-backend-service on push to \"^main$\""

  include_build_logs = "INCLUDE_BUILD_LOGS_WITH_STATUS"
  service_account    = "projects/${var.project_id}/serviceAccounts/cloudbuild@${var.project_id}.iam.gserviceaccount.com"

  github {
    owner = "ramen-ai-team"
    name  = var.github_repo

    push {
      branch = "^main$"
    }
  }

  filename = "cloudbuild.yaml"

  substitutions = {
    _DEPLOY_REGION  = var.region
    _AR_HOSTNAME    = "${var.region}-docker.pkg.dev"
    _AR_REPOSITORY  = var.ar_repository
    _AR_PROJECT_ID  = var.project_id
    _SERVICE_NAME   = var.service_name
    _PLATFORM       = "managed"
    _PROJECT_ID     = data.google_project.project.number
    _TRIGGER_ID     = "120889c1-2019-4ca7-965b-c21beaf5cde4"
  }

  tags = [
    "gcp-cloud-build-deploy-cloud-run",
    "gcp-cloud-build-deploy-cloud-run-managed",
    var.service_name,
  ]

  depends_on = [google_project_service.apis]
}

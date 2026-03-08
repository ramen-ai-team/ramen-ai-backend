resource "google_artifact_registry_repository" "default" {
  project       = var.project_id
  location      = var.region
  repository_id = var.ar_repository
  format        = "DOCKER"
  description   = "Cloud Run Source Deployments"

  depends_on = [google_project_service.apis]
}

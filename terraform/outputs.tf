output "cloud_run_url" {
  description = "Cloud Run service URL"
  value       = google_cloud_run_v2_service.default.uri
}

output "artifact_registry_url" {
  description = "Artifact Registry repository URL"
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/${var.ar_repository}"
}

output "cloud_run_service_account" {
  description = "Cloud Run service account email (default Compute SA)"
  value       = data.google_compute_default_service_account.default.email
}

output "project_number" {
  description = "GCP project number"
  value       = data.google_project.project.number
}

data "google_project" "project" {
  project_id = var.project_id
}

locals {
  # Cloud Buildトリガーで実際に使われているカスタムサービスアカウント
  cloudbuild_sa = "serviceAccount:cloudbuild@${var.project_id}.iam.gserviceaccount.com"
}

# Cloud BuildサービスアカウントにCloud Run管理権限を付与
resource "google_project_iam_member" "cloudbuild_run_admin" {
  project = var.project_id
  role    = "roles/run.admin"
  member  = local.cloudbuild_sa
}

# Cloud BuildサービスアカウントにArtifact Registry書き込み権限を付与
resource "google_project_iam_member" "cloudbuild_ar_writer" {
  project = var.project_id
  role    = "roles/artifactregistry.writer"
  member  = local.cloudbuild_sa
}

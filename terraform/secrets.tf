# Secret Managerのシークレット定義
# 注意: シークレットの値(version)はTerraform管理外とし、手動またはCI/CDで設定する

locals {
  secrets = [
    "RAILS_MASTER_KEY",
    "GCP_CLIENT_ID",
    "GCP_CLIENT_SECRET",
  ]
}

resource "google_secret_manager_secret" "secrets" {
  for_each  = toset(local.secrets)
  project   = var.project_id
  secret_id = each.value

  replication {
    auto {}
  }

  depends_on = [google_project_service.apis]
}

# Cloud BuildサービスアカウントにSecret Managerへのアクセス権を付与
resource "google_secret_manager_secret_iam_member" "cloudbuild_access" {
  for_each  = toset(local.secrets)
  project   = var.project_id
  secret_id = google_secret_manager_secret.secrets[each.value].secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = local.cloudbuild_sa
}

# デフォルトComputeサービスアカウント（Cloud Runが使用）にSecret Managerへのアクセス権を付与
resource "google_secret_manager_secret_iam_member" "cloudrun_access" {
  for_each  = toset(local.secrets)
  project   = var.project_id
  secret_id = google_secret_manager_secret.secrets[each.value].secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${data.google_compute_default_service_account.default.email}"
}

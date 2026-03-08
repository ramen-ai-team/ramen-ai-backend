locals {
  image = "${var.region}-docker.pkg.dev/${var.project_id}/${var.ar_repository}/${var.github_repo}/${var.service_name}:latest"
}

# 既存のデフォルトComputeサービスアカウントを参照
data "google_compute_default_service_account" "default" {
  project = var.project_id
}

resource "google_cloud_run_v2_service" "default" {
  project  = var.project_id
  name     = var.service_name
  location = var.region

  # IAMチェックを無効化（公開アクセス）
  invoker_iam_disabled = true

  template {
    service_account       = data.google_compute_default_service_account.default.email
    timeout               = "300s"
    max_instance_request_concurrency = 80

    scaling {
      min_instance_count = var.cloud_run_min_instances
      max_instance_count = var.cloud_run_max_instances
    }

    containers {
      image = local.image

      resources {
        limits = {
          cpu    = "1000m"
          memory = var.cloud_run_memory
        }
        cpu_idle          = true
        startup_cpu_boost = true
      }

      # Secret Managerからシークレットを注入
      env {
        name = "RAILS_MASTER_KEY"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.secrets["RAILS_MASTER_KEY"].secret_id
            version = "latest"
          }
        }
      }

      env {
        name = "GCP_CLIENT_ID"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.secrets["GCP_CLIENT_ID"].secret_id
            version = "latest"
          }
        }
      }

      env {
        name = "GCP_CLIENT_SECRET"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.secrets["GCP_CLIENT_SECRET"].secret_id
            version = "latest"
          }
        }
      }

      ports {
        container_port = 8080
        name           = "http1"
      }

      # 実際の設定に合わせてTCPプローブを使用
      startup_probe {
        tcp_socket {
          port = 8080
        }
        failure_threshold = 1
        period_seconds    = 240
        timeout_seconds   = 240
      }
    }

    vpc_access {
      egress = "PRIVATE_RANGES_ONLY"
      network_interfaces {
        network    = "default"
        subnetwork = "default"
      }
    }
  }

  lifecycle {
    # Cloud Buildがイメージ・ラベル・コンテナ名を更新するため、Terraform管理外とする
    ignore_changes = [
      template[0].containers[0].image,
      template[0].containers[0].name,
      template[0].labels,
      client,
      client_version,
    ]
  }

  depends_on = [
    google_project_service.apis,
    google_artifact_registry_repository.default,
  ]
}

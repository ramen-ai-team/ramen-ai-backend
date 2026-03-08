terraform {
  required_version = ">= 1.5"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }

  backend "gcs" {
    bucket = "ramen-ai-terraform-state"
    prefix = "ramen-ai-backend"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

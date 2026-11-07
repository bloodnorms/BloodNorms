# ============================================================================
# BloodNorms | infra/cloudrun-voice-gateway.tf
# Terraform Infrastructure as Code for Voice Gateway on Google Cloud Run
# ============================================================================

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

variable "project_id" {
  type        = string
  description = "GCP Project ID for BloodNorms production"
  default     = "bloodnorms-prod"
}

variable "region" {
  type        = string
  description = "Primary Cloud Run deployment region"
  default     = "asia-south1"
}

resource "google_cloud_run_v2_service" "voice_gateway" {
  name     = "bloodnorms-voice-gateway"
  location = var.region
  project  = var.project_id

  template {
    scaling {
      min_instance_count = 1
      max_instance_count = 20
    }

    containers {
      image = "gcr.io/${var.project_id}/voice-gateway:latest"

      resources {
        limits = {
          cpu    = "2000m"
          memory = "2048Mi"
        }
      }

      ports {
        container_port = 8080
      }

      env {
        name  = "PORT"
        value = "8080"
      }

      env {
        name  = "NODE_ENV"
        value = "production"
      }

      env {
        name = "VOICE_GATEWAY_SECRET"
        value_source {
          secret_key_ref {
            secret  = "voice-gateway-secret"
            version = "latest"
          }
        }
      }

      env {
        name = "GEMINI_API_KEY"
        value_source {
          secret_key_ref {
            secret  = "gemini-api-key"
            version = "latest"
          }
        }
      }

      liveness_probe {
        http_get {
          path = "/livez"
          port = 8080
        }
        period_seconds   = 10
        timeout_seconds  = 3
        failure_threshold = 3
      }

      startup_probe {
        http_get {
          path = "/readyz"
          port = 8080
        }
        period_seconds   = 5
        timeout_seconds  = 3
        failure_threshold = 6
      }
    }
  }
}

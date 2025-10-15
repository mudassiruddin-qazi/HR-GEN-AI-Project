terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }

  required_version = ">= 1.5.0"
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# -------------------------------
# 1️⃣ Enable Required APIs
# -------------------------------
resource "google_project_service" "required" {
  for_each = toset([
    "run.googleapis.com",
    "pubsub.googleapis.com",
    "secretmanager.googleapis.com",
    "storage.googleapis.com",
    "vertexai.googleapis.com",
    "firestore.googleapis.com",
    "cloudkms.googleapis.com",
    "cloudbuild.googleapis.com",
    "iam.googleapis.com"
  ])
  project             = var.project_id
  service             = each.key
  disable_on_destroy  = false
}

# -------------------------------
# 2️⃣ Service Account
# -------------------------------
resource "google_service_account" "api_sa" {
  account_id   = "genai-api-sa"
  display_name = "GenAI API Service Account"
}

# -------------------------------
# 3️⃣ IAM Roles
# -------------------------------
resource "google_project_iam_member" "api_sa_secret_access" {
  project = var.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.api_sa.email}"
}

resource "google_project_iam_member" "api_sa_storage" {
  project = var.project_id
  role    = "roles/storage.admin"
  member  = "serviceAccount:${google_service_account.api_sa.email}"
}

resource "google_project_iam_member" "api_sa_pubsub" {
  project = var.project_id
  role    = "roles/pubsub.publisher"
  member  = "serviceAccount:${google_service_account.api_sa.email}"
}

resource "google_project_iam_member" "api_sa_firestore" {
  project = var.project_id
  role    = "roles/datastore.user"
  member  = "serviceAccount:${google_service_account.api_sa.email}"
}

# -------------------------------
# 4️⃣ Cloud Storage Bucket
# -------------------------------
resource "google_storage_bucket" "assets" {
  name          = "${var.project_id}-genai-assets"
  location      = var.region
  storage_class = "STANDARD"

  uniform_bucket_level_access = true

  lifecycle_rule {
    condition {
      age = 30
    }
    action {
      type = "Delete"
    }
  }

  versioning {
    enabled = true
  }
}

# -------------------------------
# 5️⃣ Pub/Sub
# -------------------------------
resource "google_pubsub_topic" "ingest_topic" {
  name = "genai-ingest-topic"
}

resource "google_pubsub_subscription" "ingest_sub" {
  name  = "genai-ingest-sub"
  topic = google_pubsub_topic.ingest_topic.name
}

# -------------------------------
# 6️⃣ Secret Manager
# -------------------------------
resource "google_secret_manager_secret" "vertex_api_key" {
  project   = var.project_id
  secret_id = "vertex-api-key"

  replication {
    auto {}
  }
}

# Optional: if you want to store the Vertex API key immediately
# (Uncomment below and provide var.vertex_api_key in variables.tf)
#
# resource "google_secret_manager_secret_version" "vertex_api_key_version" {
#   secret      = google_secret_manager_secret.vertex_api_key.id
#   secret_data = var.vertex_api_key
# }

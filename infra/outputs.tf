output "api_service_account_email" {
  description = "Service Account email for GenAI API"
  value       = google_service_account.api_sa.email
}

output "bucket_name" {
  description = "Cloud Storage Bucket for GenAI assets"
  value       = google_storage_bucket.assets.name
}

output "pubsub_topic" {
  description = "Pub/Sub topic for document ingestion"
  value       = google_pubsub_topic.ingest_topic.name
}

output "pubsub_subscription" {
  description = "Pub/Sub subscription for ingestion worker"
  value       = google_pubsub_subscription.ingest_sub.name
}

output "vertex_secret_name" {
  description = "Secret Manager Vertex API Key secret name"
  value       = google_secret_manager_secret.vertex_api_key.name
}

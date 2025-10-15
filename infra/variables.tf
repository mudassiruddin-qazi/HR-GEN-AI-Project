variable "project_id" {
  type        = string
  description = "GCP Project ID"
  default     = "lustrous-drake-412814"
}

variable "region" {
  type        = string
  description = "GCP Region"
  default     = "us-central1"
}

# Optional variable if you want to upload Vertex API key via Terraform
# variable "vertex_api_key" {
#   type        = string
#   description = "Vertex API Key for Generative AI access"
#   sensitive   = true
# }

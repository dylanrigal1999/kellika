variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "europe-west2"
}

variable "github_repo" {
  description = "GitHub repository in owner/name format"
  type        = string
}

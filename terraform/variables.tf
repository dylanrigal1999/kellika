variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "env" {
  description = "Environment name (dev or prod)"
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

variable "tfstate_bucket" {
  description = "GCS bucket name for Terraform state"
  type        = string
}

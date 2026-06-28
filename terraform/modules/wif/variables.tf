variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "env" {
  description = "Environment name (dev or prod)"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository in owner/name format (e.g. dylanrigal1999/kellika)"
  type        = string
}

variable "tfstate_bucket" {
  description = "Name of the GCS bucket used for Terraform state"
  type        = string
}

variable "tf_workflow_name" {
  description = "Name of the Terraform GitHub Actions workflow (must match the workflow's name: field)"
  type        = string
  default     = "Terraform"
}

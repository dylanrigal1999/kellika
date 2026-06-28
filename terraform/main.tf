terraform {
  required_version = ">= 1.9"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

module "wif" {
  source = "./modules/wif"

  project_id     = var.project_id
  env            = var.env
  github_repo    = var.github_repo
  tfstate_bucket = var.tfstate_bucket
}

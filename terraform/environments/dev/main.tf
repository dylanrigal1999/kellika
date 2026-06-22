terraform {
  required_version = ">= 1.9"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }

  backend "gcs" {
    bucket = "kellika-dev-tfstate"
    prefix = "terraform/state"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

module "wif" {
  source = "../../modules/wif"

  project_id     = var.project_id
  env            = "dev"
  github_repo    = var.github_repo
  tfstate_bucket = "kellika-dev-tfstate"
}

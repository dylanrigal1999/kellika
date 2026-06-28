resource "google_iam_workload_identity_pool" "pool" {
  project                   = var.project_id
  workload_identity_pool_id = "kellika-${var.env}-pool"
  display_name              = "Kellika ${var.env} GitHub Actions"
}

resource "google_iam_workload_identity_pool_provider" "github" {
  project                            = var.project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.pool.workload_identity_pool_id
  workload_identity_pool_provider_id = "kellika-${var.env}-github"
  display_name                       = "GitHub Actions"

  attribute_mapping = {
    "google.subject"             = "assertion.sub"
    "attribute.actor"            = "assertion.actor"
    "attribute.repository"       = "assertion.repository"
    "attribute.repository_owner" = "assertion.repository_owner"
    "attribute.ref"              = "assertion.ref"
  }

  attribute_condition = "attribute.repository == '${var.github_repo}'"

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}

resource "google_storage_bucket_iam_member" "tfstate_admin" {
  bucket = var.tfstate_bucket
  role   = "roles/storage.admin"
  member = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.pool.name}/attribute.repository/${var.github_repo}"
}

resource "google_project_iam_member" "wif_workload_identity_admin" {
  project = var.project_id
  role    = "roles/iam.workloadIdentityPoolAdmin"
  member  = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.pool.name}/attribute.repository/${var.github_repo}"
}

resource "google_project_iam_member" "wif_service_usage_admin" {
  project = var.project_id
  role    = "roles/serviceusage.serviceUsageAdmin"
  member  = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.pool.name}/attribute.repository/${var.github_repo}"
}

resource "google_project_iam_member" "wif_project_iam_admin" {
  project = var.project_id
  role    = "roles/resourcemanager.projectIamAdmin"
  member  = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.pool.name}/attribute.repository/${var.github_repo}"
}

# The three google_project_iam_member resources above cannot be applied by CI.
# Attempts consistently failed with googleapi: Error 400: Precondition check failed.,
# failedPrecondition — the exact cause is unclear (possible timing issue with newly
# created WIF pool, org policy, or a GCP restriction on federated identities calling
# setIamPolicy for principalSet:// members).
#
# As a one-time bootstrap step for each environment, the project owner (dylanrigal@gmail.com)
# must apply these locally using personal credentials:
#
#   cd terraform
#   terraform init -backend-config="bucket=kellika-<env>-tfstate" -backend-config="prefix=terraform/state"
#   terraform apply -var-file=environments/<env>.tfvars

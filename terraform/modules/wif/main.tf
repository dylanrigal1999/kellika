resource "google_project_service" "required_apis" {
  for_each = toset([
    "cloudresourcemanager.googleapis.com",
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "sts.googleapis.com",
  ])

  project            = var.project_id
  service            = each.value
  disable_on_destroy = false
}

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

# Project-level IAM bindings for the WIF principal are not managed by Terraform.
# Attempts to manage them via google_project_iam_member consistently failed with
# googleapi: Error 400: Precondition check failed., failedPrecondition — the exact
# cause is unclear (possible timing issue with newly created WIF pool, org policy,
# or a GCP restriction on federated identities calling setIamPolicy for principalSet://
# members). The same bindings applied successfully via gcloud as the project owner.
#
# These must be granted manually by the project owner (dylanrigal@gmail.com)
# as a one-time bootstrap step for each environment:
#
#   PROJECT_NUMBER=$(gcloud projects describe <project-id> --format='value(projectNumber)')
#   WIF_PRINCIPAL="principalSet://iam.googleapis.com/projects/${PROJECT_NUMBER}/locations/global/workloadIdentityPools/kellika-<env>-pool/attribute.repository/dylanrigal1999/kellika"
#
#   gcloud projects add-iam-policy-binding <project-id> --member="${WIF_PRINCIPAL}" --role="roles/iam.workloadIdentityPoolAdmin"
#   gcloud projects add-iam-policy-binding <project-id> --member="${WIF_PRINCIPAL}" --role="roles/serviceusage.serviceUsageAdmin"
#   gcloud projects add-iam-policy-binding <project-id> --member="${WIF_PRINCIPAL}" --role="roles/resourcemanager.projectIamAdmin"

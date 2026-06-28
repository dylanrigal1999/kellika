resource "google_service_account" "kellika_backend_service_account" {
  project      = var.project_id
  account_id   = "kellika-${var.env}-api"
  display_name = "Kellika ${var.env} Backend"
}

resource "google_project_iam_member" "kellika_backend_firestore_access" {
  project = var.project_id
  role    = "roles/datastore.user"
  member  = "serviceAccount:${google_service_account.kellika_backend_service_account.email}"
}

resource "google_service_account_iam_member" "kellika_deploy_sa_user" {
  service_account_id = google_service_account.kellika_backend_service_account.name
  role               = "roles/iam.serviceAccountUser"
  member             = local.deploy_principal_set
}

resource "google_project_iam_member" "kellika_deploy_run_developer" {
  project = var.project_id
  role    = "roles/run.developer"
  member  = local.deploy_principal_set
}

resource "google_cloud_run_v2_service" "kellika_backend_cloud_run_service" {
  project             = var.project_id
  name                = "kellika-${var.env}-api"
  location            = var.region
  deletion_protection = var.env == "prod"

  template {
    service_account = google_service_account.kellika_backend_service_account.email

    containers {
      image = var.docker_image
    }
  }

  depends_on = [google_project_service.apis]
}

resource "google_cloud_run_v2_service_iam_member" "kellika_backend_public_invoker" {
  project  = var.project_id
  location = var.region
  name     = google_cloud_run_v2_service.kellika_backend_cloud_run_service.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

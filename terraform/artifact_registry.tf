resource "google_artifact_registry_repository" "kellika_gar_repository" {
  project       = var.project_id
  location      = var.region
  repository_id = "kellika-${var.env}-api"
  format        = "DOCKER"

  depends_on = [google_project_service.apis]
}

resource "google_artifact_registry_repository_iam_member" "deploy_writer" {
  project    = var.project_id
  location   = var.region
  repository = google_artifact_registry_repository.kellika_gar_repository.name
  role       = "roles/artifactregistry.writer"
  member     = local.deploy_principal_set
}

output "workload_identity_provider" {
  description = "Full resource name of the WIF provider — set as a GitHub Actions variable"
  value       = google_iam_workload_identity_pool_provider.github.name
}

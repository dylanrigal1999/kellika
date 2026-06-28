output "workload_identity_provider" {
  description = "Full resource name of the WIF provider — set as a GitHub Actions variable"
  value       = google_iam_workload_identity_pool_provider.kellika_github_oidc_provider.name
}

output "pool_name" {
  description = "WIF pool resource name — use to construct workflow-specific principal sets in the root module"
  value       = google_iam_workload_identity_pool.kellika_wif_pool.name
}

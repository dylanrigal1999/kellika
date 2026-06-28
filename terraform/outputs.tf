output "workload_identity_provider" {
  description = "WIF provider resource name — set as GitHub Actions variable WIF_PROVIDER_DEV or WIF_PROVIDER_PROD"
  value       = module.wif.workload_identity_provider
}

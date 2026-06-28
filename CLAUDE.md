# Kellika

A shared accountability task app for two users. Users create tasks, mark them complete, and the other user receives a motivating push notification (similar to Duolingo).

## Stack

- **iOS**: SwiftUI
- **Backend**: FastAPI on Cloud Run
- **Database**: Firestore
- **Auth**: Firebase Auth
- **Notifications**: Firebase Cloud Messaging
- **Infrastructure**: Terraform
- **CI/CD**: GitHub Actions with Workload Identity Federation (WIF)

## Project Structure

kellika/
├── terraform/
│   ├── environments/
│   │   ├── dev/
│   │   └── prod/
│   └── modules/
├── backend/
├── ios/
└── .github/workflows/

## GCP

- **Dev project**: `kellika-dev`
- **Prod project**: `kellika-prod`
- **Region**: `europe-west2`
- **GitHub repo**: `dylanrigal1999/kellika`

## Terraform Conventions

- State is stored in GCS — bucket naming: `kellika-{env}-tfstate`
- One directory per environment under `terraform/environments/` — do not use Terraform workspaces
- Do not hardcode project IDs in modules — always use variables
- Do not create service account keys — all CI/CD auth uses WIF
- Do not commit `.tfvars` files containing secrets
- `terraform apply` must only run via GitHub Actions — never apply manually

## Verification

Before committing any Terraform change:
1. `terraform fmt -recursive` — must produce no output
2. `terraform validate` — must pass with no errors
3. `terraform plan` — run locally to review, but never run `terraform apply` locally

`terraform apply` runs automatically via GitHub Actions on merge to `main` (prod) or `dev` branch. If you need to apply manually for any reason, stop and ask the user first.

## Firestore Schema

**`users/{user_id}`**
```
display_name:  string
email:         string
fcm_token:     string
group_id:      string
created_at:    timestamp
```

**`groups/{group_id}`**
```
user_ids:      [uid1, uid2, ...]
created_at:    timestamp
```

**`tasks/{task_id}`**
```
title:         string
owner_id:      string
group_id:      string
completed:     bool
completed_at:  timestamp | null
created_at:    timestamp
```

## Naming Conventions

- GCP resources: `kellika-{env}-{resource}` e.g. `kellika-dev-api`
- GCS state bucket: `kellika-{env}-tfstate`
- Terraform modules: snake_case

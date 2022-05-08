# actions-infra-cicd-sample

## prerequisites
- Create Service Account (1) for Terraform (GCP resources creation & modification)

## Setup

```bash
$ export PROJECT_ID=<gcp_project_id>
$ export WORKLOAD_IDENTITY_POOL_NAME=<pool_name>
$ export WORKLOAD_IDENTITY_PROVIDER_NAME=<provider_name>
$ export GITHUB_REPO=<repository_name> # taxintt/actions-infra-cicd-sample
$ export SA_NAME=<serrvice_account_name> # sa-for-wif-test

# Setup Workload Identity Pool
$ gcloud services enable iamcredentials.googleapis.com --project "${PROJECT_ID}"

$ gcloud iam workload-identity-pools create "${WORKLOAD_IDENTITY_POOL_NAME}" \
    --project="${PROJECT_ID}" \
    --location="global" \
    --display-name="Pool with GitHub OIDC provider"

$ gcloud iam workload-identity-pools providers create-oidc "${WORKLOAD_IDENTITY_PROVIDER_NAME}" \
    --project="${PROJECT_ID}" \
    --location="global" \
    --workload-identity-pool="${WORKLOAD_IDENTITY_POOL_NAME}" \
    --display-name="Provider used with GHA" \
    --attribute-mapping="google.subject=assertion.sub,attribute.repository=assertion.repository,attribute.actor=assertion.actor,attribute.aud=assertion.aud" \
    --issuer-uri="https://token.actions.githubusercontent.com"

# Check WORKLOAD_IDENTITY_POOL_ID
$ export WORKLOAD_IDENTITY_POOL_ID=$( \
    gcloud iam workload-identity-pools describe "${WORKLOAD_IDENTITY_POOL_NAME}" \
        --project="${PROJECT_ID}" \
        --location="global" \
        --format="value(name)" \
  )
$ echo $WORKLOAD_IDENTITY_POOL_ID

# Setup Service Account (This SA (1) runs Terraform commands in the situation that is impersonated)
# FYI: Add some role for Terraform
$ gcloud iam service-accounts create "${SA_NAME}" \
    --project="${PROJECT_ID}" \
    --display-name="Service Account for using WIF test"

$ export SA_EMAIL="${SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"
$ gcloud iam service-accounts add-iam-policy-binding "${SA_EMAIL}" \
    --project="${PROJECT_ID}" \
    --role="roles/iam.workloadIdentityUser" \
    --member="principalSet://iam.googleapis.com/${WORKLOAD_IDENTITY_POOL_ID}/attribute.repository/${GITHUB_REPO}"
```
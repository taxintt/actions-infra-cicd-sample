terraform {
  backend "gcs" {
    bucket = "tfstate-bucket-for-actions-infra-cicd-sample"
    prefix = "prod"
  }

  required_providers {
    google = {
      source  = "hashicorp/null"
      version = "~> 3.1"
    }
  }
}
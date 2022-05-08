terraform {
  backend "gcs" {
    bucket = "tfstate-bucket-for-actions-infra-cicd-sample"
    prefix = "stg"
  }

  required_providers {
    google = {
      source  = "hashicorp/null"
      version = "~> 3.1.1"
    }
  }
}
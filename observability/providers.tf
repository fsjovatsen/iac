terraform {
  required_version = ">=1.0"

  required_providers {
    helm = {
      source = "hashicorp/helm"
    }
    aiven = {
      source  = "aiven/aiven"
      version = ">=4.0.0, < 5.0.0"
    }
  }
}
terraform {
  required_version = ">=1.0"

  required_providers {
    helm = {
      source = "hashicorp/helm"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
    time = {
      source  = "hashicorp/time"
      version = "0.9.1"
    }
    http = {
      source = "http"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
  }
}
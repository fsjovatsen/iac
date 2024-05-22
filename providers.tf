terraform {
  required_version = ">=1.0"

  required_providers {
    #     azapi = {
    #       source  = "azure/azapi"
    #       version = "~>1.5"
    #     }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
    #     azuread = {
    #       source  = "hashicorp/azuread"
    #       version = "~> 2.7.0"
    #     }
    helm = {
      source = "hashicorp/helm"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
    #     random = {
    #       source  = "hashicorp/random"
    #       version = "~>3.0"
    #     }
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
    aiven = {
      source  = "aiven/aiven"
      version = ">=4.0.0, < 5.0.0"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 2.5.0"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "kubernetes" {
  host                   = data.azurerm_kubernetes_cluster.k8s.kube_config.0.host
  client_certificate     = base64decode(data.azurerm_kubernetes_cluster.k8s.kube_config.0.client_certificate)
  client_key             = base64decode(data.azurerm_kubernetes_cluster.k8s.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.k8s.kube_config.0.cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = data.azurerm_kubernetes_cluster.k8s.kube_config.0.host
    client_certificate     = base64decode(data.azurerm_kubernetes_cluster.k8s.kube_config.0.client_certificate)
    client_key             = base64decode(data.azurerm_kubernetes_cluster.k8s.kube_config.0.client_key)
    cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.k8s.kube_config.0.cluster_ca_certificate)
  }
}

provider "aiven" {
  api_token = var.aiven_api_token
}


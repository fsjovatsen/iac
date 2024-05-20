resource "kubernetes_namespace" "cert-man" {
  metadata {
    labels = {
      "cert-manager.io/disable-validation" = "true"
    }

    name = "cert-manager"
  }
}

data "http" "cert_man_crds" {
  url = "https://github.com/cert-manager/cert-manager/releases/download/v1.14.5/cert-manager.crds.yaml"
}

# split raw yaml into individual resources
data "kubectl_file_documents" "cert_man_crds" {
  content = data.http.cert_man_crds.response_body
}

# apply each resource from the yaml one by one
resource "kubectl_manifest" "knative_serving_crds" {
  for_each   = data.kubectl_file_documents.cert_man_crds.manifests
  yaml_body  = each.value
}

resource "helm_release" "cert-man" {
  chart      = "cert-manager"
  name       = "cert-manager"
  namespace  = kubernetes_namespace.cert-man.metadata[0].name
  repository = "https://charts.jetstack.io"
  version    = "v1.14.5"
}

resource "kubernetes_manifest" "cluster-issuer" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name = "letsencrypt-production"
    }
    spec = {
      acme = {
        email  = "test@gmail.com"
        server = "https://acme-v02.api.letsencrypt.org/directory"
        privateKeySecretRef = {

          name = "private-key-secret"
        }
        solvers = [
          {
            http01 = {
              ingress = {
                ingressClassName = "azure-application-gateway"
              }
            }
          }
        ]
      }
    }
  }
}
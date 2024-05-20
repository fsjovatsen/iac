resource "helm_release" "prometheus" {
  chart = "prometheus"
  name  = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  version = "25.21.0"
  values = [file("observability/prometheus-values.yaml")]
  namespace = "observability"
  create_namespace = true
}
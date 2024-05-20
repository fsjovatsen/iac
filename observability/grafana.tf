resource "aiven_grafana" "grafana" {
  project                 = "frode-a20f"
  cloud_name              = "azure-norway-east"
  plan                    = "startup-4"
  service_name            = "grafana-${var.cluster_name}"
  maintenance_window_dow  = "monday"
  maintenance_window_time = "10:00:00"

  grafana_user_config {
    alerting_enabled = true

    public_access {
      grafana = true
    }
  }
}
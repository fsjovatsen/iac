# resource "aiven_opensearch" "opensearch" {
#   project                 = "frode-a20f"
#   cloud_name              = "azure-norway-east"
#   plan                    = "startup-4"
#   service_name            = "open-search-${var.cluster_name}"
#   maintenance_window_dow  = "monday"
#   maintenance_window_time = "10:00:00"
#
#   opensearch_user_config {
#     opensearch_version = 1
#
#     opensearch_dashboards {
#       enabled                    = true
#       opensearch_request_timeout = 30000
#     }
#
#     public_access {
#       opensearch            = true
#       opensearch_dashboards = true
#     }
#   }
# }
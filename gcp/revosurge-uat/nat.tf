# Cloud NAT Configuration

# 获取现有的 revosurge-nat（仅用于信息展示）
data "google_compute_router_nat" "default_revosurge_nat" {
  for_each = var.subnet_configs
  name     = "revosurge-nat"
  router   = "revosurge-router"
  region   = each.value.region
  project  = var.project_id
}

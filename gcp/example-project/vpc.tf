# GCP VPC and Firewall Rules Configuration

# 获取现有 VPC 网络
data "google_compute_network" "current_vpc" {
  name = var.current_vpc_name
}

# 获取所有区域的子网信息
data "google_compute_subnetwork" "subnets" {
  for_each = var.subnet_configs
  name     = each.key
  region   = each.value.region
}

# 创建防火墙规则
resource "google_compute_firewall" "firewall_rules" {
  for_each = var.firewall_rules

  name        = each.value.name
  description = each.value.description
  network     = data.google_compute_network.current_vpc.self_link
  priority    = each.value.priority

  source_ranges = each.value.source_ranges
  target_tags   = each.value.target_tags

  dynamic "allow" {
    for_each = each.value.allow
    content {
      protocol = allow.value.protocol
      ports    = allow.value.ports
    }
  }
}
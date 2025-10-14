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

# 更新现有的 SSH 防火墙规则，添加 algorithm 标签
resource "google_compute_firewall" "revosurge_uat_allow_ssh" {
  name    = "revosurge-uat-allow-ssh"
  network = data.google_compute_network.current_vpc.self_link

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["revosurge-manager", "algorithm"]
}

# 创建防火墙规则 - 允许算法标签的实例进行内部通信
resource "google_compute_firewall" "revosurge_uat_allow_algorithm" {
  name    = "revosurge-uat-allow-algorithm"
  network = data.google_compute_network.current_vpc.self_link

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "icmp"
  }

  priority = "65534"

  # 允许算法子网的内部通信
  source_ranges = [
    for subnet_name, subnet_config in var.subnet_configs : subnet_config.primary_ipv4_range
  ]
  
  target_tags = ["algorithm"]
}
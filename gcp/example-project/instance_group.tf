# GCP Instance Group Configuration

# 创建 Instance Groups
resource "google_compute_instance_group" "instance_groups" {
  for_each = var.instance_groups

  name        = each.value.name
  description = each.value.description
  zone        = each.value.zone
  network     = data.google_compute_network.current_vpc.self_link

  # 添加 VM 实例到 Instance Group
  instances = [
    for instance_key in each.value.instances :
    google_compute_instance.vm_instance[instance_key].self_link
  ]

  # 定义命名端口
  dynamic "named_port" {
    for_each = each.value.named_ports
    content {
      name = named_port.value.name
      port = named_port.value.port
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

# 输出 Instance Group 信息
output "instance_group_info" {
  value = {
    for key, ig in google_compute_instance_group.instance_groups : key => {
      name      = ig.name
      zone      = ig.zone
      self_link = ig.self_link
      size      = ig.size
      instances = ig.instances
      named_ports = [
        for port in ig.named_port : {
          name = port.name
          port = port.port
        }
      ]
    }
  }
  description = "Information about all instance groups"
}

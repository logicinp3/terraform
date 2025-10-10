# GCP VM Instance Configuration

# 创建静态外部 IP（可选）
resource "google_compute_address" "external_ip" {
  name   = "${var.vm_name}-external-ip"
  region = var.region
}

# 创建 VM 实例
resource "google_compute_instance" "vm_instance" {
  name         = var.vm_name
  machine_type = var.vm_machine_type
  zone         = var.zone
  tags         = ["allow-ssh"]

  boot_disk {
    initialize_params {
      image = "${var.vm_image_project}/${var.vm_image_family}"
      size  = 10  # GB
      type  = "pd-standard"
    }
  }

  network_interface {
    network    = google_compute_network.vpc_network.self_link
    subnetwork = google_compute_subnetwork.subnet.self_link

    access_config {
      nat_ip = google_compute_address.external_ip.address
    }
  }

  # 启动脚本（可选）
  metadata_startup_script = <<-EOF
    #!/bin/bash
    echo "Hello, World!" > /var/www/index.html
    apt-get update
    apt-get install -y nginx
    systemctl start nginx
    systemctl enable nginx
  EOF

  # 服务账户设置
  service_account {
    email  = "default"
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }
}

# 输出信息
output "vm_external_ip" {
  value       = google_compute_address.external_ip.address
  description = "The external IP address of the VM instance"
}

output "vm_internal_ip" {
  value       = google_compute_instance.vm_instance.network_interface[0].network_ip
  description = "The internal IP address of the VM instance"
}
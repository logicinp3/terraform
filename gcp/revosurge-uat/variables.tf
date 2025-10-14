# GCP Variables
variable "project_id" {
  description = "The ID of the GCP project"
  type        = string
  default     = "revosurge-uat"
}

variable "project_name" {
  description = "The name of the GCP project"
  type        = string
  default     = "revosurge-uat"
}

# 默认区域和可用区
variable "default_region" {
  description = "The default GCP region"
  type        = string
  default     = "asia-southeast1"
}

variable "default_zone" {
  description = "The default GCP zone"
  type        = string
  default     = "asia-southeast1-a"
}

# 现有 VPC 配置
variable "current_vpc_name" {
  description = "The name of the current VPC network"
  type        = string
  default     = "revosurge-uat"
}

# 多区域子网配置
variable "subnet_configs" {
  description = "Configuration for subnets in different regions"
  type = map(object({
    region             = string
    primary_ipv4_range = string
  }))
  default = {
    "algorithm-ew1" = {
      region             = "europe-west1"
      primary_ipv4_range = "172.20.10.0/24"
    }
    "algorithm-uc1" = {
      region             = "us-central1"
      primary_ipv4_range = "172.20.11.0/24"
    }
    "algorithm-as1" = {
      region             = "asia-southeast1"
      primary_ipv4_range = "172.20.12.0/24"
    }
  }
}

# 多 VM 实例配置 
variable "vm_instances" {
  description = "Configuration for VM instances in different regions"
  type = map(object({
    instances = list(object({
      name          = string
      machine_type  = string
      zone          = string
      image_family  = string
      image_project = string
      disk_size     = number
      disk_type     = string
      network_tags  = list(string)
      network       = string
      subnetwork    = string
    }))
  }))
  default = {
    "europe-west1" = {
      instances = [
        {
          name          = "default-vm"
          machine_type  = "e2-small"
          zone          = "europe-west1-b"
          image_family  = "ubuntu-2204-lts"
          image_project = "ubuntu-os-cloud"
          disk_size     = 20
          disk_type     = "pd-balanced"
          network_tags  = ["algorithm"]
          network       = "revosurge-uat"
          subnetwork    = "algorithm-ew1"
        }
      ]
    }
  }
}

# 网络配置说明
# VM 使用静态外部 IP 地址

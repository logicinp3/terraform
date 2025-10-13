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
    subnet_name = string
    region      = string
    zone        = string
  }))
  default = {
    "asia-southeast1" = {
      subnet_name = "algorithm-as1"
      region      = "asia-southeast1"
      zone        = "asia-southeast1-a"
    }
    "europe-west1" = {
      subnet_name = "algorithm-ew1"
      region      = "europe-west1"
      zone        = "europe-west1-a"
    }
    "us-central1" = {
      subnet_name = "algorithm-uc1"
      region      = "us-central1"
      zone        = "us-central1-a"
    }
  }
}

# VM Instance Configuration
variable "vm_instance" {
  description = "Configuration for the VM instance"
  type = object({
    name         = string
    machine_type = string
    network_tags = list(string)
    labels       = map(string)
    service_account = object({
      email  = string
      scopes = list(string)
    })
  })
  default = {
    name         = "algorithm-vm"
    machine_type = "e2-standard-2"  # Default to standard type, can be overridden
    network_tags = ["algorithm"]
    labels = {
      environment = "uat"
      managed-by  = "terraform"
    }
    service_account = {
      email  = "default"
      scopes = ["cloud-platform"]
    }
  }
}

# VM Disk Configuration
variable "vm_disk" {
  description = "Configuration for the VM boot disk"
  type = object({
    size_gb     = number
    type        = string
    auto_delete = bool
    encryption = object({
      enabled        = bool
      kms_key_self_link = string
    })
  })
  default = {
    size_gb     = 50
    type        = "pd-balanced"
    auto_delete = true
    encryption = {
      enabled        = true
      kms_key_self_link = ""  # Set to use customer-managed encryption key if needed
    }
  }
}

# VM Image Configuration
variable "vm_image" {
  description = "Source image configuration for the VM"
  type = object({
    family  = string
    project = string
  })
  default = {
    family  = "ubuntu-2204-lts"
    project = "ubuntu-os-cloud"
  }
}

# VM Access Configuration
variable "vm_access_config" {
  description = "Configuration for VM access"
  type = object({
    enable_ssh_keys = bool
    metadata_startup_script = string
  })
  default = {
    enable_ssh_keys        = true
    metadata_startup_script = ""
  }
}

# 网络配置说明
# VM 使用静态外部 IP 地址
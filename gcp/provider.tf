# GCP Provider Configuration
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}

provider "google" {
  # 您可以在此处设置凭证文件路径，或者使用环境变量 GOOGLE_CREDENTIALS
  # credentials = file("path/to/credentials.json")
  
  # 项目 ID
  # project = var.project_id
  
  # 区域设置
  # region = var.region
  
  # 可用区设置
  # zone = var.zone
}
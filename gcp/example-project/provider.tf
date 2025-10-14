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
  # 方式1: 使用凭证文件（如果有服务账号密钥文件）
  # credentials = file("path/to/your-service-account-key.json")

  # 方式2: 使用环境变量 GOOGLE_CREDENTIALS
  # export GOOGLE_CREDENTIALS="path/to/your-service-account-key.json"

  # 方式3: 使用 gcloud 应用默认凭证（推荐）
  # 运行: gcloud auth application-default login

  project = var.project_id
  region = var.default_region
  zone = var.default_zone
}

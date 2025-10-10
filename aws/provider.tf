# AWS Provider Configuration
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  # 您可以在此处设置凭证信息，或者使用环境变量 AWS_ACCESS_KEY_ID 和 AWS_SECRET_ACCESS_KEY
  # access_key = var.aws_access_key
  # secret_key = var.aws_secret_key
  
  # 区域设置
  # region = var.region
}
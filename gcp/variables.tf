# GCP Variables
variable "project_id" {
  description = "The ID of the GCP project"
  type        = string
}

variable "region" {
  description = "The GCP region to deploy resources in"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "The GCP zone to deploy resources in"
  type        = string
  default     = "us-central1-a"
}

variable "vpc_name" {
  description = "The name of the VPC network"
  type        = string
  default     = "main-vpc"
}

variable "subnet_name" {
  description = "The name of the subnet"
  type        = string
  default     = "main-subnet"
}

variable "subnet_cidr" {
  description = "The CIDR block for the subnet"
  type        = string
  default     = "10.0.0.0/24"
}

variable "vm_name" {
  description = "The name of the VM instance"
  type        = string
  default     = "instance-1"
}

variable "vm_machine_type" {
  description = "The machine type of the VM instance"
  type        = string
  default     = "e2-medium"
}

variable "vm_image_family" {
  description = "The image family for the VM instance"
  type        = string
  default     = "debian-11"
}

variable "vm_image_project" {
  description = "The project where the VM image is hosted"
  type        = string
  default     = "debian-cloud"
}
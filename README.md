# Terraform Infrastructure as Code

This repository contains Terraform configurations for provisioning infrastructure on Google Cloud Platform (GCP) and Amazon Web Services (AWS).

## Structure

The repository is organized into two main directories:

- `gcp/`: Contains Terraform configurations for GCP resources
- `aws/`: Contains Terraform configurations for AWS resources

## Prerequisites

1. Install Terraform: [Terraform Installation Guide](https://learn.hashicorp.com/tutorials/terraform/install-cli)
2. Set up your cloud provider credentials:
   - For GCP: [Google Cloud Provider Configuration](https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/getting_started)
   - For AWS: [AWS Provider Configuration](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/)

## Usage

### GCP

1. Navigate to the GCP directory:
```bash
cd gcp
```

2. Create a `terraform.tfvars` file with your GCP configuration:
```hcl
project_id = "your-gcp-project-id"
region     = "us-central1"
zone       = "us-central1-a"
# Add other variables as needed
```

3. Initialize Terraform:
```bash
terraform init
```

4. Review the planned changes:
```bash
terraform plan
```

5. Apply the changes:
```bash
terraform apply
```

### AWS

1. Navigate to the AWS directory:
```bash
cd aws
```

2. Create a `terraform.tfvars` file with your AWS configuration:
```hcl
region    = "us-west-2"
key_name  = "your-key-pair-name"
# Update ami_id if needed for your region
# Add other variables as needed
```

3. Initialize Terraform:
```bash
terraform init
```

4. Review the planned changes:
```bash
terraform plan
```

5. Apply the changes:
```bash
terraform apply
```

## Resources

### GCP Resources
- VPC Network
- Subnet
- Firewall Rules
- VM Instance
- Static External IP

### AWS Resources
- VPC
- Public and Private Subnets
- Internet Gateway
- Route Tables
- Security Groups
- EC2 Instance
- Elastic IP

## Clean Up

To destroy the resources created by Terraform, run:
```bash
terraform destroy
```

## Notes
- Always review the planned changes before applying them.
- Ensure you have the necessary permissions in your cloud accounts.
- Be mindful of costs associated with the resources you create.
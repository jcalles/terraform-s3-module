terraform {
  required_version = ">= 1.0.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
  
  # Configure provider with your authentication method
  # This example assumes AWS credentials are configured via AWS CLI, environment variables, or IAM roles
}

module "s3_buckets" {
  source = "../../"
  
  # Required variables
  namespace      = var.namespace
  stage         = var.stage
  aws_region    = var.aws_region
  aws_account_id = var.aws_account_id
  
  # Basic S3 bucket configuration
  buckets = {
    "data" = {
      versioning_enabled = true
      encryption_enabled = true
    }
    "data2" = {
      versioning_enabled = false
      encryption_enabled = false
    }
  }
  
  tags = {
    Environment = var.stage
    Project     = "s3-module-example"
    ManagedBy   = "terraform"
  }
}

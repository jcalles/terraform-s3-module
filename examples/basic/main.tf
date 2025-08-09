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
      # Versioning configuration
      versioning = {
        enabled = true
      }
      # Server-side encryption (enabled by default with AES256)
      server_side_encryption_rule = {
        sse_algorithm = "AES256"
      }
      lifecycle_rules = [
        {
          id      = "default_lifecycle"
          enabled = true
          abort_incomplete_multipart_upload_days = 7
          transition = [
            {
              days          = 30
              storage_class = "STANDARD_IA"
            },
            {
              days          = 90
              storage_class = "GLACIER"
            }
          ]
        }
      ]
    }
    "data2" = {
      # Versioning disabled - no versioning config needed
      # Encryption disabled - override default
      server_side_encryption_rule = {
        sse_algorithm = "AES256"  # Note: encryption is always enabled, this is just explicit
      }
      lifecycle_rules = [
        {
          id      = "cleanup_incomplete_uploads"
          enabled = true
          abort_incomplete_multipart_upload_days = 1
        }
      ]
    }
  }
  
  tags = {
    Environment = var.stage
    Project     = "s3-module-example"
    ManagedBy   = "terraform"
  }
}

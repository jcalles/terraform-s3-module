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
}

module "s3_buckets" {
  source = "../../"
  
  # Required variables
  namespace      = var.namespace
  stage         = var.stage
  aws_region    = var.aws_region
  aws_account_id = var.aws_account_id
  
  # Advanced S3 buckets configuration
  buckets = {
    "data-primary" = {
      # Versioning enabled
      versioning = {
        enabled = true
      }
      # Server-side encryption with AES256
      server_side_encryption_rule = {
        sse_algorithm = "AES256"
      }
      # Lifecycle rules for cost optimization
      lifecycle_rules = [
        {
          id      = "primary_data_lifecycle"
          enabled = true
          transition = [
            {
              days          = 30
              storage_class = "STANDARD_IA"
            },
            {
              days          = 90
              storage_class = "GLACIER"
            },
            {
              days          = 365
              storage_class = "DEEP_ARCHIVE"
            }
          ]
        }
      ]
    }
    "data-backup" = {
      # Versioning enabled for backup integrity
      versioning = {
        enabled = true
      }
      # Server-side encryption
      server_side_encryption_rule = {
        sse_algorithm = "AES256"
      }
      # Lifecycle rules for backup retention
      lifecycle_rules = [
        {
          id      = "backup_lifecycle"
          enabled = true
          transition = [
            {
              days          = 1
              storage_class = "STANDARD_IA"
            },
            {
              days          = 30
              storage_class = "GLACIER"
            }
          ]
          # Keep backup versions for 90 days
          noncurrent_version_expiration = {
            days = 90
          }
        }
      ]
    }
    "logs" = {
      # No versioning needed for logs
      # Encryption enabled by default
      lifecycle_rules = [
        {
          id      = "logs_retention"
          enabled = true
          expiration = {
            days = 90  # Delete logs after 90 days
          }
        }
      ]
    }
    "public-assets" = {
      # Public access enabled
      publicly_accessible = true
      # CORS configuration for web assets
      cors_rule = [
        {
          allowed_methods = ["GET", "HEAD"]
          allowed_origins = ["*"]
          allowed_headers = ["*"]
          max_age_seconds = 3000
        }
      ]
    }
  }
  
  tags = {
    Environment   = var.stage
    Project      = "advanced-s3-example"
    ManagedBy    = "terraform"
    Owner        = "platform-team"
    CostCenter   = "engineering"
  }
}

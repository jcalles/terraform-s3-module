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
      versioning_enabled     = true
      encryption_enabled     = true
      lifecycle_rules_enabled = true
      cors_enabled          = false
    }
    "data-backup" = {
      versioning_enabled     = true
      encryption_enabled     = true
      lifecycle_rules_enabled = true
      storage_class         = "STANDARD_IA"
    }
    "logs" = {
      versioning_enabled     = false
      encryption_enabled     = true
      lifecycle_rules_enabled = true
      log_retention_days    = 90
    }
    "public-assets" = {
      versioning_enabled     = false
      encryption_enabled     = true
      cors_enabled          = true
      public_read_access    = true
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

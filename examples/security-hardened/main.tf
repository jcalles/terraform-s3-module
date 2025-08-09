terraform {
  required_version = ">= 1.0"
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

# Security-hardened S3 configuration example
module "secure_s3_buckets" {
  source = "../../"
  
  # Required variables
  namespace      = var.namespace
  stage         = var.stage
  aws_region    = var.aws_region
  aws_account_id = var.aws_account_id
  
  # Security-first S3 bucket configurations
  buckets = {
    # Enterprise data bucket with full security features
    "enterprise-data" = {
      # Versioning with MFA delete protection
      versioning = {
        enabled    = true
        mfa_delete = "Enabled"  # Requires MFA to delete versions
      }
      # Server-side encryption with KMS
      server_side_encryption_rule = {
        sse_algorithm     = "aws:kms"
        kms_master_key_id = var.kms_key_arn
      }
      
      # Lifecycle management for cost optimization and security
      lifecycle_rules = [
        {
          id      = "enterprise_lifecycle"
          enabled = true
          abort_incomplete_multipart_upload_days = 1  # Clean up incomplete uploads quickly
          
          # Transition strategy for cost optimization
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
          
          # Clean up old versions for compliance
          noncurrent_version_expiration = {
            newer_noncurrent_versions = 3
            noncurrent_days          = 90
          }
        }
      ]
      
      # CORS for secure web access
      cors_configuration = [
        {
          allowed_headers = ["*"]
          allowed_methods = ["GET", "HEAD"]
          allowed_origins = ["https://yourcompany.com"]
          expose_headers  = ["ETag"]
          max_age_seconds = 3000
        }
      ]
      
      # Access logging for audit trail
      access_logging = {
        target_bucket = "${var.namespace}-${var.stage}-${var.aws_region}-audit-logs"
        target_prefix = "access-logs/enterprise-data/"
      }
    }
    
    # Backup bucket with replication
    "backup-data" = {
      # Versioning for backup integrity
      versioning = {
        enabled = true
      }
      # Server-side encryption
      server_side_encryption_rule = {
        sse_algorithm = "AES256"
      }
      
      lifecycle_rules = [
        {
          id      = "backup_lifecycle"
          enabled = true
          abort_incomplete_multipart_upload_days = 7
          
          # Aggressive archiving for backups
          transition = [
            {
              days          = 7
              storage_class = "GLACIER"
            },
            {
              days          = 30
              storage_class = "DEEP_ARCHIVE"
            }
          ]
        }
      ]
      
      # Cross-region replication for disaster recovery
      replication_configuration = {
        role = "arn:aws:iam::${var.aws_account_id}:role/replication-role"
        rules = [
          {
            id       = "replicate_to_dr_region"
            status   = "Enabled"
            priority = 1
            
            destination = {
              bucket        = "arn:aws:s3:::${var.namespace}-${var.stage}-us-west-2-backup-data"
              storage_class = "STANDARD_IA"
            }
          }
        ]
      }
    }
    
    # Audit logs bucket with extended retention
    "audit-logs" = {
      # Versioning for audit integrity
      versioning = {
        enabled = true
      }
      # Server-side encryption for sensitive logs
      server_side_encryption_rule = {
        sse_algorithm = "AES256"
      }
      
      lifecycle_rules = [
        {
          id      = "audit_retention"
          enabled = true
          abort_incomplete_multipart_upload_days = 1
          
          # Long-term retention for compliance
          transition = [
            {
              days          = 90
              storage_class = "GLACIER"
            },
            {
              days          = 2555  # 7 years
              storage_class = "DEEP_ARCHIVE"
            }
          ]
        }
      ]
    }
    
    # Public website bucket (controlled public access)
    "public-website" = {
      # Versioning for website content management
      versioning = {
        enabled = true
      }
      # Server-side encryption even for public content
      server_side_encryption_rule = {
        sse_algorithm = "AES256"
      }
      # Allow controlled public access
      publicly_accessible = true
      
      # Website hosting configuration
      website = {
        index_document = "index.html"
        error_document = "error.html"
      }
      
      lifecycle_rules = [
        {
          id      = "website_cleanup"
          enabled = true
          abort_incomplete_multipart_upload_days = 1
          
          # Clean up old website versions
          noncurrent_version_expiration = {
            newer_noncurrent_versions = 5
            noncurrent_days          = 30
          }
        }
      ]
      
      cors_configuration = [
        {
          allowed_headers = ["*"]
          allowed_methods = ["GET", "HEAD"]
          allowed_origins = ["*"]
          max_age_seconds = 86400
        }
      ]
    }
  }
  
  tags = {
    Environment   = var.stage
    Project      = "s3-security-example"
    ManagedBy    = "terraform"
    SecurityTier = "high"
    Compliance   = "required"
  }
}

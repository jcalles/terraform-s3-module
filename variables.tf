# GENERAL VARIABLES
variable "aws_account_id" {
  description = "The AWS account ID"
  type        = string
}

variable "aws_region" {
  type        = string
  description = "AWS region to deploy resources to"
}

variable "namespace" {
  description = "Namespace (e.g. `yourcompany` or `yourorg`)"
  type        = string
}

variable "stage" {
  type        = string
  description = "Stage/environment (e.g. `dev`, `staging`, `prod`)"
}

variable "tags" {
  type        = map(string)
  description = "Additional tags for all AWS resources"
  default     = {}
}

variable "default_tags" {
  type        = map(string)
  description = "Default tags to apply to all resources"
  default     = {}
}

# MODULE VARIABLES
variable "buckets" {
  description = <<-EOT
    Map of S3 bucket configurations. Each bucket can have the following options:
    
    - bucket_name: (optional) Custom bucket name, defaults to namespace-stage-region-key
    - force_destroy: (optional) Allow bucket deletion when not empty, defaults to false
    - versioning: (optional) Object versioning configuration
      - enabled: Enable versioning (true/false)
      - mfa_delete: Require MFA for version deletion ("Enabled"/"Disabled")
    - server_side_encryption_rule: (optional) Server-side encryption configuration
      - sse_algorithm: Encryption algorithm ("AES256" or "aws:kms")
      - kms_master_key_id: KMS key ARN (required for aws:kms)
      - bucket_key_enabled: Use S3 bucket key for KMS (true/false)
    - publicly_accessible: (optional) Allow public access to bucket, defaults to false
    - abort_incomplete_multipart_upload_days: (optional) Days after which incomplete multipart uploads are aborted, defaults to 7
    - lifecycle_rules: (optional) List of lifecycle rule configurations
    - cors_rule: (optional) List of CORS rule configurations
    - website: (optional) Website hosting configuration
    - replication: (optional) Cross-region replication configuration
    - notifications: (optional) Event notification configurations
    - access_points: (optional) S3 access point configurations
    
    Example:
    {
      "my-bucket" = {
        versioning = {
          enabled = true
        }
        server_side_encryption_rule = {
          sse_algorithm = "AES256"
        }
        abort_incomplete_multipart_upload_days = 3
        lifecycle_rules = [
          {
            id = "delete-old-versions"
            enabled = true
            noncurrent_version_expiration = {
              days = 30
            }
          }
        ]
      }
    }
  EOT
  type        = any
  default     = {}
}

# Advanced Configuration Reference

This document provides comprehensive examples of advanced S3 bucket configurations supported by this module.

## Table of Contents

- [CloudFront Distribution Bucket](#cloudfront-distribution-bucket)
- [Cross-Account Access](#cross-account-access)
- [Custom IAM Policies](#custom-iam-policies)
- [KMS Encryption](#kms-encryption)
- [Lifecycle Management](#lifecycle-management)
- [CORS Configuration](#cors-configuration)
- [S3 Access Points](#s3-access-points)
- [Bucket Replication](#bucket-replication)
- [Public Website Hosting](#public-website-hosting)

## CloudFront Distribution Bucket

For serving content through CloudFront:

```hcl
module "cloudfront_buckets" {
  source = "jcalles/s3/aws"
  
  namespace      = "yourcompany"
  stage         = "prod"
  aws_region    = "us-west-2"
  aws_account_id = "YOUR_ACCOUNT_ID"
  
  buckets = {
    "cdn-assets" = {
      versioning_enabled = false
      encryption_enabled = true
      publicly_accessible = true
      
      # Custom policy for CloudFront access
      policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
          Sid    = "AllowCloudFrontServicePrincipal"
          Effect = "Allow"
          Principal = {
            Service = "cloudfront.amazonaws.com"
          }
          Action   = "s3:GetObject"
          Resource = "arn:aws:s3:::yourcompany-prod-us-west-2-cdn-assets/*"
          Condition = {
            StringEquals = {
              "AWS:SourceArn" = "arn:aws:cloudfront::YOUR_ACCOUNT_ID:distribution/CLOUDFRONT_DISTRIBUTION_ID"
            }
          }
        }]
      })
      
      # CORS for web access
      cors_rule = [{
        allowed_methods = ["GET", "HEAD"]
        allowed_origins = ["https://example.com", "https://www.example.com"]
        allowed_headers = ["*"]
        expose_headers  = ["ETag"]
        max_age_seconds = 3600
      }]
      
      # Public access settings
      public_access_block = {
        block_public_acls       = false
        block_public_policy     = true
        ignore_public_acls      = false
        restrict_public_buckets = true
      }
    }
  }
}
```

## Cross-Account Access

For sharing buckets across AWS accounts:

```hcl
module "shared_buckets" {
  source = "jcalles/s3/aws"
  
  # ... required variables ...
  
  buckets = {
    "shared-data" = {
      versioning_enabled = true
      encryption_enabled = true
      
      # Custom IAM policy for cross-account access
      add_iam_policy_stat = [{
        sid    = "CrossAccountAccess"
        effect = "Allow"
        actions = [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        principals = [{
          type        = "AWS"
          identifiers = ["arn:aws:iam::987654321098:role/CrossAccountRole"]
        }]
      }, {
        sid    = "BucketOwnerControl"
        effect = "Allow"
        actions = ["s3:PutObject"]
        principals = [{
          type        = "AWS"
          identifiers = ["arn:aws:iam::987654321098:role/CrossAccountRole"]
        }]
        conditions = [{
          test     = "StringEquals"
          variable = "s3:x-amz-acl"
          values   = ["bucket-owner-full-control"]
        }]
      }]
    }
  }
}
```

## Custom IAM Policies

For complex permission scenarios:

```hcl
module "secure_buckets" {
  source = "jcalles/s3/aws"
  
  # ... required variables ...
  
  buckets = {
    "secure-data" = {
      versioning_enabled = true
      encryption_enabled = true
      
      # Enable additional security policies
      deny_unencrypted_object_uploads = true
      deny_incorrect_encryption_headers = true
      
      # Custom IAM statements
      add_iam_policy_stat = [{
        sid    = "RequireSSLRequestsOnly"
        effect = "Deny"
        actions = ["s3:*"]
        principals = [{
          type        = "*"
          identifiers = ["*"]
        }]
        conditions = [{
          test     = "Bool"
          variable = "aws:SecureTransport"
          values   = ["false"]
        }]
        resources = [
          "arn:aws:s3:::bucket-name",
          "arn:aws:s3:::bucket-name/*"
        ]
      }]
    }
  }
}
```

## KMS Encryption

For enhanced encryption with customer-managed keys:

```hcl
module "encrypted_buckets" {
  source = "jcalles/s3/aws"
  
  # ... required variables ...
  
  buckets = {
    "sensitive-data" = {
      versioning_enabled = true
      encryption_enabled = true
      
      # KMS encryption configuration
      server_side_encryption_rule = {
        bucket_key_enabled = true
        kms_master_key_id  = "arn:aws:kms:us-west-2:YOUR_ACCOUNT_ID:key/YOUR_KMS_KEY_ID"
        sse_algorithm      = "aws:kms"
      }
    }
  }
}
```

## Lifecycle Management

For automated data archiving and deletion:

```hcl
module "archive_buckets" {
  source = "jcalles/s3/aws"
  
  # ... required variables ...
  
  buckets = {
    "document-archive" = {
      versioning_enabled = true
      encryption_enabled = true
      
      # Lifecycle rules for cost optimization
      lifecycle_rules = [{
        id      = "archive_policy"
        enabled = true
        
        # Move to IA after 30 days
        transition = [{
          days          = 30
          storage_class = "STANDARD_IA"
        }, {
          days          = 90
          storage_class = "GLACIER"
        }, {
          days          = 365
          storage_class = "DEEP_ARCHIVE"
        }]
        
        # Delete after 7 years
        expiration = {
          days = 2555
        }
        
        # Clean up incomplete multipart uploads
        abort_incomplete_multipart_upload = {
          days_after_initiation = 7
        }
        
        # Apply to specific prefix
        filter = {
          prefix = "documents/"
          tags = {
            archive = "true"
          }
        }
      }]
    }
  }
}
```

## CORS Configuration

For web applications requiring cross-origin access:

```hcl
module "web_buckets" {
  source = "jcalles/s3/aws"
  
  # ... required variables ...
  
  buckets = {
    "web-assets" = {
      versioning_enabled = false
      encryption_enabled = true
      publicly_accessible = true
      
      # CORS configuration for web apps
      cors_rule = [{
        allowed_methods = ["GET", "POST", "PUT", "DELETE", "HEAD"]
        allowed_origins = [
          "https://app.example.com",
          "https://staging.example.com",
          "http://localhost:3000"  # Development
        ]
        allowed_headers = [
          "Authorization",
          "Content-Type",
          "x-amz-date",
          "x-amz-content-sha256",
          "x-amz-user-agent"
        ]
        expose_headers = [
          "ETag",
          "x-amz-meta-custom-header"
        ]
        max_age_seconds = 3600
      }]
    }
  }
}
```

## S3 Access Points

For fine-grained access control:

```hcl
module "access_point_buckets" {
  source = "jcalles/s3/aws"
  
  # ... required variables ...
  
  buckets = {
    "data-lake" = {
      versioning_enabled = true
      encryption_enabled = true
      
      # S3 Access Point configuration
      s3_access_point = {
        # Lambda access point for data processing
        aws_lambda = "arn:aws:lambda:us-west-2:YOUR_ACCOUNT_ID:function:DataProcessor:$LATEST"
        
        # Access point policy
        access_point_policy = {
          analytics_team = {
            effect = "Allow"
            actions = [
              "s3:GetObject",
              "s3:ListBucket"
            ]
            resources = [
              "arn:aws:s3:us-west-2:YOUR_ACCOUNT_ID:accesspoint/data-lake/object/*"
            ]
            principals = [{
              type        = "AWS"
              identifiers = ["arn:aws:iam::YOUR_ACCOUNT_ID:role/AnalyticsRole"]
            }]
          }
        }
        
        # Lambda access policy
        lambda_policy = {
          processor = {
            effect = "Allow"
            actions = [
              "s3-object-lambda:GetObject"
            ]
            resources = [
              "arn:aws:s3-object-lambda:us-west-2:YOUR_ACCOUNT_ID:accesspoint/data-processor"
            ]
            principals = [{
              type        = "AWS"
              identifiers = ["arn:aws:iam::YOUR_ACCOUNT_ID:role/LambdaExecutionRole"]
            }]
          }
        }
      }
    }
  }
}
```

## Bucket Replication

For cross-region disaster recovery:

```hcl
module "replicated_buckets" {
  source = "jcalles/s3/aws"
  
  # ... required variables ...
  
  buckets = {
    "primary-data" = {
      versioning_enabled = true
      encryption_enabled = true
      
      # Replication configuration
      replication = {
        role                   = "arn:aws:iam::YOUR_ACCOUNT_ID:role/ReplicationRole"
        destination_bucket     = "your-backup-bucket"
        destination_account_id = "YOUR_ACCOUNT_ID"
        
        rules = [{
          priority                         = 1
          delete_marker_replication_status = "Disabled"
          storage_class                    = "STANDARD_IA"
          destination_kms_key_arn          = "arn:aws:kms:us-west-2:YOUR_ACCOUNT_ID:key/YOUR_DESTINATION_KEY_ID"
          replication_time                 = 15  # minutes
          
          source_selection_criteria = {
            replica_modifications_status     = "Enabled"
            sse_kms_encrypted_objects_status = "Enabled"
          }
          
          # Replicate specific prefix
          filter = {
            prefix = "important/"
          }
        }]
      }
    }
  }
}
```

## Public Website Hosting

For static website hosting:

```hcl
module "website_buckets" {
  source = "jcalles/s3/aws"
  
  # ... required variables ...
  
  buckets = {
    "static-website" = {
      versioning_enabled = false
      encryption_enabled = true
      publicly_accessible = true
      
      # Website configuration
      website = {
        index_document = "index.html"
        error_document = "error.html"
        
        routing_rules = [{
          condition = {
            key_prefix_equals = "docs/"
          }
          redirect = {
            replace_key_prefix_with = "documents/"
          }
        }]
      }
      
      # Public read access
      public_access_block = {
        block_public_acls       = false
        block_public_policy     = false
        ignore_public_acls      = false
        restrict_public_buckets = false
      }
      
      # CORS for website
      cors_rule = [{
        allowed_methods = ["GET", "HEAD"]
        allowed_origins = ["*"]
        max_age_seconds = 3600
      }]
    }
  }
}
```

## Best Practices

### Security
- Always enable encryption
- Use least privilege IAM policies
- Enable versioning for important data
- Block public access unless explicitly needed
- Use VPC endpoints for internal access

### Cost Optimization
- Use appropriate storage classes
- Configure lifecycle rules
- Enable intelligent tiering when appropriate
- Monitor usage with S3 analytics

### Performance
- Use appropriate prefix patterns
- Consider access patterns when designing bucket structure
- Use CloudFront for global distribution
- Implement request rate optimization

### Compliance
- Enable logging and monitoring
- Use KMS for sensitive data
- Implement proper access controls
- Document bucket purposes and retention policies

# Advanced S3 Module Example

This example demonstrates advanced usage of the AWS S3 Terraform module with multiple buckets and different configurations for various use cases.

## What This Example Creates

This example creates four S3 buckets, each optimized for different purposes:

### 1. **Data Primary Bucket** (`data-primary`)
- **Purpose**: Primary data storage for applications
- **Configuration**:
  - ✅ Versioning enabled (data protection)
  - ✅ Encryption enabled (security)
  - ✅ Lifecycle rules enabled (cost optimization)
  - ❌ CORS disabled (internal use only)
- **Use Case**: Application data, user uploads, primary storage

### 2. **Data Backup Bucket** (`data-backup`)
- **Purpose**: Backup and disaster recovery storage
- **Configuration**:
  - ✅ Versioning enabled (backup integrity)
  - ✅ Encryption enabled (security)
  - ✅ Lifecycle rules enabled (automatic archiving)
  - 📦 **Standard-IA storage class** (cost optimization for infrequent access)
- **Use Case**: Database backups, file archives, disaster recovery

### 3. **Logs Bucket** (`logs`)
- **Purpose**: Application and access logs storage
- **Configuration**:
  - ❌ Versioning disabled (logs are immutable)
  - ✅ Encryption enabled (compliance)
  - ✅ Lifecycle rules with **90-day retention**
  - 🗑️ Automatic deletion of old logs
- **Use Case**: Application logs, web server logs, audit trails

### 4. **Public Assets Bucket** (`public-assets`)
- **Purpose**: Public web assets and static content
- **Configuration**:
  - ❌ Versioning disabled (static content)
  - ✅ Encryption enabled (security)
  - ✅ **CORS enabled** for web access
  - 🌐 **Public read access** configured
- **Use Case**: Website assets, CDN content, public downloads

## Architecture Overview

```
┌─────────────────┐    ┌─────────────────┐
│   Application   │    │    Website      │
│                 │    │                 │
└─────────┬───────┘    └─────────┬───────┘
          │                      │
          ▼                      ▼
┌─────────────────┐    ┌─────────────────┐
│  data-primary   │    │  public-assets  │
│  (Standard)     │    │  (Public)       │
│  Versioned      │    │  CORS Enabled   │
└─────────────────┘    └─────────────────┘
          │
          ▼ (backup)
┌─────────────────┐    ┌─────────────────┐
│  data-backup    │    │     logs        │
│  (Standard-IA)  │    │  (90d retention)│
│  Long-term      │    │  Auto-cleanup   │
└─────────────────┘    └─────────────────┘
```

## Cost Optimization Features

- **Storage Classes**: Uses Standard-IA for backup data (lower cost)
- **Lifecycle Rules**: Automatic transitions and deletions
- **Log Retention**: 90-day retention prevents log accumulation
- **Versioning Strategy**: Disabled where not needed to reduce storage costs

## Security Features

- 🔒 **Encryption**: All buckets encrypted by default
- 🛡️ **IAM Policies**: Principle of least privilege
- 🚫 **Public Access**: Explicitly configured only where needed
- 🔐 **Access Points**: Secure access patterns
- 🌐 **CORS**: Controlled cross-origin access

## Usage

1. **Create a `terraform.tfvars` file** with your specific values:
   ```hcl
   namespace      = "yourcompany"
   stage         = "prod"
   aws_region    = "us-west-2"
   aws_account_id = "YOUR_ACCOUNT_ID"
   ```

2. **Initialize and apply**:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## Example Output

```hcl
all_bucket_details = {
  arns = {
    "data-backup" = "arn:aws:s3:::yourcompany-prod-us-west-2-data-backup"
    "data-primary" = "arn:aws:s3:::yourcompany-prod-us-west-2-data-primary"
    "logs" = "arn:aws:s3:::yourcompany-prod-us-west-2-logs"
    "public-assets" = "arn:aws:s3:::yourcompany-prod-us-west-2-public-assets"
  }
  domain_names = {
    "data-backup" = "yourcompany-prod-us-west-2-data-backup.s3.amazonaws.com"
    "data-primary" = "yourcompany-prod-us-west-2-data-primary.s3.amazonaws.com"
    "logs" = "yourcompany-prod-us-west-2-logs.s3.amazonaws.com"
    "public-assets" = "yourcompany-prod-us-west-2-public-assets.s3.amazonaws.com"
  }
  ids = {
    "data-backup" = "yourcompany-prod-us-west-2-data-backup"
    "data-primary" = "yourcompany-prod-us-west-2-data-primary"
    "logs" = "yourcompany-prod-us-west-2-logs"
    "public-assets" = "yourcompany-prod-us-west-2-public-assets"
  }
}
```

## Prerequisites

- AWS CLI configured or appropriate IAM role
- Terraform >= 1.0.0
- AWS permissions for:
  - S3 bucket creation and management
  - IAM policy and role creation
  - S3 access point creation
  - S3 lifecycle configuration

## Cleanup

To destroy all resources:
```bash
terraform destroy
```

⚠️ **Warning**: This will permanently delete all S3 buckets and their contents. Make sure to backup any important data before destroying.

## Next Steps

- Customize bucket configurations for your specific needs
- Add additional buckets by extending the `buckets` map
- Review the [main module documentation](../../README.md) for all available options
- Check out monitoring and alerting setup for your buckets

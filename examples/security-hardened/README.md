# Security-Hardened S3 Configuration Example

This example demonstrates enterprise-grade security configurations for S3 buckets using the terraform-s3-module. It showcases all available security features and best practices.

## Security Features Demonstrated

### 🔒 **Encryption & Access Control**
- **Server-side encryption** enabled for all buckets
- **Versioning** enabled for critical data buckets
- **MFA delete** protection for enterprise data
- **HTTPS-only** access enforced via bucket policies

### 🛡️ **Lifecycle Management**
- **Multipart upload cleanup** (1-7 days) to prevent incomplete upload accumulation
- **Cost-optimized storage transitions** (Standard → IA → Glacier → Deep Archive)
- **Version cleanup** to manage storage costs and compliance
- **Retention policies** aligned with compliance requirements

### 📊 **Monitoring & Compliance**
- **Access logging** for audit trails
- **Cross-region replication** for disaster recovery
- **Compliance-ready retention** (7+ years for audit logs)
- **Security tags** for governance

### 🌐 **Controlled Public Access**
- **Website hosting** with proper CORS configuration
- **Public access** limited to specific use cases
- **Security headers** and origin controls

## Usage

```bash
# Set your AWS account ID
export TF_VAR_aws_account_id="123456789012"

# Initialize and apply
terraform init
terraform plan
terraform apply
```

## Bucket Configurations

| Bucket | Purpose | Security Level | Retention |
|--------|---------|----------------|-----------|
| `enterprise-data` | Critical business data | Maximum | 1+ years |
| `backup-data` | Backup and DR | High | Long-term |
| `audit-logs` | Compliance logs | Maximum | 7+ years |
| `public-website` | Static website | Controlled Public | 30 days |

## Compliance Features

### **Data Retention**
- **Audit logs**: 7+ years (DEEP_ARCHIVE after 7 years)
- **Enterprise data**: 1+ years with version management
- **Backup data**: Aggressive archiving (7 days → Glacier)

### **Security Controls**
- **Incomplete upload cleanup**: 1-7 days maximum
- **Version limits**: Controlled retention of object versions
- **Access patterns**: HTTPS-only with proper CORS
- **Replication**: Cross-region for disaster recovery

### **Cost Optimization**
- **Intelligent tiering**: Automatic transitions based on access patterns
- **Storage classes**: Optimized for each use case
- **Lifecycle rules**: Automatic cleanup and archiving

## Checkov Compliance

This configuration addresses all major Checkov security checks:
- ✅ **CKV_AWS_300**: Multipart upload abort configured
- ✅ **CKV_AWS_18**: Access logging enabled (enterprise bucket)
- ✅ **CKV_AWS_144**: Cross-region replication (backup bucket)
- ✅ **CKV_AWS_21**: Versioning enabled where appropriate
- ✅ **All IAM checks**: Secure policies with least privilege

## Next Steps

1. **Customize retention periods** based on your compliance requirements
2. **Configure replication role** for cross-region backup
3. **Set up CloudWatch alarms** for bucket access monitoring
4. **Integrate with AWS Config** for continuous compliance monitoring

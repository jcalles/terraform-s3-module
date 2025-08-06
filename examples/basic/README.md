# Basic S3 Module Example

This example demonstrates the basic usage of the AWS S3 Terraform module with minimal configuration.

## What This Example Creates

- A single S3 bucket with:
  - Versioning enabled
  - Encryption enabled (AES256 by default)
  - Secure bucket policies (blocks public access)
  - Proper IAM policies for security
  - Consistent naming using the cloudposse label module

## Bucket Created

- **Name**: `{namespace}-{stage}-{region}-data`
- **Example**: `testcompany-dev-us-east-1-data`

## Usage

1. **Set your AWS credentials** (via AWS CLI, environment variables, or IAM roles)

2. **Create a `terraform.tfvars` file** with your specific values:
   ```hcl
   namespace      = "yourcompany"
   stage         = "dev"
   aws_region    = "us-west-2"
   aws_account_id = "YOUR_ACCOUNT_ID"
   ```

3. **Initialize and apply**:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## Prerequisites

- **AWS CLI configured** or appropriate IAM role
- **Terraform >= 1.0.0**
- **AWS permissions** to create:
  - S3 buckets and configurations
  - IAM policies
  - S3 access points (if configured)

## Outputs

After successful deployment, you'll get:
- **bucket_ids**: Map of bucket names to their IDs
- **bucket_arns**: Map of bucket names to their ARNs
- **bucket_domain_names**: Map of bucket names to their domain names
- **access_points**: Map of access point configurations

## Example Output
```
bucket_ids = {
  "data" = "yourcompany-dev-us-west-2-data"
}
bucket_arns = {
  "data" = "arn:aws:s3:::yourcompany-dev-us-west-2-data"
}
bucket_domain_names = {
  "data" = "yourcompany-dev-us-west-2-data.s3.amazonaws.com"
}
```

## Cleanup

To destroy the resources:
```bash
terraform destroy
```

## Next Steps

- Check out the [Advanced Example](../advanced/) for multi-bucket configurations
- Review the [main module documentation](../../README.md) for all available options

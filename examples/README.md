# AWS S3 Terraform Module Examples

This directory contains examples demonstrating different use cases for the AWS S3 Terraform module.

## Available Examples

### [Basic Example](./basic/)
Demonstrates the simplest usage of the module:
- Single S3 bucket creation
- Basic security configurations
- Essential IAM policies
- Standard encryption and versioning

**Use this example when you need:**
- Simple S3 bucket setup
- Learning the module basics
- Minimal configuration requirements

### [Advanced Example](./advanced/)
Demonstrates complex multi-bucket scenarios:
- Multiple S3 buckets with different purposes
- Advanced lifecycle management
- CORS configuration for web assets
- Different storage classes for cost optimization
- Comprehensive tagging strategies

**Use this example when you need:**
- Multiple buckets with different configurations
- Cost optimization strategies
- Public asset hosting
- Log storage with retention policies

### [Configuration Reference](./CONFIGURATION.md)
Comprehensive guide covering advanced configurations:
- CloudFront integration
- Cross-account access
- Custom IAM policies
- KMS encryption
- Lifecycle management
- CORS configuration
- S3 Access Points
- Bucket replication
- Website hosting

**Use this reference when you need:**
- Advanced security configurations
- Complex access patterns
- Integration with other AWS services
- Enterprise-grade setups

## Getting Started

1. Choose the example that best fits your use case
2. Navigate to the example directory
3. Create a `terraform.tfvars` file with your specific values
4. Customize the variables for your environment
5. Run `terraform init`, `terraform plan`, and `terraform apply`

## Prerequisites

All examples require:
- AWS CLI configured or appropriate IAM credentials
- Terraform >= 1.0.0
- Appropriate AWS permissions for S3 and IAM resources

## Common Variables

Most examples use these common variables:
- `namespace`: Your organization identifier
- `stage`: Environment name (dev, staging, prod)
- `aws_region`: AWS region for resource deployment
- `aws_account_id`: Your AWS account ID

## Support

For questions about configurations:
- Check the [Configuration Reference](./CONFIGURATION.md)
- Review the [main module documentation](../README.md)
- Open an issue on GitHub

## Resources

No resources.
<!-- END_AUTOMATED_TF_DOCS_BLOCK -->
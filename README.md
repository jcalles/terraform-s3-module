# AWS S3 Terraform Module

[![Terraform Registry](https://img.shields.io/badge/terraform-registry-blue.svg)](https://registry.terraform.io/modules/jcalles/s3/aws)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Latest Release](https://img.shields.io/github/v/release/jcalles/terraform-s3-module)](https://github.com/jcalles/terraform-s3-module/releases)

A comprehensive Terraform module for creating and managing AWS S3 buckets with advanced security, lifecycle management, and access control features.

## Features

- 🔒 **Security First**: Encryption by default, secure bucket policies, and IAM integration
- 📦 **Multi-Bucket Support**: Create and manage multiple S3 buckets with different configurations
- 🔄 **Lifecycle Management**: Automated object transitions and deletion policies
- 🌐 **Access Control**: Support for bucket policies, access points, and CORS configuration
- 🏷️ **Consistent Naming**: Integration with cloudposse/terraform-null-label for standardized resource naming
- 📊 **Monitoring Ready**: CloudTrail and CloudWatch integration capabilities
- 🔧 **Highly Configurable**: Extensive customization options for different use cases

## Quick Start

```hcl
module "s3_buckets" {
  source = "jcalles/s3/aws"
  version = "~> 1.0"
  
  namespace      = "yourcompany"
  stage         = "prod"
  aws_region    = "us-west-2"
  aws_account_id = "YOUR_ACCOUNT_ID"
  
  buckets = {
    "data" = {
      versioning_enabled = true
      encryption_enabled = true
    }
    "logs" = {
      versioning_enabled = false
      lifecycle_rules_enabled = true
    }
  }
  
  tags = {
    Environment = "production"
    Project     = "web-app"
  }
}
```

## Common Use Cases

### 1. Static Website Hosting
```hcl
module "website_buckets" {
  source = "jcalles/s3/aws"
  
  # ... required variables ...
  
  buckets = {
    "website" = {
      versioning_enabled = false
      encryption_enabled = true
      cors_enabled      = true
      publicly_accessible = true
      cors_rule = [{
        allowed_methods = ["GET", "HEAD"]
        allowed_origins = ["https://example.com"]
        allowed_headers = ["*"]
      }]
    }
  }
}
```

### 2. Data Lake Storage
```hcl
module "datalake_buckets" {
  source = "jcalles/s3/aws"
  
  # ... required variables ...
  
  buckets = {
    "raw-data" = {
      versioning_enabled = true
      encryption_enabled = true
      lifecycle_rules_enabled = true
      storage_class = "STANDARD"
    }
    "processed-data" = {
      versioning_enabled = true
      encryption_enabled = true
      lifecycle_rules_enabled = true
      storage_class = "STANDARD_IA"
    }
    "archived-data" = {
      versioning_enabled = true
      encryption_enabled = true
      lifecycle_rules_enabled = true
      storage_class = "GLACIER"
    }
  }
}
```

### 3. Application Logs
```hcl
module "logging_buckets" {
  source = "jcalles/s3/aws"
  
  # ... required variables ...
  
  buckets = {
    "app-logs" = {
      versioning_enabled = false
      encryption_enabled = true
      lifecycle_rules_enabled = true
      log_retention_days = 30
    }
    "access-logs" = {
      versioning_enabled = false
      encryption_enabled = true
      lifecycle_rules_enabled = true
      log_retention_days = 90
    }
  }
}
```

## Examples

- **[Basic Usage](./examples/basic/)** - Simple S3 bucket with standard security
- **[Advanced Configuration](./examples/advanced/)** - Multiple buckets with different purposes and configurations
- **[Configuration Reference](./examples/CONFIGURATION.md)** - Comprehensive guide for complex scenarios

## Configuration Options

### Bucket Configuration

Each bucket in the `buckets` variable supports the following options:

```hcl
buckets = {
  "bucket-name" = {
    # Versioning
    versioning_enabled = true/false
    
    # Encryption
    encryption_enabled = true/false
    server_side_encryption_rule = {
      sse_algorithm     = "AES256" # or "aws:kms"
      kms_master_key_id = "alias/aws/s3" # for KMS encryption
      bucket_key_enabled = true/false
    }
    
    # Lifecycle Management
    lifecycle_rules_enabled = true/false
    log_retention_days     = 90 # for log buckets
    
    # Access Control
    publicly_accessible = true/false
    cors_enabled        = true/false
    cors_rule = [{
      allowed_methods = ["GET", "POST"]
      allowed_origins = ["*"]
      allowed_headers = ["*"]
      max_age_seconds = 3600
    }]
    
    # Advanced Options
    force_destroy = true/false
    bucket_name   = "custom-bucket-name" # Override default naming
    
    # Storage Class
    storage_class = "STANDARD" # STANDARD, STANDARD_IA, etc.
    
    # Public Access
    public_read_access = true/false
    
    # Custom IAM Policies
    policy = "custom-iam-policy-json"
    add_iam_policy_stat = [
      {
        sid    = "CustomStatement"
        effect = "Allow"
        # ... custom policy statements
      }
    ]
  }
}
```

### Security Features

- **Encryption by Default**: All buckets are encrypted by default
- **Public Access Block**: Blocks public access unless explicitly enabled
- **Secure Transport**: Denies insecure HTTP connections
- **Latest TLS**: Requires TLS 1.2 or higher
- **Custom Policies**: Support for additional IAM policy statements

### Naming Convention

Bucket names follow the pattern: `{namespace}-{stage}-{aws_region}-{bucket_key}`

Example: `yourcompany-prod-us-west-2-data`

<!-- BEGIN_TF_DOCS -->


## Usage

Basic usage of this module is as follows:

```hcl
module "s3_buckets" {
  source = "jcalles/s3/aws"
  version = "~> 1.0"
  
  # Required variables
  namespace      = "yourcompany"
  stage         = "dev"
  aws_region    = "us-west-2"
  aws_account_id = "YOUR_ACCOUNT_ID"
  
  # S3 buckets configuration
  buckets = {
    "data" = {
      versioning_enabled = true
      encryption_enabled = true
    }
    "logs" = {
      versioning_enabled = false
      lifecycle_rules_enabled = true
    }
  }
  
  tags = {
    Environment = "development"
    Project     = "example"
  }
}
```

## Examples

- [Basic Usage](./examples/basic/) - Simple S3 bucket creation
- [Advanced Usage](./examples/advanced/) - Multiple buckets with custom configurations

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_label"></a> [label](#module\_label) | git::https://github.com/cloudposse/terraform-null-label.git | tags/0.25.0 |

## Resources

| Name | Type |
|------|------|
| [aws_s3_access_point.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_access_point) | resource |
| [aws_s3_bucket.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_acl.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl) | resource |
| [aws_s3_bucket_cors_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_cors_configuration) | resource |
| [aws_s3_bucket_lifecycle_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_ownership_controls.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_ownership_controls) | resource |
| [aws_s3_bucket_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_replication_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_replication_configuration) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_s3control_access_point_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3control_access_point_policy) | resource |
| [aws_s3control_object_lambda_access_point.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3control_object_lambda_access_point) | resource |
| [aws_s3control_object_lambda_access_point_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3control_object_lambda_access_point_policy) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_canonical_user_id.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/canonical_user_id) | data source |
| [aws_iam_policy_document.additional_statements](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.combined](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.deny_incorrect_encryption_headers](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.deny_insecure_transport](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.deny_unencrypted_object_uploads](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.lambda_endpoint_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.public_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.require_latest_tls](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.s3_endpoint_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.s3_interface_enpoint](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_account_id"></a> [aws\_account\_id](#input\_aws\_account\_id) | The AWS account ID | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region to deploy resources to | `string` | n/a | yes |
| <a name="input_buckets"></a> [buckets](#input\_buckets) | Map of S3 bucket configurations | `any` | `{}` | no |
| <a name="input_default_tags"></a> [default\_tags](#input\_default\_tags) | Default tags to apply to all resources | `map(string)` | `{}` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace (e.g. `yourcompany` or `yourorg`) | `string` | n/a | yes |
| <a name="input_stage"></a> [stage](#input\_stage) | Stage/environment (e.g. `dev`, `staging`, `prod`) | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags for all AWS resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_buckets_access_point"></a> [buckets\_access\_point](#output\_buckets\_access\_point) | Access points for the created S3 buckets |
| <a name="output_buckets_arns"></a> [buckets\_arns](#output\_buckets\_arns) | ARNs of the created S3 buckets |
| <a name="output_buckets_domain_names"></a> [buckets\_domain\_names](#output\_buckets\_domain\_names) | Domain names of the created S3 buckets |
| <a name="output_buckets_ids"></a> [buckets\_ids](#output\_buckets\_ids) | IDs of the created S3 buckets |
| <a name="output_object_lambda_access_point_alias"></a> [object\_lambda\_access\_point\_alias](#output\_object\_lambda\_access\_point\_alias) | Aliases for object lambda access points |
<!-- END_TF_DOCS -->

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

### Development

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Run tests and validate with `terraform fmt` and `terraform validate`
5. Commit your changes (`git commit -m 'Add amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

### Testing

Before submitting changes, please test your modifications:

```bash
# Format code
terraform fmt -recursive

# Validate configuration
terraform validate

# Test with real AWS resources (optional)
cd examples/basic
terraform init
terraform plan
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [CloudPosse](https://github.com/cloudposse) for the excellent terraform-null-label module
- [Terraform Registry](https://registry.terraform.io/) for hosting and distribution
- AWS documentation and best practices

## Support

If you find this module useful, please consider:
- ⭐ Starring the repository
- 🐛 Reporting issues
- 💡 Suggesting improvements
- 📝 Contributing documentation

For questions and support, please use GitHub Issues.
## Resources

| Name | Type |
|------|------|
| [aws_s3_access_point.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_access_point) | resource |
| [aws_s3_bucket.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_acl.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl) | resource |
| [aws_s3_bucket_cors_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_cors_configuration) | resource |
| [aws_s3_bucket_lifecycle_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_ownership_controls.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_ownership_controls) | resource |
| [aws_s3_bucket_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_replication_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_replication_configuration) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_s3control_access_point_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3control_access_point_policy) | resource |
| [aws_s3control_object_lambda_access_point.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3control_object_lambda_access_point) | resource |
| [aws_s3control_object_lambda_access_point_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3control_object_lambda_access_point_policy) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_canonical_user_id.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/canonical_user_id) | data source |
| [aws_iam_policy_document.additional_statements](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.combined](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.deny_incorrect_encryption_headers](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.deny_insecure_transport](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.deny_unencrypted_object_uploads](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.imperva_bucket_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.imperva_list_bucket_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.lambda_endpoint_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.public_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.require_latest_tls](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.s3_endpoint_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.s3_interface_enpoint](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [curl_curl.getips](https://registry.terraform.io/providers/anschoewe/curl/latest/docs/data-sources/curl) | data source |
| [terraform_remote_state.network](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |
| [utils_deep_merge_json.policy](https://registry.terraform.io/providers/cloudposse/utils/latest/docs/data-sources/deep_merge_json) | data source |
<!-- END_AUTOMATED_TF_DOCS_BLOCK -->
<!-- BEGIN_TF_DOCS -->


## Usage

Basic usage of this module is as follows:

```hcl
module "s3_buckets" {
  source = "jcalles/s3/aws"
  version = "~> 1.0"
  
  # Required variables
  namespace      = "yourcompany"
  stage         = "dev"
  aws_region    = "us-west-2"
  aws_account_id = "YOUR_ACCOUNT_ID"
  
  # S3 buckets configuration
  buckets = {
    "data" = {
      versioning_enabled = true
      encryption_enabled = true
    }
    "logs" = {
      versioning_enabled = false
      lifecycle_rules_enabled = true
    }
  }
  
  tags = {
    Environment = "development"
    Project     = "example"
  }
}
```

## Examples

- [Basic Usage](./examples/basic/) - Simple S3 bucket creation
- [Advanced Usage](./examples/advanced/) - Multiple buckets with custom configurations

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_label"></a> [label](#module\_label) | git::https://github.com/cloudposse/terraform-null-label.git | tags/0.25.0 |

## Resources

| Name | Type |
|------|------|
| [aws_s3_access_point.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_access_point) | resource |
| [aws_s3_bucket.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_acl.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl) | resource |
| [aws_s3_bucket_cors_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_cors_configuration) | resource |
| [aws_s3_bucket_lifecycle_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_ownership_controls.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_ownership_controls) | resource |
| [aws_s3_bucket_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_replication_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_replication_configuration) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_s3control_access_point_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3control_access_point_policy) | resource |
| [aws_s3control_object_lambda_access_point.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3control_object_lambda_access_point) | resource |
| [aws_s3control_object_lambda_access_point_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3control_object_lambda_access_point_policy) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_canonical_user_id.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/canonical_user_id) | data source |
| [aws_iam_policy_document.additional_statements](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.combined](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.deny_incorrect_encryption_headers](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.deny_insecure_transport](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.deny_unencrypted_object_uploads](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.lambda_endpoint_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.public_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.require_latest_tls](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.s3_endpoint_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.s3_interface_enpoint](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_account_id"></a> [aws\_account\_id](#input\_aws\_account\_id) | The AWS account ID | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region to deploy resources to | `string` | n/a | yes |
| <a name="input_buckets"></a> [buckets](#input\_buckets) | Map of S3 bucket configurations | `any` | `{}` | no |
| <a name="input_default_tags"></a> [default\_tags](#input\_default\_tags) | Default tags to apply to all resources | `map(string)` | `{}` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace (e.g. `mycompany` or `myorg`) | `string` | n/a | yes |
| <a name="input_stage"></a> [stage](#input\_stage) | Stage/environment (e.g. `dev`, `staging`, `prod`) | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags for all AWS resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_buckets_access_point"></a> [buckets\_access\_point](#output\_buckets\_access\_point) | n/a |
| <a name="output_buckets_arns"></a> [buckets\_arns](#output\_buckets\_arns) | n/a |
| <a name="output_buckets_domain_names"></a> [buckets\_domain\_names](#output\_buckets\_domain\_names) | n/a |
| <a name="output_buckets_ids"></a> [buckets\_ids](#output\_buckets\_ids) | n/a |
| <a name="output_object_lambda_access_point_alias"></a> [object\_lambda\_access\_point\_alias](#output\_object\_lambda\_access\_point\_alias) | n/a |
<!-- END_TF_DOCS -->
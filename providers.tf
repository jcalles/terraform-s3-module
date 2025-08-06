# Provider configuration for the S3 module
# This file contains the provider setup that will be used by consuming modules

provider "aws" {
  
  default_tags {
    tags = merge(
      var.default_tags,
      var.tags
    )
  }
}


variable "namespace" {
  description = "Namespace (e.g. `yourcompany` or `yourcompany-platform`)"
  type        = string
  default     = "advanced-example"
}

variable "stage" {
  description = "Stage/environment name (e.g. `dev`, `staging`, `prod`)"
  type        = string
  default     = "prod"
}

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-west-2"
}

variable "aws_account_id" {
  description = "AWS Account ID"
  type        = string
  # No default - must be provided
}

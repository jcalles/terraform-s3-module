variable "namespace" {
  description = "Namespace (e.g. `yourcompany` or `yourorg`)"
  type        = string
  default     = "security"
}

variable "stage" {
  type        = string
  description = "Stage/environment (e.g. `dev`, `staging`, `prod`)"
  default     = "prod"
}

variable "aws_region" {
  type        = string
  description = "AWS region to deploy resources to"
  default     = "us-east-1"
}

variable "aws_account_id" {
  description = "The AWS account ID"
  type        = string
  # No default - must be provided
}

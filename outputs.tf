output "buckets_arns" {
  description = "ARNs of the created S3 buckets"
  value       = { for key, value in aws_s3_bucket.this : key => value.arn }
}

output "buckets_domain_names" {
  description = "Domain names of the created S3 buckets"
  value       = { for key, value in aws_s3_bucket.this : key => value.bucket_domain_name }
}

output "buckets_ids" {
  description = "IDs of the created S3 buckets"
  value       = { for key, value in aws_s3_bucket.this : key => value.id }
}

output "buckets_access_point" {
  description = "Access points for the created S3 buckets"
  value       = { for key, value in aws_s3_access_point.this : key => value.arn }
}

output "object_lambda_access_point_alias" {
  description = "Aliases for object lambda access points"
  value       = { for key, value in aws_s3control_object_lambda_access_point.this : key => value.alias }
}
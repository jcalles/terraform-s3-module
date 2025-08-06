output "bucket_ids" {
  description = "IDs of the created S3 buckets"
  value       = module.s3_buckets.buckets_ids
}

output "bucket_arns" {
  description = "ARNs of the created S3 buckets"
  value       = module.s3_buckets.buckets_arns
}

output "bucket_domain_names" {
  description = "Domain names of the created S3 buckets"
  value       = module.s3_buckets.buckets_domain_names
}

output "access_points" {
  description = "Access points for the created S3 buckets"
  value       = module.s3_buckets.buckets_access_point
}

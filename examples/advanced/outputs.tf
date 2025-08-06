output "all_bucket_details" {
  description = "Complete details of all created S3 buckets"
  value = {
    ids          = module.s3_buckets.buckets_ids
    arns         = module.s3_buckets.buckets_arns
    domain_names = module.s3_buckets.buckets_domain_names
    access_points = module.s3_buckets.buckets_access_point
  }
}

output "primary_data_bucket" {
  description = "Details of the primary data bucket"
  value = {
    id   = lookup(module.s3_buckets.buckets_ids, "data-primary", "")
    arn  = lookup(module.s3_buckets.buckets_arns, "data-primary", "")
    name = lookup(module.s3_buckets.buckets_domain_names, "data-primary", "")
  }
}

output "backup_data_bucket" {
  description = "Details of the backup data bucket"
  value = {
    id   = lookup(module.s3_buckets.buckets_ids, "data-backup", "")
    arn  = lookup(module.s3_buckets.buckets_arns, "data-backup", "")
    name = lookup(module.s3_buckets.buckets_domain_names, "data-backup", "")
  }
}

output "logs_bucket" {
  description = "Details of the logs bucket"
  value = {
    id   = lookup(module.s3_buckets.buckets_ids, "logs", "")
    arn  = lookup(module.s3_buckets.buckets_arns, "logs", "")
    name = lookup(module.s3_buckets.buckets_domain_names, "logs", "")
  }
}

output "public_assets_bucket" {
  description = "Details of the public assets bucket"
  value = {
    id   = lookup(module.s3_buckets.buckets_ids, "public-assets", "")
    arn  = lookup(module.s3_buckets.buckets_arns, "public-assets", "")
    name = lookup(module.s3_buckets.buckets_domain_names, "public-assets", "")
  }
}

output "bucket_details" {
  description = "Details of all created S3 buckets"
  value = {
    bucket_names        = module.secure_s3_buckets.bucket_names
    bucket_arns        = module.secure_s3_buckets.bucket_arns
    bucket_domains     = module.secure_s3_buckets.bucket_domain_names
    website_endpoints  = module.secure_s3_buckets.bucket_website_endpoints
    hosted_zone_ids    = module.secure_s3_buckets.bucket_hosted_zone_ids
  }
}

output "security_features" {
  description = "Summary of security features enabled"
  value = {
    encryption_enabled    = "All buckets use server-side encryption"
    versioning_enabled    = "Enterprise and backup buckets have versioning"
    lifecycle_management  = "All buckets have lifecycle rules with multipart upload cleanup"
    access_logging       = "Enterprise bucket has access logging enabled"
    replication          = "Backup bucket has cross-region replication"
    public_access_control = "Public access is controlled and limited to website bucket only"
  }
}

output "compliance_notes" {
  description = "Compliance and security notes"
  value = {
    multipart_cleanup    = "All buckets clean up incomplete multipart uploads within 1-7 days"
    data_retention      = "Audit logs retained for 7+ years, enterprise data for 1+ year"
    encryption_at_rest  = "All buckets use AES-256 encryption"
    encryption_in_transit = "HTTPS-only access enforced via bucket policies"
    access_controls     = "Least-privilege access with IAM integration"
  }
}

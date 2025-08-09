data "aws_caller_identity" "current" {}

module "label" {
  source    = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.25.0"
  namespace = var.namespace
  stage     = var.stage
  tags      = var.tags
}

data "aws_canonical_user_id" "this" {}



resource "aws_s3_bucket" "this" {
  for_each      = { for key, value in var.buckets : key => value }
  bucket        = lookup(each.value, "bucket_name", "${var.namespace}-${var.stage}-${var.aws_region}-${each.key}")
  force_destroy = lookup(each.value, "force_destroy", false)
  lifecycle {
    ignore_changes = [
      server_side_encryption_configuration,
      lifecycle_rule
    ]
  }
}
resource "aws_s3_bucket_ownership_controls" "this" {
  for_each = { for key, value in var.buckets : key => value }
  bucket   = aws_s3_bucket_policy.this[each.key].id
  rule {
    object_ownership = length(local.control_object_ownership) > 0 && length(try(lookup(each.value, "bucket_ownership"), [])) > 0 ? lookup(each.value, "bucket_ownership") : try(each.value.publicly_accessible, []) == true ? "BucketOwnerPreferred" : "BucketOwnerEnforced"
  }
  depends_on = [
    aws_s3_bucket_policy.this,
    aws_s3_bucket_public_access_block.this,
    aws_s3_bucket.this
  ]
}
resource "aws_s3_bucket_public_access_block" "this" {
  for_each                = { for key, value in var.buckets : key => value }
  bucket                  = lookup(each.value, "bucket_name", "${var.namespace}-${var.stage}-${var.aws_region}-${each.key}")
  block_public_acls       = try(each.value.publicly_accessible, []) == true ? false : try(each.value.public_access_block.block_public_acls, true)
  block_public_policy     = try(each.value.publicly_accessible, []) == true ? false : try(each.value.public_access_block.block_public_policy, true)
  ignore_public_acls      = try(each.value.publicly_accessible, []) == true ? false : try(each.value.public_access_block.ignore_public_acls, true)
  restrict_public_buckets = try(each.value.publicly_accessible, []) == true ? false : try(each.value.public_access_block.restrict_public_buckets, true)
  depends_on = [
    aws_s3_bucket.this
  ]
}
resource "aws_s3_bucket_policy" "this" {
  for_each = { for key, value in var.buckets : key => value }
  bucket   = lookup(each.value, "bucket_name", "${var.namespace}-${var.stage}-${var.aws_region}-${each.key}")
  policy   = try(each.value.policy, null) != null ? each.value.policy : data.aws_iam_policy_document.combined[each.key].json

  depends_on = [
    aws_s3_bucket_public_access_block.this,
    data.aws_iam_policy_document.combined
  ]
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  for_each              = { for key, value in var.buckets : key => value }
  bucket                = lookup(each.value, "bucket_name", "${var.namespace}-${var.stage}-${var.aws_region}-${each.key}")
  expected_bucket_owner = var.aws_account_id

  rule {
    bucket_key_enabled = try(each.value.server_side_encryption_rule["bucket_key_enabled"], false)
    apply_server_side_encryption_by_default {
        sse_algorithm = try(each.value.server_side_encryption_rule["sse_algorithm"], "AES256")
        kms_master_key_id = try(each.value.server_side_encryption_rule["kms_master_key_id"], null)
    }
  }
}

resource "aws_s3_bucket_cors_configuration" "this" {
  for_each              = { for key, value in var.buckets : key => value if length(try(value.cors_rule, [])) > 0 }
  bucket                = lookup(each.value, "bucket_name", "${var.namespace}-${var.stage}-${var.aws_region}-${each.key}")
  expected_bucket_owner = var.aws_account_id
  dynamic "cors_rule" {
    for_each = try(each.value.cors_rule, [])
    content {
      id              = try(cors_rule.value.id, null)
      allowed_methods = cors_rule.value.allowed_methods
      allowed_origins = cors_rule.value.allowed_origins
      allowed_headers = try(cors_rule.value.allowed_headers, null)
      expose_headers  = try(cors_rule.value.expose_headers, null)
      max_age_seconds = try(cors_rule.value.max_age_seconds, null)
    }
  }
  depends_on = [
    aws_s3_bucket.this
  ]
}

resource "aws_s3_bucket_acl" "this" {
  for_each              = { for key, value in var.buckets : key => value if try(local.control_object_ownership, false) == true }
  bucket                = lookup(each.value, "bucket_name", "${var.namespace}-${var.stage}-${var.aws_region}-${each.key}")
  expected_bucket_owner = var.aws_account_id
  acl                   = try(each.value.publicly_accessible, []) == true ? "public-read" : try(lookup(each.value, "acl", "private"), [])
  depends_on            = [aws_s3_bucket_ownership_controls.this]
}


resource "aws_s3_bucket_versioning" "this" {
  for_each = {
    for key, value in var.buckets :
    key => value
    if length(try(value.versioning, [])) > 0
  }
  bucket                = lookup(each.value, "bucket_name", "${var.namespace}-${var.stage}-${var.aws_region}-${each.key}")
  expected_bucket_owner = try(each.value.versioning["expected_bucket_owner_enabled"], true) ? var.aws_account_id : null
  mfa                   = try(each.value.versioning["mfa"], null)

  versioning_configuration {
    # Valid values: "Enabled" or "Suspended"
    status = try(each.value.versioning["enabled"] ? "Enabled" : "Suspended", tobool(each.value.versioning["status"]) ? "Enabled" : "Suspended", title(lower(each.value.versioning["status"])))

    # Valid values: "Enabled" or "Disabled"
    mfa_delete = try(tobool(each.value.versioning["mfa_delete"]) ? "Enabled" : "Disabled", title(lower(each.value.versioning["mfa_delete"])), null)
  }
}

# ### Replication
# #NOTE  Destination bucket MUST exist and SHOULD has
# # a bucket policy describe here: https://docs.aws.amazon.com/AmazonS3/latest/userguide/replication-walkthrough-2.html
# Must have bucket versioning enabled first
# The IAM role must be created  in another TF module as shown in the README file
resource "aws_s3_bucket_replication_configuration" "this" {
  for_each = {
    for key, value in var.buckets :
    key => value
    if length(try(value.replication, [])) > 0
    && contains(try(keys(value.replication), []), "destination_account_id")
    && contains(try(keys(value.replication), []), "destination_bucket")
    && contains(try(keys(value.replication), []), "role")
  }
  bucket = lookup(each.value, "bucket_name", "${var.namespace}-${var.stage}-${var.aws_region}-${each.key}")
  role   = lookup(each.value.replication, "role")

  dynamic "rule" {
    for_each = flatten(try([each.value.replication.rules], [], []))
    content {
      id       = try(rule.value.id, "Replicate ${var.namespace} ${var.stage} ${each.key} to ${lookup(each.value.replication, "destination_bucket", null)}")
      status   = try(tobool(rule.value.status) ? "Enabled" : "Disabled", title(lower(rule.value.status)), "Enabled")
      priority = try(rule.value.priority, 0)
      delete_marker_replication {
        status = try(rule.value.delete_marker_replication_status, "Enabled")
      }

      filter {
        prefix   = try(rule.value.prefix, null)
      }

      destination {
        account       = lookup(each.value.replication, "destination_account_id")
        bucket        = "arn:aws:s3:::${lookup(each.value.replication, "destination_bucket")}"
        storage_class = try(rule.value.storage_class, null)

        dynamic "encryption_configuration" {
          for_each = try([rule.value.destination_kms_key_arn], [])
          content {            
            replica_kms_key_id = try(encryption_configuration.value, null)
          }
        }

        dynamic "access_control_translation" {
          for_each = try([rule.value.owner], [])
          content {            
            owner = try(title(lower(access_control_translation.value)), "Destination")
          }
        }

        dynamic "replication_time" {
          for_each = try([rule.value.replication_time], [])
          content {            
            status = "Enabled"
            time {
              minutes = try(title(lower(replication_time.value)), 15)
            }
          }
        }
      }

      dynamic "source_selection_criteria" {
        for_each = try([rule.value.source_selection_criteria], [])
        content {   
          replica_modifications {
            status = try(source_selection_criteria.value.replica_modifications_status, "Disabled")
          }
          sse_kms_encrypted_objects {
            status = try(source_selection_criteria.value.sse_kms_encrypted_objects_status, "Enabled")
          }
        }
      }
    }
  }

  depends_on = [
    aws_s3_bucket_versioning.this,
    aws_s3_bucket_server_side_encryption_configuration.this
  ]
}

### adding lifecycle rules 
resource "aws_s3_bucket_lifecycle_configuration" "this" {
  for_each = { for key, value in var.buckets : key => value }
  bucket                = lookup(each.value, "bucket_name", "${var.namespace}-${var.stage}-${var.aws_region}-${each.key}")
  expected_bucket_owner = var.aws_account_id

  # Default rule to abort incomplete multipart uploads (required for security compliance)
  rule {
    id     = "abort-incomplete-multipart-uploads"
    status = "Enabled"

    abort_incomplete_multipart_upload {
      days_after_initiation = try(each.value.abort_incomplete_multipart_upload_days, 7)
    }

    filter {}
  }

  # User-defined lifecycle rules (if any)
  dynamic "rule" {
    for_each = try(each.value.lifecycle_rules, [])

    content {
      id     = try(rule.value.id, null)
      status = try(rule.value.enabled ? "Enabled" : "Disabled", tobool(rule.value.status) ? "Enabled" : "Disabled", title(lower(rule.value.status)))

      # Max 1 block - abort_incomplete_multipart_upload
      dynamic "abort_incomplete_multipart_upload" {
        for_each = try([rule.value.abort_incomplete_multipart_upload_days], [])

        content {
          days_after_initiation = try(rule.value.abort_incomplete_multipart_upload_days, null)
        }
      }


      # Max 1 block - expiration
      dynamic "expiration" {
        for_each = try(flatten([rule.value.expiration]), [])

        content {
          date                         = try(expiration.value.date, null)
          days                         = try(expiration.value.days, null)
          expired_object_delete_marker = try(expiration.value.expired_object_delete_marker, null)
        }
      }

      # Several blocks - transition
      dynamic "transition" {
        for_each = try(flatten([rule.value.transition]), [])

        content {
          date          = try(transition.value.date, null)
          days          = try(transition.value.days, null)
          storage_class = transition.value.storage_class
        }
      }

      # Max 1 block - noncurrent_version_expiration
      dynamic "noncurrent_version_expiration" {
        for_each = try(flatten([rule.value.noncurrent_version_expiration]), [])

        content {
          newer_noncurrent_versions = try(noncurrent_version_expiration.value.newer_noncurrent_versions, null)
          noncurrent_days           = try(noncurrent_version_expiration.value.days, noncurrent_version_expiration.value.noncurrent_days, null)
        }
      }

      # Several blocks - noncurrent_version_transition
      dynamic "noncurrent_version_transition" {
        for_each = try(flatten([rule.value.noncurrent_version_transition]), [])

        content {
          newer_noncurrent_versions = try(noncurrent_version_transition.value.newer_noncurrent_versions, null)
          noncurrent_days           = try(noncurrent_version_transition.value.days, noncurrent_version_transition.value.noncurrent_days, null)
          storage_class             = noncurrent_version_transition.value.storage_class
        }
      }

      # Max 1 block - filter - without any key arguments or tags
      dynamic "filter" {
        for_each = length(try(flatten([rule.value.filter]), [])) == 0 ? [true] : []

        content {
          #          prefix = ""
        }
      }

      # Max 1 block - filter - with one key argument or a single tag
      dynamic "filter" {
        for_each = [for v in try(flatten([rule.value.filter]), []) : v if max(length(keys(v)), length(try(rule.value.filter.tags, rule.value.filter.tag, []))) == 1]

        content {
          object_size_greater_than = try(filter.value.object_size_greater_than, null)
          object_size_less_than    = try(filter.value.object_size_less_than, null)
          prefix                   = try(filter.value.prefix, null)

          dynamic "tag" {
            for_each = try(filter.value.tags, filter.value.tag, [])

            content {
              key   = tag.key
              value = tag.value
            }
          }
        }
      }

      # Max 1 block - filter - with more than one key arguments or multiple tags
      dynamic "filter" {
        for_each = [for v in try(flatten([rule.value.filter]), []) : v if max(length(keys(v)), length(try(rule.value.filter.tags, rule.value.filter.tag, []))) > 1]

        content {
          and {
            object_size_greater_than = try(filter.value.object_size_greater_than, null)
            object_size_less_than    = try(filter.value.object_size_less_than, null)
            prefix                   = try(filter.value.prefix, null)
            tags                     = try(filter.value.tags, filter.value.tag, null)
          }
        }
      }
    }
  }

  # Must have bucket versioning enabled first
  depends_on = [aws_s3_bucket_versioning.this]
}


## S3 access points #############
resource "aws_s3_access_point" "this" {
  for_each = {
    for key, value in var.buckets :
    key => value
    if length(try(value.s3_access_point, [])) > 0
    && contains(try(keys(value.s3_access_point), []), "aws_lambda")
  }
  bucket = lookup(each.value, "bucket_name", "${var.namespace}-${var.stage}-${var.aws_region}-${each.key}")
  name   = "${each.key}-access-point"

  dynamic "public_access_block_configuration" {
    for_each = contains(keys(each.value.s3_access_point), "vpc_id") ? [] : [1]
    content {
      block_public_acls       = try(each.value.s3_access_point.block_public_acls, true)
      block_public_policy     = contains(try(keys(each.value.s3_access_point), []), "policy") == true ? false : true
      ignore_public_acls      = try(each.value.s3_access_point.ignore_public_acls, true)
      restrict_public_buckets = try(each.value.s3_access_point.restrict_public_buckets, true)
    }
  }

  dynamic "vpc_configuration" {
    for_each = contains(keys(each.value.s3_access_point), "vpc_id") ? [1] : []
    content {
      vpc_id = each.value.s3_access_point.vpc_id
    }
  }

  lifecycle {
    ignore_changes = [policy]
  }

}

resource "aws_s3control_access_point_policy" "this" {
  for_each = {
    for key, value in var.buckets :
    key => value
    if length(try(value.s3_access_point, [])) > 0
    && contains(try(keys(value.s3_access_point), []), "aws_lambda")
    && contains(try(keys(value.s3_access_point), []), "access_point_policy")
  }
  access_point_arn = aws_s3_access_point.this[each.key].arn
  policy           = data.aws_iam_policy_document.s3_endpoint_policy[each.key].json
  depends_on       = [aws_s3_access_point.this]
}



resource "aws_s3control_object_lambda_access_point" "this" {
  for_each = {
    for key, value in var.buckets :
    key => value
    if length(try(value.s3_access_point, [])) > 0
    && contains(try(keys(value.s3_access_point), []), "aws_lambda")
  }
  name = "${each.key}-lambda-access-point"

  configuration {
    supporting_access_point = aws_s3_access_point.this[each.key].arn

    transformation_configuration {
      actions = ["GetObject"]

      content_transformation {
        aws_lambda {
          function_arn = try(each.value.s3_access_point.aws_lambda, [])
        }
      }
    }
  }
}


resource "aws_s3control_object_lambda_access_point_policy" "this" {
  for_each = {
    for key, value in var.buckets :
    key => value
    if length(try(value.s3_access_point, [])) > 0
    && contains(try(keys(value.s3_access_point), []), "aws_lambda")
  }
  name = aws_s3control_object_lambda_access_point.this[each.key].name
  policy = length(try(each.value.s3_access_point.lambda_policy, {})) > 0 ? each.value.s3_access_point.lambda_policy : jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "s3-object-lambda:Get*",
        "s3-object-lambda:List*"
      ]
      Principal = {
        AWS = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
      }
      Resource = aws_s3control_object_lambda_access_point.this[each.key].arn
    }]
  })
}

data "aws_iam_policy_document" "s3_endpoint_policy" {
  for_each = {
    for key, value in var.buckets :
    key => value
    if length(try(value.s3_access_point, [])) > 0
    && contains(try(keys(value.s3_access_point), []), "aws_lambda")
    && contains(try(keys(value.s3_access_point), []), "access_point_policy")
  }

  dynamic "statement" {
    for_each = [
      for statement in each.value.s3_access_point.access_point_policy :
      statement
    ]

    content {
      sid       = lookup(statement.value, "sid", statement.key)
      effect    = lookup(statement.value, "effect", null)
      actions   = lookup(statement.value, "actions", null)
      resources = lookup(statement.value, "resources", ["${aws_s3_access_point.this[each.key].arn}/object/*"])

      dynamic "principals" {
        for_each = lookup(statement.value, "principals", [])

        content {
          type        = principals.value.type
          identifiers = principals.value.identifiers
        }
      }

      dynamic "condition" {
        for_each = lookup(statement.value, "conditions", [])

        content {
          test     = condition.value.test
          variable = condition.value.variable
          values   = condition.value.values
        }
      }
    }
  }
}


data "aws_iam_policy_document" "lambda_endpoint_policy" {
  for_each = {
    for key, value in var.buckets :
    key => value
    if length(try(value.s3_access_point, [])) > 0
    && contains(try(keys(value.s3_access_point), []), "aws_lambda")
    && contains(try(keys(value.s3_access_point), []), "lambda_policy")
  }

  dynamic "statement" {
    for_each = [for statement in each.value.s3_access_point.lambda_policy : statement]

    content {
      sid       = lookup(statement.value, "sid", statement.key)
      effect    = lookup(statement.value, "effect", null)
      actions   = lookup(statement.value, "actions", null)
      resources = lookup(statement.value, "resources", [])

      dynamic "principals" {
        for_each = lookup(statement.value, "principals", [])

        content {
          type        = principals.value.type
          identifiers = principals.value.identifiers
        }
      }

      dynamic "condition" {
        for_each = lookup(statement.value, "conditions", [])

        content {
          test     = condition.value.test
          variable = condition.value.variable
          values   = condition.value.values
        }
      }
    }
  }
}

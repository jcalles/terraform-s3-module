data "aws_iam_policy_document" "require_latest_tls" {
  for_each = { for key, value in var.buckets : key => value }
  statement {
    sid = "DenyNonTLS12PutObjects"

    effect = "Deny"

    actions = ["s3:PutObject"]

    resources = [
      "arn:aws:s3:::${lookup(each.value, "bucket_name", "${var.namespace}-${var.stage}-${var.aws_region}-${each.key}")}",
      "arn:aws:s3:::${lookup(each.value, "bucket_name", "${var.namespace}-${var.stage}-${var.aws_region}-${each.key}")}/*",
    ]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "NumericLessThan"
      variable = "s3:TlsVersion"

      values = ["1.2"]
    }
  }
}
data "aws_iam_policy_document" "deny_insecure_transport" {
  for_each = { for key, value in var.buckets : key => value }

  statement {
    sid    = "denyInsecureTransport"
    effect = "Deny"

    actions = [
      "s3:*",
    ]

    resources = [
      "arn:aws:s3:::${lookup(each.value, "bucket_name", "${var.namespace}-${var.stage}-${var.aws_region}-${each.key}")}",
      "arn:aws:s3:::${lookup(each.value, "bucket_name", "${var.namespace}-${var.stage}-${var.aws_region}-${each.key}")}/*",
    ]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values = [
        "false"
      ]
    }
  }
}
data "aws_iam_policy_document" "deny_unencrypted_object_uploads" {
  for_each = { for key, value in var.buckets : key => value }

  statement {
    sid    = "denyUnencryptedObjectUploads"
    effect = "Deny"

    actions = [
      "s3:PutObject"
    ]

    resources = [
      "arn:aws:s3:::${lookup(each.value, "bucket_name", "${var.namespace}-${var.stage}-${var.aws_region}-${each.key}")}/*"
    ]

    principals {
      identifiers = ["*"]
      type        = "*"
    }

    condition {
      test     = "Null"
      variable = "s3:x-amz-server-side-encryption"
      values   = [true]
    }
  }
}
data "aws_iam_policy_document" "deny_incorrect_encryption_headers" {
  for_each = { for key, value in var.buckets : key => value }

  statement {
    sid    = "denyIncorrectEncryptionHeaders"
    effect = "Deny"

    actions = [
      "s3:PutObject"
    ]

    resources = [
      "arn:aws:s3:::${lookup(each.value, "bucket_name", "${var.namespace}-${var.stage}-${var.aws_region}-${each.key}")}/*"
    ]

    principals {
      identifiers = ["*"]
      type        = "*"
    }

    condition {
      test     = "StringNotEquals"
      variable = "s3:x-amz-server-side-encryption"
      values   = ["AES256"]
    }
  }
}

data "aws_iam_policy_document" "s3_interface_enpoint" {
  for_each = { for key, value in var.buckets : key => value }
  statement {
    sid    = "Access-to-specific-VPCE-only"
    effect = "Allow"
    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "s3:GetObject",
    ]

    resources = [
      "arn:aws:s3:::${lookup(each.value, "bucket_name", "${var.namespace}-${var.stage}-${var.aws_region}-${each.key}")}/*"
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:SourceVpce"
      values   = [lookup(each.value, "s3_interface_enpoint_id", "")]

    }
  }
}

data "aws_iam_policy_document" "public_access" {
  for_each = { for key, value in var.buckets : key => value if try(value.publicly_accessible, []) == true }
  statement {
    sid       = "PublicReadGetObject"
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::${lookup(each.value, "bucket_name", "${var.namespace}-${var.stage}-${var.aws_region}-${each.key}")}/*"]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }
}

data "aws_iam_policy_document" "additional_statements" {
  for_each = { for key, value in var.buckets : key => value if length(try(value.add_iam_policy_stat, [])) > 0 }

  dynamic "statement" {
    for_each = [
      for statement in each.value.add_iam_policy_stat :
      statement
    ]

    content {
      sid    = lookup(statement.value, "sid", statement.key)
      effect = lookup(statement.value, "effect", null)

      actions     = lookup(statement.value, "actions", null)
      not_actions = lookup(statement.value, "not_actions", null)

      resources = lookup(statement.value, "resources", [
        "arn:aws:s3:::${lookup(each.value, "bucket_name", "${var.namespace}-${var.stage}-${var.aws_region}-${each.key}")}",
        "arn:aws:s3:::${lookup(each.value, "bucket_name", "${var.namespace}-${var.stage}-${var.aws_region}-${each.key}")}/*"
      ])

      not_resources = lookup(statement.value, "not_resources", null)

      dynamic "principals" {
        for_each = lookup(statement.value, "principals", [])

        content {
          type        = principals.value.type
          identifiers = principals.value.identifiers
        }
      }

      dynamic "not_principals" {
        for_each = lookup(statement.value, "not_principals", [])

        content {
          type        = not_principals.value.type
          identifiers = not_principals.value.identifiers
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

### Combined 
data "aws_iam_policy_document" "combined" {
  for_each = { for key, value in var.buckets : key => value }
  source_policy_documents = compact([
    data.aws_iam_policy_document.require_latest_tls[each.key].json,
    data.aws_iam_policy_document.deny_insecure_transport[each.key].json,
    try(each.value.s3_interface_enpoint_id, "") == "" ? null : data.aws_iam_policy_document.s3_interface_enpoint[each.key].json,
    try(each.value.deny_unencrypted_object_uploads, false) == true ? data.aws_iam_policy_document.deny_unencrypted_object_uploads[each.key].json : null,
    try(each.value.deny_incorrect_encryption_headers, false) == true ? data.aws_iam_policy_document.deny_incorrect_encryption_headers[each.key].json : null,
    try(length(each.value.add_iam_policy_stat) > 0, []) == true ? data.aws_iam_policy_document.additional_statements[each.key].json : null,
    try(each.value.publicly_accessible, false) == true ? data.aws_iam_policy_document.public_access[each.key].json : null,
  ])
}

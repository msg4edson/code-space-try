resource "aws_s3_bucket" "servicenow_ingestion" {
  bucket = var.s3_bucket_name
}

data "aws_iam_policy_document" "appflow_s3_access" {
  statement {
    sid = "AllowAppFlowS3Access"

    principals {
      type        = "Service"
      identifiers = ["appflow.amazonaws.com"]
    }

    actions = [
      "s3:GetBucketAcl",
      "s3:PutObject",
      "s3:PutObjectAcl"
    ]

    resources = [
      aws_s3_bucket.servicenow_ingestion.arn,
      "${aws_s3_bucket.servicenow_ingestion.arn}/*"
    ]
  }
}

resource "aws_s3_bucket_policy" "servicenow_ingestion" {
  bucket = aws_s3_bucket.servicenow_ingestion.id
  policy = data.aws_iam_policy_document.appflow_s3_access.json
}

resource "aws_s3_bucket_versioning" "servicenow_ingestion" {
  count  = var.manage_s3_bucket_security_resources ? 1 : 0
  bucket = aws_s3_bucket.servicenow_ingestion.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "servicenow_ingestion" {
  count  = var.manage_s3_bucket_security_resources ? 1 : 0
  bucket = aws_s3_bucket.servicenow_ingestion.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "servicenow_ingestion" {
  count  = var.manage_s3_bucket_security_resources ? 1 : 0
  bucket = aws_s3_bucket.servicenow_ingestion.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket" "servicenow_ingestion" {
  bucket = var.s3_bucket_name
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

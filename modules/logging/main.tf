# 1. The Logging Bucket
resource "aws_s3_bucket" "logs" {
  bucket = "${var.project_name}-tableau-logs-${data.aws_caller_identity.current.account_id}"
  tags   = local.common_tags
}

data "aws_caller_identity" "current" {}

# 2. Hardened Security Settings
resource "aws_s3_bucket_public_access_block" "logs" {
  bucket                  = aws_s3_bucket.logs.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# 3. Enforce HTTPS
resource "aws_s3_bucket_policy" "force_https" {
  bucket = aws_s3_bucket.logs.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "AllowSSLRequestsOnly"
      Effect    = "Deny"
      Principal = "*"
      Action    = "s3:*"
      Resource  = [aws_s3_bucket.logs.arn, "${aws_s3_bucket.logs.arn}/*"]
      Condition = { Bool = { "aws:SecureTransport" = "false" } }
    }]
  })
}

# 4. Lifecycle Policy for Cost Management
resource "aws_s3_bucket_lifecycle_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id
  rule {
    id     = "archive-old-logs"
    status = "Enabled"
    transition {
      days          = var.retention_days
      storage_class = "GLACIER"
    }
  }
}
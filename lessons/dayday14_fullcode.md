// first we create s3 resource 
resource "aws_s3_bucket" "my_first_bucket" {
  bucket = var.bucket_name
  # acl    = "public-read"
}

// here we make the bucket private
resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.my_first_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

// now we allow the origin to access the bucket
resource "aws_cloudfront_origin_access_control" "my_origin_access_control" {
  name                              = "my_origin_access_control"
  description                       = "Example Policy"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

// bucket policy
resource "aws_s3_bucket_policy" "allow_access_from_another_account" {
  bucket = aws_s3_bucket.my_first_bucket.id

  depends_on = [aws_s3_bucket_public_access_block.example]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Statement1"
        Effect = "Allow"

        # FIXED → Correct principal
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }

        Action = [
          "s3:GetObject",
          "s3:ListBucket",
        ]

        Resource = [
          aws_s3_bucket.my_first_bucket.arn,
          "${aws_s3_bucket.my_first_bucket.arn}/*"
        ]

        # FIXED → Required OAC condition
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.s3_distribution.arn
          }
        }
      }
    ]
  })
}

data "aws_iam_policy_document" "allow_access_from_another_account" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["123456789012"]
    }

    actions = [
      "s3:GetObject"
    ]

    resources = [
      aws_s3_bucket.my_first_bucket.arn,
      "${aws_s3_bucket.my_first_bucket.arn}/*",
    ]
  }
}

// s3 bucket object 
resource "aws_s3_object" "object" {

  bucket   = aws_s3_bucket.my_first_bucket.id
  for_each = fileset("${path.module}/www", "**/*")
  key      = each.value
  source   = "${path.module}/www/${each.value}"

  etag = filemd5("${path.module}/www/${each.value}")
  content_type = lookup({
    "index.html" = "text/html"
    "style.css"  = "text/css"
    "script.js"  = "application/javascript",
    "jpeg"       = "image/jpeg",
    "png"        = "image/png",
    "gif"        = "image/gif",
    "jpg"        = "image/jpg",
    "ico"        = "image/ico",
    "svg"        = "image/svg+xml",
    "webp"       = "image/webp",
    "mp4"        = "video/mp4",
    "mp3"        = "audio/mp3",
    "doc"        = "application/msword",
    "docx"       = "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
    "json"       = "application/json",
    "xml"        = "application/xml",
    "html"       = "text/html",
    "css"        = "text/css",
    "js"         = "application/javascript",
    "txt"        = "text/plain",
    "log"        = "text/plain",
    "md"         = "text/markdown",
  }, split(".", each.value)[length(split(".", each.value)) - 1], "application/octet-stream")
}

// cloudfront distribution
resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name              = aws_s3_bucket.my_first_bucket.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.my_origin_access_control.id

    # THIS IS VALID NOW
    origin_id = local.origin_id
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Some comment"
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

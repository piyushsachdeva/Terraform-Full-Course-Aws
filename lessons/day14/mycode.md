
 Global Static Website with Custom Domain on AWS using Terraform

## Project Goal
This project extends the secure S3 + CloudFront static website architecture (Day 14) by adding a custom domain, HTTPS via ACM, and automated cache invalidation to create a fully production-ready, globally distributed website.


## 💻 Terraform Implementation Details

### 1. Variables and Locals

Key variables were introduced for domain configuration.

```hcl
variable "domain_name" {
  default = "example.tech-tutorials-py.com" # Replace with your domain
}

variable "hosted_zone_id" {
  description = "Route 53 Hosted Zone ID for the domain"
  # Note: This is usually looked up using a data source or pre-defined.
}
````

### 2\. HTTPS Certificate Provisioning (ACM)

A public certificate was requested in `us-east-1` (a CloudFront requirement) and validated via DNS records in Route 53.

```hcl
resource "aws_acm_certificate" "cert" {
  domain_name       = var.domain_name
  validation_method = "DNS"
  provider          = aws.us-east-1 # ACM for CloudFront MUST be in us-east-1
}

# DNS Validation for the Certificate
resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name    = dvo.resource_record_name
      record  = dvo.resource_record_value
      type    = dvo.resource_record_type
    }
  }
  
  # ... Route 53 settings using the Hosted Zone ID ...
}

resource "aws_acm_certificate_validation" "cert_validation" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}
```

### 3\. Updated CloudFront Distribution

The distribution was modified to use the custom domain and the new ACM certificate.

```hcl
resource "aws_cloudfront_distribution" "s3_distribution" {
  # ... (OAC and Origin settings from Day 14) ...

  aliases = [var.domain_name] # Add custom domain here

  viewer_certificate {
    # Custom certificate ARN from ACM
    acm_certificate_arn      = aws_acm_certificate_validation.cert_validation.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
  
  # Ensure viewer_protocol_policy is "redirect-to-https"
  default_cache_behavior {
    # ...
    viewer_protocol_policy = "redirect-to-https"
    # ...
  }
}
```

### 4\. Route 53 DNS Configuration

Created an `A` record alias to point the domain directly at the CloudFront distribution's endpoint.

```hcl
resource "aws_route53_record" "site_alias" {
  zone_id = var.hosted_zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.s3_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.s3_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}
```

### 5\. Automated Cache Invalidation

A `null_resource` and a local-exec provisioner were used to trigger a CloudFront invalidation whenever the S3 file content changes, ensuring users immediately see the new version.

```hcl
# This resource runs after S3 objects are uploaded and triggers invalidation.
resource "aws_cloudfront_distribution_invalidation" "cache_bust" {
  distribution_id = aws_cloudfront_distribution.s3_distribution.id

  # Trigger invalidation whenever any static file resource changes its content (etag)
  # or whenever the distribution itself changes.
  depends_on = [
    aws_s3_object.object
  ]

  # Invalidation path to clear all cached files
  paths = [
    "/*",
  ]
}
```

-----

## ✅ Deployment & Verification

1.  **Initialize**: `terraform init`
2.  **Plan**: `terraform plan`
3.  **Apply**: `terraform apply --auto-approve`

### Verification Steps

1.  **Access URL**: Browsed to `https://[your custom domain]`
2.  **HTTPS Check**: Verified the padlock icon and confirmed the certificate was issued by Amazon.
3.  **Content Check**: Modified `index.html` in the `www` folder, reapplied Terraform, and confirmed the new content loaded instantly (proving the invalidation worked).

**Status**: The static website is now live, secure, globally distributed, and accessible via a custom domain.

-----

## ➡️ Next Steps (CI/CD and Environments)

  * **CI/CD Pipeline**: Integrate this Terraform stack into a CI/CD pipeline (e.g., GitHub Actions or AWS CodePipeline) to automate deployment upon every code commit.
  * **Multiple Environments**: Implement separate Terraform workspaces (e.g., `dev`, `staging`, `prod`) to manage configurations for different environments.
  * **Security Headers**: Add CloudFront Response Headers Policy to enforce security headers like HSTS and CSP.

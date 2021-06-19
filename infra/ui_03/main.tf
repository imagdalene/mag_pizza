terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

}

provider "aws" {
  profile = "default"
  region  = "us-east-1"
}


resource "aws_cloudfront_origin_access_identity" "UIOriginIdentity" {
  comment = "Identity"
}

data "aws_iam_policy_document" "s3_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.uibucket.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.UIOriginIdentity.iam_arn]
    }
  }

  statement {
    actions = ["s3:ListBucket"]
    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.UIOriginIdentity.iam_arn]
    }
    resources = [aws_s3_bucket.uibucket.arn]

  }
}

data "aws_route53_zone" "selected" {
  name = var.ZoneName
}

resource "aws_s3_bucket" "uibucket" {
  bucket = "ui-bucket-amazing-primes"
}

resource "aws_s3_bucket_policy" "uibucketPolicy" {
  bucket = aws_s3_bucket.uibucket.id
  policy = data.aws_iam_policy_document.s3_policy.json
}

resource "aws_cloudfront_distribution" "UiDist" {
  aliases             = var.Aliases
  enabled             = true
  default_root_object = "index.html"
  depends_on = [
    aws_s3_bucket.uibucket
  ]
  origin {
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.UIOriginIdentity.cloudfront_access_identity_path
    }
    domain_name = aws_s3_bucket.uibucket.bucket_regional_domain_name
    origin_id   = "S3-origin-${aws_s3_bucket.uibucket.id}"
  }

  custom_error_response {
    error_code         = 404
    response_code      = 200
    response_page_path = "/index.html"

  }


  default_cache_behavior {
    allowed_methods = [
      "GET", "HEAD"
    ]
    cached_methods = [
      "GET", "HEAD"
    ]

    forwarded_values {
      query_string = true

      cookies {
        forward = "all"
      }
    }
    target_origin_id = "S3-origin-${aws_s3_bucket.uibucket.id}"

    viewer_protocol_policy = "redirect-to-https"

  }

  viewer_certificate {
    acm_certificate_arn      = var.CertArn
    minimum_protocol_version = "TLSv1.2_2018"
    ssl_support_method       = "sni-only"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}

resource "aws_route53_record" "Route53A" {
  name    = var.ZoneName
  type    = "A"
  zone_id = data.aws_route53_zone.selected.zone_id
  alias {
    name                   = aws_cloudfront_distribution.UiDist.domain_name
    evaluate_target_health = false
    zone_id                = aws_cloudfront_distribution.UiDist.hosted_zone_id
  }
}

data "aws_route53_zone" "daisukekonishi" {
  name         = "daisukekonishi.com."
  private_zone = false
}

resource "aws_route53_record" "apex" {
  zone_id = data.aws_route53_zone.daisukekonishi.zone_id
  name    = "daisukekonishi.com"
  type    = "A"

  alias {
    name                   = "d1f7qeajtqnofe.cloudfront.net."
    zone_id                = "Z2FDTNDATAQYW2"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "google_verification" {
  zone_id = data.aws_route53_zone.daisukekonishi.zone_id
  name    = "daisukekonishi.com"
  type    = "TXT"
  ttl     = 300
  records = [var.route53_google_verification_record]
}

resource "aws_route53_record" "acm_validation" {
  zone_id = data.aws_route53_zone.daisukekonishi.zone_id
  name    = "_d482ca759bf58c094690fa1fe22d15f8.daisukekonishi.com"
  type    = "CNAME"
  ttl     = 300
  records = [var.route53_acm_validation_target]
}

resource "aws_route53_record" "blog" {
  zone_id = data.aws_route53_zone.daisukekonishi.zone_id
  name    = "blog.daisukekonishi.com"
  type    = "CNAME"
  ttl     = 300
  records = ["cname.vercel-dns.com"]
}

resource "aws_route53_record" "daily" {
  zone_id = data.aws_route53_zone.daisukekonishi.zone_id
  name    = "daily.daisukekonishi.com"
  type    = "A"
  ttl     = 300
  records = ["151.101.1.195", "151.101.65.195"]
}

resource "aws_route53_record" "mealselect" {
  zone_id = data.aws_route53_zone.daisukekonishi.zone_id
  name    = "mealselect.daisukekonishi.com"
  type    = "A"
  ttl     = 300
  records = ["104.198.14.52"]
}

resource "aws_route53_health_check" "blog_site" {
  type              = "HTTPS"
  fqdn              = "blog.daisukekonishi.com"
  port              = 443
  resource_path     = "/"
  failure_threshold = 3
  request_interval  = 30
  regions           = ["ap-northeast-1", "ap-southeast-1", "us-west-2"]

  tags = {
    Name = "BlogSite"
  }
}

resource "aws_route53_health_check" "memo_drip" {
  type              = "HTTPS"
  fqdn              = "memodrip.net"
  port              = 443
  resource_path     = "/"
  failure_threshold = 3
  request_interval  = 30
  regions           = ["ap-northeast-1", "ap-southeast-1", "us-west-2"]

  tags = {
    Name = "MemoDrip"
  }
}

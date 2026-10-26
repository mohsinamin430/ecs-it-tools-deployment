#Create route53 hosted zone
resource "aws_route53_zone" "hosted_zone_it_tools" {
  name = var.domain_name
}

resource "aws_route53domains_registered_domain" "domain" {
  domain_name = var.domain_name

  name_server {
    name = aws_route53_zone.hosted_zone_it_tools.name_servers[0]
  }

  name_server {
    name = aws_route53_zone.hosted_zone_it_tools.name_servers[1]
  }

  name_server {
    name = aws_route53_zone.hosted_zone_it_tools.name_servers[2]
  }

  name_server {
    name = aws_route53_zone.hosted_zone_it_tools.name_servers[3]
  }
}

#Create ACM certificate for the domain
resource "aws_acm_certificate" "cert" {
  domain_name               = var.domain_name
  subject_alternative_names = ["${var.sub_domain}.${var.domain_name}"]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

#route53 CNAME records generated for ACM certificate validation
resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }

  zone_id = aws_route53_zone.hosted_zone_it_tools.zone_id
  name    = each.value.name
  type    = each.value.type
  records = [each.value.record]
  ttl     = 60
}

#A record for ecs.
resource "aws_route53_record" "ecs" {
  zone_id = aws_route53_zone.hosted_zone_it_tools.zone_id
  name    = "${var.sub_domain}.${var.domain_name}"
  type    = "A"
  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}

#A record for root domain
resource "aws_route53_record" "root" {
  zone_id = aws_route53_zone.hosted_zone_it_tools.zone_id
  name    = var.domain_name
  type    = "A"
  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}

#Create health check on port 80
resource "aws_route53_health_check" "health_check" {
  fqdn              = "${var.sub_domain}.${var.domain_name}"
  type              = "HTTP"
  resource_path     = "/health"
  port              = 80
  request_interval  = 30
  failure_threshold = 3
}

#Validate the ACM certificate. Waits until ACM sees route53 records and validates the certificate. This is required for the ALB to use the certificate.
resource "aws_acm_certificate_validation" "cert_validation" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}
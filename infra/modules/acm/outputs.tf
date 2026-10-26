output "acm_certificate_arn" {
  value = aws_acm_certificate_validation.cert_validation.certificate_arn
}

output "nameservers" {
  value = aws_route53_zone.hosted_zone_it_tools.name_servers
}
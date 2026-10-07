output "name_servers" {
  value = local.has_domain ? aws_route53_zone.public[0].name_servers : []
}

output "zone_id" {
  value = local.has_domain ? aws_route53_zone.public[0].zone_id : null
}

output "custom_domain_url" {
  value = var.enable_custom_domain && local.has_domain ? "https://${local.api_domain_name}" : null
}

output "zone_arn" {
  value = local.has_domain ? "arn:aws:route53:::hostedzone/${aws_route53_zone.public[0].zone_id}" : null
}

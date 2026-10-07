locals {
  has_domain      = trimspace(var.domain_name) != ""
  api_domain_name = local.has_domain ? "${var.api_subdomain_label}.${var.domain_name}" : ""
}

resource "aws_route53_zone" "public" {
  count   = local.has_domain ? 1 : 0
  name    = var.domain_name
  comment = "Public DNS zone for ${var.domain_name}."
  tags    = merge(var.tags, { Name = var.domain_name })
}

resource "aws_acm_certificate" "api" {
  count = var.enable_custom_domain ? 1 : 0

  domain_name       = local.api_domain_name
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true

    precondition {
      condition     = local.has_domain
      error_message = "Set domain_name to a registered domain before enabling the custom API domain."
    }
  }

  tags = merge(var.tags, { Name = local.api_domain_name })
}

resource "aws_route53_record" "certificate_validation" {
  for_each = var.enable_custom_domain ? {
    for option in aws_acm_certificate.api[0].domain_validation_options : option.domain_name => {
      name   = option.resource_record_name
      type   = option.resource_record_type
      record = option.resource_record_value
    }
  } : {}

  allow_overwrite = true
  zone_id         = aws_route53_zone.public[0].zone_id
  name            = each.value.name
  type            = each.value.type
  ttl             = 60
  records         = [each.value.record]
}

resource "aws_acm_certificate_validation" "api" {
  count = var.enable_custom_domain ? 1 : 0

  certificate_arn         = aws_acm_certificate.api[0].arn
  validation_record_fqdns = [for record in values(aws_route53_record.certificate_validation) : record.fqdn]
}

resource "aws_apigatewayv2_domain_name" "api" {
  count = var.enable_custom_domain ? 1 : 0

  domain_name = local.api_domain_name

  domain_name_configuration {
    certificate_arn = aws_acm_certificate_validation.api[0].certificate_arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }

  tags = merge(var.tags, { Name = local.api_domain_name })
}

resource "aws_apigatewayv2_api_mapping" "api" {
  count = var.enable_custom_domain ? 1 : 0

  api_id      = var.api_id
  domain_name = aws_apigatewayv2_domain_name.api[0].id
  stage       = var.api_stage_name
}

resource "aws_route53_record" "api_a" {
  count = var.enable_custom_domain ? 1 : 0

  zone_id = aws_route53_zone.public[0].zone_id
  name    = local.api_domain_name
  type    = "A"

  alias {
    name                   = aws_apigatewayv2_domain_name.api[0].domain_name_configuration[0].target_domain_name
    zone_id                = aws_apigatewayv2_domain_name.api[0].domain_name_configuration[0].hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "api_aaaa" {
  count = var.enable_custom_domain ? 1 : 0

  zone_id = aws_route53_zone.public[0].zone_id
  name    = local.api_domain_name
  type    = "AAAA"

  alias {
    name                   = aws_apigatewayv2_domain_name.api[0].domain_name_configuration[0].target_domain_name
    zone_id                = aws_apigatewayv2_domain_name.api[0].domain_name_configuration[0].hosted_zone_id
    evaluate_target_health = false
  }
}

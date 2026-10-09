data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}
data "aws_region" "current" {}

locals {
  routes = toset([
    "GET /health",
    "GET /objects/{key}",
    "PUT /objects/{key}",
  ])

  access_log_format = jsonencode({
    requestId      = "$context.requestId"
    sourceIp       = "$context.identity.sourceIp"
    requestTime    = "$context.requestTime"
    httpMethod     = "$context.httpMethod"
    routeKey       = "$context.routeKey"
    status         = "$context.status"
    responseLength = "$context.responseLength"
    integrationErr = "$context.integrationErrorMessage"
  })

  access_log_group_arn = "arn:${data.aws_partition.current.partition}:logs:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/apigateway/${var.name_prefix}"
}

resource "aws_kms_key" "logs" {
  description             = "KMS key for API access logs"
  deletion_window_in_days = 7
  enable_key_rotation     = false
  tags                    = merge(var.tags, { Name = "${var.name_prefix}-api-logs" })
}

resource "aws_kms_key_policy" "logs" {
  key_id = aws_kms_key.logs.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "EnableAccountKeyAdministration"
        Effect    = "Allow"
        Principal = { AWS = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:root" }
        Action    = "kms:*"
        Resource  = "*"
      },
      {
        Sid       = "AllowCloudWatchLogsUseOfKey"
        Effect    = "Allow"
        Principal = { Service = "logs.${data.aws_region.current.region}.${data.aws_partition.current.dns_suffix}" }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:Describe*",
        ]
        Resource = "*"
        Condition = {
          ArnEquals = {
            "kms:EncryptionContext:aws:logs:arn" = local.access_log_group_arn
          }
        }
      },
    ]
  })
}

resource "aws_cloudwatch_log_group" "access" {
  name              = "/aws/apigateway/${var.name_prefix}"
  retention_in_days = 14
  kms_key_id        = aws_kms_key.logs.arn
  tags              = merge(var.tags, { Name = "${var.name_prefix}-api-access" })

  depends_on = [aws_kms_key_policy.logs]
}

resource "aws_apigatewayv2_api" "this" {
  name                         = "${var.name_prefix}-http-api"
  protocol_type                = "HTTP"
  disable_execute_api_endpoint = false

  dynamic "cors_configuration" {
    for_each = length(var.allowed_origins) > 0 ? [true] : []
    content {
      allow_credentials = false
      allow_origins     = var.allowed_origins
      allow_methods     = ["*"]
      allow_headers     = ["*"]
      expose_headers    = ["*"]
      max_age           = 0
    }
  }

  tags = merge(var.tags, { Name = "${var.name_prefix}-http-api" })
}

resource "aws_apigatewayv2_integration" "lambda" {
  api_id                 = aws_apigatewayv2_api.this.id
  integration_type       = "AWS_PROXY"
  integration_uri        = var.lambda_invoke_arn
  payload_format_version = "2.0"
  timeout_milliseconds   = 10000
}

resource "aws_apigatewayv2_route" "this" {
  for_each = local.routes

  api_id             = aws_apigatewayv2_api.this.id
  route_key          = each.value
  authorization_type = "AWS_IAM"
  target             = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.this.id
  name        = "$default"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.access.arn
    format          = local.access_log_format
  }

  default_route_settings {
    detailed_metrics_enabled = false
    throttling_burst_limit   = var.throttling_burst_limit
    throttling_rate_limit    = var.throttling_rate_limit
  }

  tags = merge(var.tags, { Name = "${var.name_prefix}-default-stage" })
}

resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowHttpApiInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_name
  qualifier     = var.lambda_alias_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.this.execution_arn}/*/*"
}
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
}

resource "aws_cloudwatch_log_group" "access" {
  name              = "/aws/apigateway/${var.name_prefix}"
  retention_in_days = 14
  tags              = merge(var.tags, { Name = "${var.name_prefix}-api-access" })
}

resource "aws_apigatewayv2_api" "this" {
  name                         = "${var.name_prefix}-http-api"
  protocol_type                = "HTTP"
  disable_execute_api_endpoint = var.disable_execute_api_endpoint

  dynamic "cors_configuration" {
    for_each = length(var.allowed_origins) > 0 ? [true] : []
    content {
      allow_origins = var.allowed_origins
      allow_methods = ["GET", "PUT", "OPTIONS"]
      allow_headers = [
        "authorization",
        "content-type",
        "x-amz-date",
        "x-amz-security-token",
        "x-amz-content-sha256",
      ]
      max_age = 300
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

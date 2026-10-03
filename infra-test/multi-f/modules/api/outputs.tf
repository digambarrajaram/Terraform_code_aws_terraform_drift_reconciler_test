output "api_id" {
  value = aws_apigatewayv2_api.this.id
}

output "api_arn" {
  value = aws_apigatewayv2_api.this.arn
}

output "api_endpoint" {
  value = aws_apigatewayv2_api.this.api_endpoint
}

output "stage_name" {
  value = aws_apigatewayv2_stage.default.name
}

output "access_log_group_arn" {
  value = aws_cloudwatch_log_group.access.arn
}

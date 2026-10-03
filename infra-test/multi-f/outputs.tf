output "api_url" {
  description = "Regional API Gateway URL. It is disabled when the custom domain is enabled."
  value       = module.api.api_endpoint
}

output "custom_domain_url" {
  description = "HTTPS custom API URL, populated after Route 53 delegation and ACM validation."
  value       = module.dns.custom_domain_url
}

output "route53_name_servers" {
  description = "Delegate these name servers at the domain registrar before enabling the custom API domain."
  value       = module.dns.name_servers
}

output "s3_bucket_name" {
  description = "Private, versioned S3 bucket used by the API."
  value       = module.storage.bucket_name
}

output "lambda_function_name" {
  description = "Versioned Lambda function behind the API."
  value       = module.app.function_name
}

output "vpc_id" {
  description = "Isolated VPC containing the Lambda private subnets."
  value       = module.network.vpc_id
}

output "apply_role_arn" {
  description = "Dedicated role ARN used by the drift reconciler for this scope."
  value       = aws_iam_role.multi_f_apply.arn
}

output "dynamodb_table_name" {
  description = "Retained on-demand test-support table from the original multi-f scope."
  value       = module.test_support.dynamodb_table_name
}

output "sns_topic_arn" {
  description = "Retained test-support topic from the original multi-f scope."
  value       = module.test_support.sns_topic_arn
}

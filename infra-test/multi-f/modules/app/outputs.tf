output "function_name" {
  value = aws_lambda_function.this.function_name
}

output "function_arn" {
  value = aws_lambda_function.this.arn
}

output "alias_name" {
  value = aws_lambda_alias.live.name
}

output "alias_arn" {
  value = aws_lambda_alias.live.arn
}

output "invoke_arn" {
  value = aws_lambda_alias.live.invoke_arn
}

output "execution_role_arn" {
  value = aws_iam_role.execution.arn
}

output "log_group_arn" {
  value = aws_cloudwatch_log_group.lambda.arn
}

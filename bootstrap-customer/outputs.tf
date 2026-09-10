output "scan_role_arn" {
  description = "ARN of the customer scan role"
  value       = aws_iam_role.scan.arn
}

output "apply_role_arn" {
  description = "ARN of the customer apply role"
  value       = aws_iam_role.apply.arn
}

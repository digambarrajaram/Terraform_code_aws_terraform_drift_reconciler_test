output "dynamodb_table_name" {
  value = aws_dynamodb_table.items.name
}

output "dynamodb_table_arn" {
  value = aws_dynamodb_table.items.arn
}

output "sns_topic_arn" {
  value = aws_sns_topic.events.arn
}

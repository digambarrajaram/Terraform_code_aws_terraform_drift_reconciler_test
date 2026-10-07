moved {
  from = aws_vpc.test
  to   = module.network.aws_vpc.this
}

moved {
  from = aws_subnet.private
  to   = module.network.aws_subnet.private["a"]
}

moved {
  from = aws_route_table.private
  to   = module.network.aws_route_table.private["a"]
}

moved {
  from = aws_route_table_association.private
  to   = module.network.aws_route_table_association.private["a"]
}

moved {
  from = aws_s3_bucket.test
  to   = module.storage.aws_s3_bucket.this
}

moved {
  from = aws_s3_bucket_public_access_block.test
  to   = module.storage.aws_s3_bucket_public_access_block.this
}

moved {
  from = aws_s3_bucket_policy.test
  to   = module.storage.aws_s3_bucket_policy.this
}

moved {
  from = aws_dynamodb_table.test
  to   = module.test_support.aws_dynamodb_table.items
}

moved {
  from = aws_cloudwatch_log_group.lambda
  to   = module.app.aws_cloudwatch_log_group.lambda
}

moved {
  from = aws_iam_role.lambda_execution
  to   = module.app.aws_iam_role.execution
}

moved {
  from = aws_iam_role_policy.lambda_logging
  to   = module.app.aws_iam_role_policy.execution
}

moved {
  from = aws_lambda_function.hello
  to   = module.app.aws_lambda_function.this
}

moved {
  from = aws_sns_topic.test
  to   = module.test_support.aws_sns_topic.events
}

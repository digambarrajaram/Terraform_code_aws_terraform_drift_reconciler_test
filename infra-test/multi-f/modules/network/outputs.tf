output "vpc_id" {
  value = aws_vpc.this.id
}

output "private_subnet_ids" {
  value = [for key in sort(keys(aws_subnet.private)) : aws_subnet.private[key].id]
}

output "lambda_security_group_id" {
  value = aws_security_group.lambda.id
}

output "s3_vpc_endpoint_id" {
  value = aws_vpc_endpoint.s3.id
}

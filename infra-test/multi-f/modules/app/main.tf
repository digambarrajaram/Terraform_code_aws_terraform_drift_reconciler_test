data "archive_file" "lambda_package" {
  type        = "zip"
  source_dir  = "${path.module}/src"
  output_path = "${path.root}/.terraform/multi_f_lambda.zip"
}

resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${var.name_prefix}-hello"
  retention_in_days = 14
  tags              = merge(var.tags, { Name = "${var.name_prefix}-lambda-logs" })
}

resource "aws_iam_role" "execution" {
  name = "${var.name_prefix}-lambda-execution"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = merge(var.tags, { Name = "${var.name_prefix}-lambda-execution" })
}

resource "aws_iam_role_policy" "execution" {
  name = "${var.name_prefix}-lambda-execution-logging"
  role = aws_iam_role.execution.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "WriteFunctionLogs"
        Effect   = "Allow"
        Action   = ["logs:CreateLogStream", "logs:PutLogEvents"]
        Resource = "${aws_cloudwatch_log_group.lambda.arn}:*"
      },
      {
        Sid    = "ManageLambdaNetworkInterfaces"
        Effect = "Allow"
        Action = [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DescribeSubnets",
          "ec2:DeleteNetworkInterface",
          "ec2:AssignPrivateIpAddresses",
          "ec2:UnassignPrivateIpAddresses",
        ]
        Resource = "*"
      },
      {
        Sid      = "AccessApplicationObjects"
        Effect   = "Allow"
        Action   = ["s3:GetObject", "s3:PutObject"]
        Resource = "${var.bucket_arn}/*"
      },
    ]
  })
}

# Do not reserve account concurrency: AWS requires at least 10 executions
# to remain unreserved for other functions.
resource "aws_lambda_function" "this" {
  function_name                  = "${var.name_prefix}-hello"
  role                           = aws_iam_role.execution.arn
  handler                        = "handler.lambda_handler"
  runtime                        = "python3.12"
  filename                       = data.archive_file.lambda_package.output_path
  source_code_hash               = data.archive_file.lambda_package.output_base64sha256
  memory_size                    = 128
  timeout                        = 10
  publish                        = true
  architectures                  = ["arm64"]
  reserved_concurrent_executions = -1

  tracing_config {
    mode = "Active"
  }

  environment {
    variables = {
      BUCKET_NAME = var.bucket_name
    }
  }

  vpc_config {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = [var.security_group_id]
  }

  tags = merge(var.tags, { Name = "${var.name_prefix}-hello" })

  depends_on = [aws_iam_role_policy.execution]
}

resource "aws_lambda_alias" "live" {
  name             = "live"
  description      = "Stable production-style alias for API Gateway integration."
  function_name    = aws_lambda_function.this.function_name
  function_version = aws_lambda_function.this.version
}
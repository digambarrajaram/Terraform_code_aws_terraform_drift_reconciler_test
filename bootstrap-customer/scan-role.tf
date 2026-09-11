data "aws_iam_policy_document" "scan_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = [var.backend_role_arn]
    }
  }
}

resource "aws_iam_role" "scan" {
  name               = "drift-reconciler-scan-${var.env_id}"
  assume_role_policy = data.aws_iam_policy_document.scan_trust.json

  tags = {
    Purpose = "drift-reconciler-scan"
    EnvID   = var.env_id
  }
}

# TESTING SCOPE — broad service coverage granted for test environment; revisit before any production customer onboarding (least-privilege per resource type actually in use).
data "aws_iam_policy_document" "scan_read" {

  statement {
    sid    = "ReadManagedResources"
    effect = "Allow"
    actions = [
      "ec2:Describe*",
      "ec2:Get*",
      "ec2:List*",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "RDSRead"
    effect = "Allow"
    actions = [
      "rds:Describe*",
      "rds:List*",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "LambdaRead"
    effect = "Allow"
    actions = [
      "lambda:List*",
      "lambda:Get*",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "IAMRead"
    effect = "Allow"
    actions = [
      "iam:List*",
      "iam:Get*",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "S3Read"
    effect = "Allow"
    actions = [
      "s3:ListAllMyBuckets",
      "s3:GetBucket*",
      "s3:ListBucket",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "DynamoDBRead"
    effect = "Allow"
    actions = [
      "dynamodb:ListTables",
      "dynamodb:DescribeTable",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "SNSRead"
    effect = "Allow"
    actions = [
      "sns:List*",
      "sns:Get*",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "SQSRead"
    effect = "Allow"
    actions = [
      "sqs:List*",
      "sqs:Get*",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "StateBucketAccess"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:ListBucket",
    ]
    resources = [
      "arn:aws:s3:::${var.tf_state_bucket}",
      "arn:aws:s3:::${var.tf_state_bucket}/*",
    ]
  }

  statement {
    sid     = "LockTableRead"
    effect  = "Allow"
    actions = ["dynamodb:GetItem"]
    resources = [
      "arn:aws:dynamodb:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:table/${var.tf_lock_table}",
    ]
  }
}

resource "aws_iam_role_policy" "scan" {
  name   = "read-managed-resources"
  role   = aws_iam_role.scan.id
  policy = data.aws_iam_policy_document.scan_read.json
}

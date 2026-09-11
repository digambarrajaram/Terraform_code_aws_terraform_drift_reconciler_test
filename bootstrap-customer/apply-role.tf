data "aws_iam_policy_document" "apply_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = [var.backend_role_arn]
    }
  }
}

resource "aws_iam_role" "apply" {
  name               = "drift-reconciler-apply-${var.env_id}"
  assume_role_policy = data.aws_iam_policy_document.apply_trust.json

  tags = {
    Purpose = "drift-reconciler-apply"
    EnvID   = var.env_id
  }
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

# TESTING SCOPE — broad service coverage granted for test environment; revisit before any production customer onboarding (least-privilege per resource type actually in use).
data "aws_iam_policy_document" "apply_write" {
  # Known limitation: EC2 permissions remain an explicit action list. Resource-
  # type-specific broadening is intentionally deferred rather than broadening
  # this role to ec2:* or all-service resources.
  statement {
    sid    = "ReadForPlan"
    effect = "Allow"
    actions = [
      "ec2:Describe*",
      "ec2:Get*",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "RDSReadForPlan"
    effect = "Allow"
    actions = [
      "rds:Describe*",
      "rds:Get*",
      "rds:List*",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "LambdaReadForPlan"
    effect = "Allow"
    actions = [
      "lambda:Describe*",
      "lambda:Get*",
      "lambda:List*",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "IAMReadForPlan"
    effect = "Allow"
    actions = [
      "iam:Describe*",
      "iam:Get*",
      "iam:List*",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "S3ReadForPlan"
    effect = "Allow"
    actions = [
      "s3:Describe*",
      "s3:Get*",
      "s3:List*",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "DynamoDBReadForPlan"
    effect = "Allow"
    actions = [
      "dynamodb:Describe*",
      "dynamodb:Get*",
      "dynamodb:List*",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "SNSReadForPlan"
    effect = "Allow"
    actions = [
      "sns:Describe*",
      "sns:Get*",
      "sns:List*",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "SQSReadForPlan"
    effect = "Allow"
    actions = [
      "sqs:Describe*",
      "sqs:Get*",
      "sqs:List*",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "VPCWrite"
    effect = "Allow"
    actions = [
      "ec2:CreateVpc",
      "ec2:DeleteVpc",
      "ec2:CreateSubnet",
      "ec2:DeleteSubnet",
      "ec2:CreateInternetGateway",
      "ec2:DeleteInternetGateway",
      "ec2:CreateRouteTable",
      "ec2:DeleteRouteTable",
      "ec2:CreateRoute",
      "ec2:DeleteRoute",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "SecurityGroupWrite"
    effect = "Allow"
    actions = [
      "ec2:CreateSecurityGroup",
      "ec2:UpdateSecurityGroupRuleDescriptionsIngress",
      "ec2:UpdateSecurityGroupRuleDescriptionsEgress",
      "ec2:DeleteSecurityGroup",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "EC2InstanceWrite"
    effect = "Allow"
    actions = [
      "ec2:CreateTags",
      "ec2:DeleteTags",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "RDSWrite"
    effect = "Allow"
    actions = [
      "rds:CreateDBInstance",
      "rds:DeleteDBInstance",
      "rds:ModifyDBInstance",
      "rds:CreateDBSubnetGroup",
      "rds:DeleteDBSubnetGroup",
      "rds:AddTagsToResource",
      "rds:RemoveTagsFromResource",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "LambdaWrite"
    effect = "Allow"
    actions = [
      "lambda:CreateFunction",
      "lambda:DeleteFunction",
      "lambda:UpdateFunctionCode",
      "lambda:UpdateFunctionConfiguration",
      "lambda:TagResource",
      "lambda:UntagResource",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "IAMWrite"
    effect = "Allow"
    actions = [
      "iam:CreateRole",
      "iam:DeleteRole",
      "iam:PutRolePolicy",
      "iam:DeleteRolePolicy",
      "iam:AttachRolePolicy",
      "iam:DetachRolePolicy",
      "iam:TagRole",
      "iam:UntagRole",
      "iam:PassRole",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "S3Write"
    effect = "Allow"
    actions = [
      "s3:CreateBucket",
      "s3:DeleteBucket",
      "s3:PutBucketPolicy",
      "s3:PutBucketTagging",
      "s3:PutObject",
      "s3:DeleteObject",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "DynamoDBWrite"
    effect = "Allow"
    actions = [
      "dynamodb:CreateTable",
      "dynamodb:DeleteTable",
      "dynamodb:UpdateTable",
      "dynamodb:TagResource",
      "dynamodb:UntagResource",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "SNSWrite"
    effect = "Allow"
    actions = [
      "sns:CreateTopic",
      "sns:DeleteTopic",
      "sns:TagResource",
      "sns:UntagResource",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "SQSWrite"
    effect = "Allow"
    actions = [
      "sqs:CreateQueue",
      "sqs:DeleteQueue",
      "sqs:TagQueue",
      "sqs:UntagQueue",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "StateBucketAccess"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:ListBucket",
    ]
    resources = [
      "arn:aws:s3:::${var.tf_state_bucket}",
      "arn:aws:s3:::${var.tf_state_bucket}/*",
    ]
  }

  statement {
    sid    = "LockTableAccess"
    effect = "Allow"
    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem",
    ]
    resources = [
      "arn:aws:dynamodb:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:table/${var.tf_lock_table}",
    ]
  }
}

resource "aws_iam_role_policy" "apply" {
  name   = "write-managed-resources"
  role   = aws_iam_role.apply.id
  policy = data.aws_iam_policy_document.apply_write.json
}

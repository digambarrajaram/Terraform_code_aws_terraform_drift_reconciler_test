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

data "aws_iam_policy_document" "apply_write" {
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
}

resource "aws_iam_role_policy" "apply" {
  name   = "write-managed-resources"
  role   = aws_iam_role.apply.id
  policy = data.aws_iam_policy_document.apply_write.json
}

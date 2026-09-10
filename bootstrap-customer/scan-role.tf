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
}

resource "aws_iam_role_policy" "scan" {
  name   = "read-managed-resources"
  role   = aws_iam_role.scan.id
  policy = data.aws_iam_policy_document.scan_read.json
}

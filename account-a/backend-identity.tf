# bootstrap/backend-identity.tf
#
# Identity used by Terraform's backend configuration. The user has no direct
# resource permissions; it can only assume the scoped scan/apply roles.

resource "aws_iam_user" "backend_identity" {
  name = "terraform-backend-${var.account_label}"

  tags = {
    Purpose = "terraform-backend-identity"
    Account = var.account_label
  }
}

data "aws_iam_policy_document" "backend_identity" {
  statement {
    sid     = "AssumeTerraformRoles"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    resources = [
      aws_iam_role.scan.arn,
      aws_iam_role.apply.arn,
    ]
  }
}

resource "aws_iam_user_policy" "backend_identity" {
  name   = "assume-terraform-roles"
  user   = aws_iam_user.backend_identity.name
  policy = data.aws_iam_policy_document.backend_identity.json
}

output "backend_identity_user_arn" {
  value = aws_iam_user.backend_identity.arn
}
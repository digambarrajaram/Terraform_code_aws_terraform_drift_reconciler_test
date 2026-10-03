data "aws_iam_policy_document" "ec2_backend_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ec2_backend" {
  name               = "terraform-backend-ec2-${var.account_label}"
  assume_role_policy = data.aws_iam_policy_document.ec2_backend_trust.json

  tags = {
    Purpose = "terraform-backend-ec2-role"
    Account = var.account_label
  }
}

resource "aws_iam_instance_profile" "ec2_backend" {
  name = "terraform-backend-ec2-${var.account_label}"
  role = aws_iam_role.ec2_backend.name
}

output "ec2_backend_role_arn" {
  value = aws_iam_role.ec2_backend.arn
}

output "ec2_backend_instance_profile_name" {
  value = aws_iam_instance_profile.ec2_backend.name
}
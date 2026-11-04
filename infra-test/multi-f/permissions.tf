data "aws_iam_policy_document" "apply_trust" {
  statement {
    sid     = "ProtectedGitHubEnvironmentOnly"
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:digambarrajaram/AWS-Terraform-Drift-Reconciler:environment:multi-f-apply"]
    }
  }

  statement {
    sid     = "DriftReconcilerBackendIdentity"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/terraform-backend-Secondary_AWS_Account"]
    }
  }
}

resource "aws_iam_role" "multi_f_apply" {
  name                 = "drift-reconciler-apply-MULTI"
  assume_role_policy   = data.aws_iam_policy_document.apply_trust.json
  max_session_duration = 3600

  tags = {
    Project = "drift-reconciler-test"
    Scope   = "multi-f"
    Purpose = "drift-reconciler-apply"
  }
}

data "aws_iam_policy_document" "multi_f_apply" {
  statement {
    sid    = "ManageScopeVpcAndEndpoint"
    effect = "Allow"
    actions = [
      "ec2:CreateVpc", "ec2:DeleteVpc", "ec2:ModifyVpcAttribute",
      "ec2:CreateSubnet", "ec2:DeleteSubnet", "ec2:ModifySubnetAttribute",
      "ec2:CreateRouteTable", "ec2:DeleteRouteTable", "ec2:CreateRoute",
      "ec2:DeleteRoute", "ec2:ReplaceRoute", "ec2:AssociateRouteTable",
      "ec2:DisassociateRouteTable", "ec2:CreateVpcEndpoint",
      "ec2:DeleteVpcEndpoints", "ec2:ModifyVpcEndpoint",
      "ec2:CreateSecurityGroup", "ec2:DeleteSecurityGroup",
      "ec2:AuthorizeSecurityGroupEgress", "ec2:RevokeSecurityGroupEgress",
      "ec2:CreateTags", "ec2:DeleteTags",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "DescribeScopeNetworking"
    effect = "Allow"
    actions = [
      "ec2:DescribeVpcs", "ec2:DescribeVpcAttribute", "ec2:DescribeSubnets",
      "ec2:DescribeRouteTables", "ec2:DescribeVpcEndpoints", "ec2:DescribePrefixLists",
      "ec2:DescribeSecurityGroups", "ec2:DescribeSecurityGroupRules",
      "ec2:DescribeTags", "ec2:DescribeAvailabilityZones",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "ManagePrivateApplicationBucket"
    effect = "Allow"
    actions = [
      "s3:CreateBucket", "s3:DeleteBucket", "s3:GetBucketLocation", "s3:ListBucket",
      "s3:GetBucketPolicy", "s3:PutBucketPolicy", "s3:DeleteBucketPolicy",
      "s3:GetBucketPublicAccessBlock", "s3:PutBucketPublicAccessBlock",
      "s3:DeleteBucketPublicAccessBlock", "s3:GetBucketOwnershipControls",
      "s3:PutBucketOwnershipControls", "s3:DeleteBucketOwnershipControls",
      "s3:GetBucketVersioning", "s3:PutBucketVersioning",
      "s3:GetEncryptionConfiguration", "s3:PutEncryptionConfiguration",
      "s3:GetBucketTagging", "s3:PutBucketTagging", "s3:DeleteBucketTagging",
      "s3:GetObject", "s3:PutObject", "s3:DeleteObject", "s3:GetObjectVersion",
    ]
    resources = ["arn:aws:s3:::${local.bucket_name}", "arn:aws:s3:::${local.bucket_name}/*"]
  }

  statement {
    sid       = "ManageRetainedTestSupport"
    effect    = "Allow"
    actions   = ["dynamodb:CreateTable", "dynamodb:DeleteTable", "dynamodb:UpdateTable", "dynamodb:DescribeTable", "dynamodb:TagResource", "dynamodb:UntagResource", "dynamodb:ListTagsOfResource", "sns:CreateTopic", "sns:DeleteTopic", "sns:GetTopicAttributes", "sns:SetTopicAttributes", "sns:TagResource", "sns:UntagResource", "sns:ListTagsForResource"]
    resources = ["arn:aws:dynamodb:${var.aws_region}:${data.aws_caller_identity.current.account_id}:table/${local.name_prefix}-items", "arn:aws:sns:${var.aws_region}:${data.aws_caller_identity.current.account_id}:${local.name_prefix}-events"]
  }

  statement {
    sid    = "ManageLambdaFunctionAndAlias"
    effect = "Allow"
    actions = [
      "lambda:CreateFunction", "lambda:DeleteFunction", "lambda:GetFunction",
      "lambda:GetFunctionConfiguration", "lambda:UpdateFunctionCode",
      "lambda:UpdateFunctionConfiguration", "lambda:PublishVersion",
      "lambda:CreateAlias", "lambda:UpdateAlias", "lambda:DeleteAlias",
      "lambda:GetAlias", "lambda:AddPermission", "lambda:RemovePermission",
      "lambda:GetPolicy", "lambda:TagResource", "lambda:UntagResource", "lambda:ListTags",
    ]
    resources = [
      "arn:aws:lambda:${var.aws_region}:${data.aws_caller_identity.current.account_id}:function:${local.name_prefix}-hello",
      "arn:aws:lambda:${var.aws_region}:${data.aws_caller_identity.current.account_id}:function:${local.name_prefix}-hello:*",
    ]
  }

  statement {
    sid       = "PassOnlyApplicationExecutionRole"
    effect    = "Allow"
    actions   = ["iam:PassRole"]
    resources = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${local.name_prefix}-lambda-execution"]
  }

  statement {
    sid    = "ManageOnlyApplicationExecutionRole"
    effect = "Allow"
    actions = [
      "iam:CreateRole", "iam:DeleteRole", "iam:GetRole", "iam:UpdateAssumeRolePolicy",
      "iam:TagRole", "iam:UntagRole", "iam:PutRolePolicy", "iam:DeleteRolePolicy",
      "iam:GetRolePolicy", "iam:ListRolePolicies",
    ]
    resources = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${local.name_prefix}-lambda-execution"]
  }

  statement {
    sid    = "ManageScopeLogGroups"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup", "logs:DeleteLogGroup", "logs:PutRetentionPolicy",
      "logs:DeleteRetentionPolicy", "logs:TagResource", "logs:UntagResource",
      "logs:ListTagsForResource", "logs:DescribeLogGroups",
      "logs:AssociateKmsKey", "logs:DisassociateKmsKey",
    ]
    resources = [
      "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${local.name_prefix}-hello",
      "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${local.name_prefix}-hello:*",
      "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/apigateway/${local.name_prefix}",
      "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/apigateway/${local.name_prefix}:*",
    ]
  }

  statement {
    sid       = "CreateTaggedScopeLogsKey"
    effect    = "Allow"
    actions   = ["kms:CreateKey"]
    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/Project"
      values   = [local.common_tags.Project]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/Scope"
      values   = [local.common_tags.Scope]
    }
  }

  statement {
    sid    = "ManageTaggedScopeLogsKey"
    effect = "Allow"
    actions = [
      "kms:CancelKeyDeletion", "kms:DescribeKey", "kms:DisableKeyRotation",
      "kms:EnableKeyRotation", "kms:GetKeyPolicy", "kms:GetKeyRotationStatus",
      "kms:ListResourceTags", "kms:PutKeyPolicy", "kms:ScheduleKeyDeletion",
      "kms:TagResource", "kms:UntagResource", "kms:UpdateKeyDescription",
    ]
    resources = ["arn:aws:kms:${var.aws_region}:${data.aws_caller_identity.current.account_id}:key/*"]

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/Project"
      values   = [local.common_tags.Project]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/Scope"
      values   = [local.common_tags.Scope]
    }
  }

  statement {
    sid       = "ManageScopeHttpApi"
    effect    = "Allow"
    actions   = ["apigateway:GET", "apigateway:POST", "apigateway:PUT", "apigateway:PATCH", "apigateway:DELETE"]
    resources = ["arn:aws:apigateway:${var.aws_region}::/apis", "arn:aws:apigateway:${var.aws_region}::/apis/*", "arn:aws:apigateway:${var.aws_region}::/domainnames", "arn:aws:apigateway:${var.aws_region}::/domainnames/*"]
  }

  statement {
    sid    = "ManageCustomDomainCertificate"
    effect = "Allow"
    actions = [
      "acm:RequestCertificate", "acm:DeleteCertificate", "acm:DescribeCertificate",
      "acm:AddTagsToCertificate", "acm:RemoveTagsFromCertificate", "acm:ListTagsForCertificate",
    ]
    resources = ["arn:aws:acm:${var.aws_region}:${data.aws_caller_identity.current.account_id}:certificate/*"]
  }

  statement {
    sid       = "ListCertificates"
    effect    = "Allow"
    actions   = ["acm:ListCertificates"]
    resources = ["*"]
  }

  statement {
    sid    = "CreateAndDiscoverHostedZone"
    effect = "Allow"
    actions = [
      "route53:CreateHostedZone", "route53:ListHostedZones",
      "route53:ListHostedZonesByName", "route53:ChangeTagsForResource",
    ]
    resources = ["*"]
  }

  dynamic "statement" {
    for_each = module.dns.zone_arn == null ? [] : [module.dns.zone_arn]

    content {
      sid    = "ManageOnlyThisHostedZone"
      effect = "Allow"
      actions = [
        "route53:DeleteHostedZone", "route53:GetHostedZone",
        "route53:ChangeResourceRecordSets", "route53:ListResourceRecordSets",
      ]
      resources = [statement.value]
    }
  }

  statement {
    sid       = "ReadRoute53ChangeStatus"
    effect    = "Allow"
    actions   = ["route53:GetChange"]
    resources = ["arn:aws:route53:::change/*"]
  }

  statement {
    sid    = "ReadAvailabilityZonesAndAccount"
    effect = "Allow"
    actions = [
      "ec2:DescribeAvailabilityZones",
      "sts:GetCallerIdentity",
    ]
    resources = ["*"]
  }

  statement {
    sid       = "ScopeStateAccess"
    effect    = "Allow"
    actions   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
    resources = ["arn:aws:s3:::sec-acc-tf-state-285629514281/multi_f/terraform.tfstate", "arn:aws:s3:::sec-acc-tf-state-285629514281/multi_f/terraform.tfstate.tflock"]
  }

  statement {
    sid       = "ScopeStateBucketList"
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = ["arn:aws:s3:::sec-acc-tf-state-285629514281"]

    condition {
      test     = "StringLike"
      variable = "s3:prefix"
      values   = ["multi_f/terraform.tfstate", "multi_f/terraform.tfstate.tflock"]
    }
  }
}

resource "aws_iam_role_policy" "multi_f_apply" {
  name   = "multi-f-managed-resources"
  role   = aws_iam_role.multi_f_apply.id
  policy = data.aws_iam_policy_document.multi_f_apply.json
}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_prefix_list" "s3" {
  name = "com.amazonaws.${var.aws_region}.s3"
}

locals {
  availability_zones = slice(data.aws_availability_zones.available.names, 0, 2)
  subnet_keys        = sort(keys(var.private_subnet_cidrs))
}

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(var.tags, { Name = "${var.name_prefix}-vpc" })
}

resource "aws_subnet" "private" {
  for_each = var.private_subnet_cidrs

  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value
  availability_zone       = local.availability_zones[index(local.subnet_keys, each.key)]
  map_public_ip_on_launch = false

  tags = merge(var.tags, {
    Name = each.key == "a" ? "${var.name_prefix}-private-subnet" : "${var.name_prefix}-private-subnet-${each.key}"
    Tier = "private"
  })
}

resource "aws_route_table" "private" {
  for_each = var.private_subnet_cidrs

  vpc_id = aws_vpc.this.id

  tags = merge(var.tags, {
    Name = each.key == "a" ? "${var.name_prefix}-private-rt" : "${var.name_prefix}-private-rt-${each.key}"
    Tier = "private"
  })
}

resource "aws_route_table_association" "private" {
  for_each = var.private_subnet_cidrs

  subnet_id      = aws_subnet.private[each.key].id
  route_table_id = aws_route_table.private[each.key].id
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.this.id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [for route_table in aws_route_table.private : route_table.id]
  policy            = data.aws_iam_policy_document.s3_endpoint.json

  tags = merge(var.tags, { Name = "${var.name_prefix}-s3-endpoint" })
}

data "aws_iam_policy_document" "s3_endpoint" {
  statement {
    sid       = "AllowOnlyApplicationBucket"
    effect    = "Allow"
    actions   = ["s3:GetObject", "s3:PutObject", "s3:ListBucket"]
    resources = [var.s3_bucket_arn, "${var.s3_bucket_arn}/*"]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }
}

resource "aws_security_group" "lambda" {
  name        = "${var.name_prefix}-lambda"
  description = "Lambda egress restricted to the private S3 gateway endpoint."
  vpc_id      = aws_vpc.this.id

  tags = merge(var.tags, { Name = "${var.name_prefix}-lambda-sg" })
}

resource "aws_vpc_security_group_egress_rule" "s3_https" {
  security_group_id = aws_security_group.lambda.id
  description       = "HTTPS to the regional S3 prefix list through the gateway endpoint."
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  prefix_list_id    = data.aws_prefix_list.s3.id
}

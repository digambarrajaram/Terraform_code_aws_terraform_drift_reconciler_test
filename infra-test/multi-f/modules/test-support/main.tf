resource "aws_dynamodb_table" "items" {
  name         = "${var.name_prefix}-items"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  point_in_time_recovery {
    enabled = true
  }

  tags = merge(var.tags, { Name = "${var.name_prefix}-items" })
}

resource "aws_sns_topic" "events" {
  name = "${var.name_prefix}-events"
  tags = merge(var.tags, { Name = "${var.name_prefix}-events" })

  kms_master_key_id = "alias/aws/sns"
}
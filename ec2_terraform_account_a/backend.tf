
data "aws_caller_identity" "aws" {}

# Terraform backend configuration for EC2 module
# Uses S3 bucket and DynamoDB table created by bootstrap module
terraform {
  backend "s3" {
    bucket       = "sec-acc-tf-state-285629514281"
    key          = "ec2_scope_a/terraform.tfstate"
    region       = "us-east-1"
    profile      = "sec_acc"
    encrypt      = true
    use_lockfile = true
  }
}

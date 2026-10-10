variable "env_id" {
  description = "Unique customer environment identifier used in the role names"
  type        = string
  default     = "PROD_SETUP"
}

variable "backend_role_arn" {
  description = "ARN of the fixed backend EC2 role trusted by these customer roles and granted scoped sts:AssumeRole access"
  type        = string
  default     = "arn:aws:iam::285629514281:role/drift-reconciler-ec2-backend"
}

variable "tf_state_bucket" {
  description = "S3 bucket containing this customer's Terraform state"
  type        = string
  default     = "sec-acc-tf-state-285629514281"
}

variable "tf_lock_table" {
  description = "DynamoDB table used for this customer's Terraform state locking"
  type        = string
  default     = "terraform-locks"
}

variable "managed_resource_prefix" {
  description = "Optional naming prefix for resources managed by the reconciler"
  type        = string
  default     = null
  nullable    = true
}

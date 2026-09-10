variable "env_id" {
  description = "Unique customer environment identifier used in the role names"
  type        = string
}

variable "backend_role_arn" {
  description = "ARN of the fixed backend EC2 role trusted to assume these customer roles"
  type        = string
  default     = "arn:aws:iam::605134452604:role/terraform-backend-ec2-scope-a"
}

variable "managed_resource_prefix" {
  description = "Optional naming prefix for resources managed by the reconciler"
  type        = string
  default     = null
  nullable    = true
}

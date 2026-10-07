variable "domain_name" {
  type = string
}

variable "api_subdomain_label" {
  type = string
}

variable "enable_custom_domain" {
  type = bool
}

variable "api_id" {
  type = string
}

variable "api_stage_name" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "tags" {
  type = map(string)
}

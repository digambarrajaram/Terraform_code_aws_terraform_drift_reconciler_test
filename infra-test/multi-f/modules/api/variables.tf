variable "name_prefix" {
  type = string
}

variable "lambda_function_name" {
  type = string
}

variable "lambda_alias_name" {
  type = string
}

variable "lambda_invoke_arn" {
  type = string
}

variable "allowed_origins" {
  type    = list(string)
  default = []
}

variable "disable_execute_api_endpoint" {
  type    = bool
  default = false
}

variable "throttling_burst_limit" {
  type    = number
  default = 20
}

variable "throttling_rate_limit" {
  type    = number
  default = 10
}

variable "tags" {
  type = map(string)
}

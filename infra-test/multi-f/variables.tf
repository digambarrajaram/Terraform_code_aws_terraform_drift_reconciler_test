variable "aws_region" {
  description = "AWS region for the multi-f test scope."
  type        = string
  default     = "us-east-1"
}

variable "domain_name" {
  description = "Optional registered DNS domain for a Route 53 hosted zone and API custom domain; leave blank until you own one."
  type        = string
  default     = ""

  validation {
    condition     = trimspace(var.domain_name) == "" || (can(regex("^[A-Za-z0-9.-]+$", var.domain_name)) && length(split(".", var.domain_name)) >= 2)
    error_message = "domain_name must be blank or a valid-looking fully qualified DNS domain."
  }
}

variable "api_subdomain_label" {
  description = "Hostname label used for the API custom domain."
  type        = string
  default     = "api"
}

variable "enable_custom_domain" {
  description = "Enable ACM validation, API Gateway custom-domain mapping, and Route 53 alias records after the hosted zone is delegated."
  type        = bool
  default     = false
}

variable "allowed_origins" {
  description = "Browser origins allowed by API Gateway CORS. Leave empty when the API is called only by non-browser clients."
  type        = list(string)
  default     = []
}

variable "vpc_cidr" {
  description = "CIDR block for the isolated Lambda VPC."
  type        = string
  default     = "10.46.0.0/16"
}

variable "private_subnet_cidrs" {
  description = "Two private subnet CIDRs in distinct Availability Zones."
  type        = map(string)
  default = {
    a = "10.46.2.0/24"
    b = "10.46.3.0/24"
  }

  validation {
    condition     = length(var.private_subnet_cidrs) == 2 && contains(keys(var.private_subnet_cidrs), "a") && contains(keys(var.private_subnet_cidrs), "b")
    error_message = "private_subnet_cidrs must define exactly the a and b subnet keys."
  }
}

variable "api_throttling_burst_limit" {
  description = "Maximum short API request burst per route."
  type        = number
  default     = 20
}

variable "api_throttling_rate_limit" {
  description = "Steady-state API requests per second per route."
  type        = number
  default     = 10
}

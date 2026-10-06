data "aws_caller_identity" "current" {}

locals {
  scope       = "multi-f"
  name_prefix = "drift-reconciler-test-${local.scope}"
  bucket_name = "${local.name_prefix}-${data.aws_caller_identity.current.account_id}"
  common_tags = {
    Project   = "drift-reconciler-test"
    Scope     = local.scope
    ManagedBy = "Terraform"
  }
}


module "storage" {
  source      = "./modules/storage"
  bucket_name = local.bucket_name
  tags        = local.common_tags
}

module "network" {
  source               = "./modules/network"
  name_prefix          = local.name_prefix
  aws_region           = var.aws_region
  vpc_cidr             = var.vpc_cidr
  private_subnet_cidrs = var.private_subnet_cidrs
  s3_bucket_arn        = module.storage.bucket_arn
  tags                 = local.common_tags
}

module "test_support" {
  source      = "./modules/test-support"
  name_prefix = local.name_prefix
  tags        = local.common_tags
}

module "app" {
  source             = "./modules/app"
  name_prefix        = local.name_prefix
  bucket_name        = module.storage.bucket_name
  bucket_arn         = module.storage.bucket_arn
  private_subnet_ids = module.network.private_subnet_ids
  security_group_id  = module.network.lambda_security_group_id
  tags               = local.common_tags
}

module "api" {
  source                       = "./modules/api"
  name_prefix                  = local.name_prefix
  lambda_function_name         = module.app.function_name
  lambda_alias_name            = module.app.alias_name
  lambda_invoke_arn            = module.app.invoke_arn
  allowed_origins              = var.allowed_origins
  disable_execute_api_endpoint = var.enable_custom_domain
  throttling_burst_limit       = var.api_throttling_burst_limit
  throttling_rate_limit        = var.api_throttling_rate_limit
  tags                         = local.common_tags
}

module "dns" {
  source               = "./modules/dns"
  domain_name          = var.domain_name
  api_subdomain_label  = var.api_subdomain_label
  enable_custom_domain = var.enable_custom_domain
  api_id               = module.api.api_id
  api_stage_name       = module.api.stage_name
  aws_region           = var.aws_region
  tags                 = local.common_tags
}

terraform {
  backend "s3" {
    bucket       = "sec-acc-tf-state-285629514281"
    key          = "lambda_scope_a/terraform.tfstate"
    region       = "us-east-1"
    profile      = "default"
    encrypt      = true
    use_lockfile = true
  }
}

terraform {
  backend "s3" {
    bucket       = "sec-acc-tf-state-285629514281"
    key          = "multi_f/terraform.tfstate"
    region       = "us-east-1"
    profile      = "default"
    encrypt      = true
    use_lockfile = true
  }
}

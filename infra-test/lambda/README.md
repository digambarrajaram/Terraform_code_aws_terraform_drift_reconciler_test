# Lambda test scope

This independent Terraform root deploys a minimal Python Lambda function for
smoke-testing AWS Lambda deployment.

## Resources

- Lambda function `account-a-hello` using Python 3.12, 128 MB memory, and a
  10-second timeout.
- Lambda execution role with permission to write to its dedicated log group.
- CloudWatch log group with 14-day retention.

The function returns a JSON greeting. Its deployment package is generated from
inline source during Terraform operations.

## State and region

The S3 backend uses bucket `sec-acc-tf-state-285629514281`, key
`lambda_scope_a/terraform.tfstate`, and region `us-east-1`. It uses S3 backend
lockfiles; Terraform 1.10 or later is required. Confirm the bucket and AWS
credentials belong to the intended test account before initializing.

## Workflow

From this directory:

```sh
terraform init
terraform validate
terraform plan
terraform apply
```

Review the plan before applying. Terraform outputs the function name and ARN.
When the test is complete, run `terraform destroy` here and review the plan
before confirming. Lambda requests and CloudWatch Logs may incur usage-based
charges.

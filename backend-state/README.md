# Backend state

This Terraform root creates the S3 bucket and DynamoDB table used by other
stacks for remote state and state locking.

## Resources

- S3 state bucket with versioning, AES-256 server-side encryption, and public
  access blocked.
- On-demand DynamoDB lock table with a string `LockID` partition key.

The bucket is configured with `force_destroy = true`. Review this behavior and
the plan carefully: destroying the root can delete the bucket and its stored
state objects.

## Prerequisites

- AWS CLI credentials for the account that will own the state resources.
- Terraform 1.5 or later and the AWS provider constraint in `versions.tf`.
- A globally unique S3 bucket name.

## Variables

| Variable | Purpose | Default |
| --- | --- | --- |
| `account_label` | Resource tag identifying the account. | `sec_acc` |
| `aws_region` | Region for the bucket and lock table. | `us-east-1` |
| `state_bucket_name` | Globally unique bucket name. | `sec-acc-tf-state-285629514281` |
| `lock_table_name` | DynamoDB lock table name. | `terraform-locks` |

Override defaults with a local `terraform.tfvars` file or `-var` arguments.
Do not commit account-specific values or credentials.

## Create the backend

Run from this directory:

```sh
terraform init
terraform validate
terraform plan
terraform apply
```

This root has no remote backend configured, so its own Terraform state is
local. Keep `terraform.tfstate` and backups secure and available for future
updates to these resources. Do not delete the local state after creating the
bucket.

## Configure dependent roots

Set the bucket and lock-table names in each dependent root's backend and access
policies. Remote S3 backend locking uses the S3 lockfile option; use Terraform
1.10 or later for roots configured with `use_lockfile = true`.

Before changing an existing root from local to remote state, back up the state
and use Terraform's state migration prompt (`terraform init -migrate-state`).
Never copy, overwrite, or delete state objects without first verifying which
root and key they belong to.

## Teardown

Destroying this root can remove the shared state bucket and lock table and
therefore disrupt every dependent Terraform root. Only do so after all dependent
stacks have been migrated or retired and their state has been backed up.

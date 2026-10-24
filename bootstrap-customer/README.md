# Bootstrap customer account

This Terraform root creates scan and apply IAM roles in a target customer
account. The roles trust a separately managed backend role using AWS
`sts:AssumeRole`; this root does not create a GitHub OIDC provider or configure
GitHub trust directly.

## Resources and access

- A read-only scan role trusted by `backend_role_arn`.
- An apply role trusted by the same backend role and granted configured
  write-access policies.
- S3 state and DynamoDB lock-table permissions needed by the customer roles.

The scan policy currently grants broad read access across several AWS services
for this test setup. Treat it as test infrastructure, review its policy before
use, and do not assume that it is a production least-privilege policy.

## Prerequisites

- Terraform 1.5 or later and AWS provider `~> 6.0`.
- AWS credentials for the target customer account with permission to create
  IAM roles and policies.
- The backend role must already exist, and its permissions/trust must allow
  the intended role-assumption flow.
- The configured state bucket and lock table must exist.

## Variables

| Variable | Purpose | Default |
| --- | --- | --- |
| `env_id` | Identifier appended to customer role names. | `PROD_SETUP` |
| `backend_role_arn` | Existing backend role trusted by the created roles. | Account-specific ARN |
| `tf_state_bucket` | S3 bucket containing Terraform state. | `sec-acc-tf-state-285629514281` |
| `tf_lock_table` | DynamoDB table used for state locking. | `terraform-locks` |
| `managed_resource_prefix` | Optional prefix used to scope applicable permissions; `null` disables the prefix filter. | `null` |

Set the values for the target account before applying. In particular, verify
the backend role ARN and state resources rather than relying on the example
defaults.

## Workflow

From this directory:

```sh
terraform init
terraform validate
terraform plan
terraform apply
```

Inspect the plan and confirm that it targets the intended customer account.
Terraform outputs the `scan_role_arn` and `apply_role_arn` values.

## Teardown

Only destroy these roles after the reconciler and any backend workflows have
stopped using them. Review the destroy plan to confirm it affects only this
account's intended roles and policies.

# Account permissions

This Terraform root configures IAM access for the drift-reconciler automation
account. Apply it only in the intended account after reviewing all trust
policies and permission scopes.

## What it creates

- A backend IAM user limited to assuming configured scan/apply roles and a
  separately defined multi-f apply role.
- A scan role with read permissions and state access needed for plan/refresh
  operations.
- An apply role for the configured GitHub Actions repository/environment.
- An EC2 role and instance profile for a backend workload.
- Optionally, the GitHub Actions OIDC identity provider.

The scan role's GitHub trust is scoped to the configured branch. The apply role
uses a GitHub environment trust condition; configure required reviewers in that
GitHub environment separately. The `backend-identity` IAM user policy is for
role assumption, not a general-purpose administrator policy.

## Prerequisites

- Terraform 1.5 or later and AWS provider `~> 6.0`.
- AWS credentials for the automation account with permission to manage the IAM
  resources in the plan.
- The state bucket and lock table named by the variables, if not already
  provisioned.
- The GitHub repository and protected environment used in trust conditions.

## Variables

| Variable | Purpose | Default |
| --- | --- | --- |
| `account_label` | Account identifier used in role names and tags. | `Secondary_AWS_Account` |
| `aws_region` | AWS region used by the provider and state permissions. | `us-east-1` |
| `state_bucket_name` | S3 bucket containing Terraform state. | `Secondary-AWS-Account-tf-state-285629514281` |
| `lock_table_name` | DynamoDB state-lock table. | `terraform-locks` |
| `github_org` / `github_repo` | Repository allowed to federate through GitHub OIDC. | `digambarrajaram` / `AWS-Terraform-Drift-Reconciler` |
| `scan_allowed_branch` | Branch allowed to assume the scan role. | `main` |
| `apply_environment_name` | GitHub environment required by apply-role trust. | `sec-acc-apply` |
| `managed_resource_prefix` | Prefix used to scope configured write permissions. | `sec-acc-` |
| `create_oidc_provider` | Whether this root creates the account's GitHub OIDC provider. | `false` |
| `existing_oidc_provider_arn` | Existing provider ARN when creation is disabled. | Account-specific ARN |

An AWS account can have only one GitHub OIDC provider for this issuer. Check
whether one already exists before setting `create_oidc_provider = true`; if it
does, keep it false and set the correct `existing_oidc_provider_arn`.

## Workflow

From this directory:

```sh
terraform init
terraform validate
terraform plan
terraform apply
```

Confirm the AWS account and inspect the plan before applying. Record the role
ARNs from Terraform outputs for the relevant automation configuration. Before
destroying this root, remove or update every workflow, customer trust, and
backend dependency that relies on these roles or the OIDC provider.

## Security

Trust conditions and IAM permissions are intentionally specific to this
repository's test setup. Confirm account IDs, GitHub organization/repository,
branch and environment names, S3 prefixes, and lock-table scope before use.
Do not commit credentials or state files.

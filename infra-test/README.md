# Infrastructure test scopes

Each directory listed below is an independent Terraform root with its own
resources and remote state key. Never run Terraform from this directory to
manage a child scope, and do not combine state between scopes.

## Available scopes

| Scope | Directory | State key | Summary |
| --- | --- | --- | --- |
| Lambda | [`lambda/`](./lambda/) | `lambda_scope_a/terraform.tfstate` | Minimal Python Lambda deployment, execution role, and 14-day CloudWatch log group. |
| Multi-f | [`multi-f/`](./multi-f/) | `multi_f/terraform.tfstate` | Private-network Lambda and S3-backed API, HTTP API with IAM authorization, optional custom domain, and test-support resources. |

The active backend bucket and region are listed in [`scope-registry.json`](./scope-registry.json).
Its role ARNs, bucket names, state keys, and regions are deployment-specific:
verify them against the intended AWS account before use.

## Preflight check

Run the scope registry check before operating a scope:

```powershell
.\check_scopes.ps1
```

The script verifies each registered directory and compares its backend bucket,
key, and region with the Terraform backend configuration. It does not check AWS
credentials, role access, or cloud resource health.

## Run a scope

Change to the scope's directory, then run `terraform init`, `terraform
validate`, `terraform plan`, and `terraform apply`. Inspect the plan and confirm
the AWS account and role before applying. Use Terraform 1.10 or later because
the S3 backend uses lockfiles.

When testing is complete, run `terraform destroy` from that same scope directory
after reviewing the plan. The Lambda and multi-f scopes can incur usage-based
charges. `multi-f` avoids NAT and interface endpoint hourly charges, but an
optional Route 53 public hosted zone is billed after a domain is configured;
domain registration may cost extra. Current AWS prices and Free Tier eligibility
vary.

S3 versioning retains previous object versions; clean up test objects and
consider retained versions when estimating storage costs.

## Retired scope

The standalone EC2 test scope is no longer present in the registry or
configuration. Its previous remote state key, `ec2_scope_a/terraform.tfstate`,
is not managed or deleted by the current scope configuration.



# `multi-f` modular serverless test stack

This independent Terraform root deploys a private-network Lambda and an
IAM-authorized HTTP API, with optional DNS/custom-domain resources. Terraform
modules are under `modules/`.

## Components

- `network`: VPC, two private subnets in separate Availability Zones, isolated
  route tables, Lambda security group, and an S3 gateway endpoint. There is no
  NAT gateway or paid interface endpoint.
- `storage`: private, versioned, AES-256-encrypted S3 bucket with public access
  blocked and a TLS-only bucket policy.
- `app`: Python Lambda in the private subnets with scoped S3 access, log
  retention, a published version, and a stable `live` alias.
- `api`: HTTP API with IAM/SigV4 authorization, throttling, access logging, and
  Lambda alias integration. CORS is enabled only when `allowed_origins` is
  explicitly configured.
- `dns`: optional Route 53 public hosted zone, ACM certificate, API custom
  domain, and DNS aliases.
- `test-support`: DynamoDB table and SNS topic retained for testing.
- `trivy-e2e.tf`: ECR repository fixture for testing image-tag mutability
  remediation.

The Lambda supports `GET /health`, `PUT /objects/{key}`, and
`GET /objects/{key}`. API routes require AWS IAM authorization; callers must
sign requests with SigV4. When the custom domain is enabled, the default
API Gateway endpoint is disabled.

## State and inputs

The S3 backend uses key `multi_f/terraform.tfstate` and is independent of the
Lambda scope. It uses S3 backend lockfiles, so Terraform 1.10 or later is
required. The main inputs are:

| Variable | Purpose | Default |
| --- | --- | --- |
| `aws_region` | Region for the stack. | `us-east-1` |
| `domain_name` | Optional registered DNS domain; blank disables DNS resources. | `""` |
| `api_subdomain_label` | Label used for the API custom hostname. | `api` |
| `enable_custom_domain` | Enables the custom domain after DNS delegation. | `false` |
| `allowed_origins` | Explicit browser origins allowed by CORS. | `[]` |
| `vpc_cidr` | VPC address range. | `10.46.0.0/16` |
| `private_subnet_cidrs` | Two private subnet ranges (`a` and `b`). | `10.46.2.0/24`, `10.46.3.0/24` |
| `api_throttling_burst_limit` | Per-route request burst limit. | `20` |
| `api_throttling_rate_limit` | Per-route steady request rate. | `10` requests/second |

The backend bucket and region are fixed in `backend.tf`; confirm these and the
scope role in `permissions.tf` match the intended account before initializing.

## Preflight and deploy

Run the scope preflight from `infra-test/`:

```powershell
.\check_scopes.ps1
```

Then, from this directory:

```sh
terraform init
terraform validate
terraform plan
terraform apply
```

With the default blank `domain_name` and `enable_custom_domain = false`, the
regional API endpoint is available from `terraform output api_url`; no hosted
zone or certificate is created.

## Optional custom domain

Only configure this after you own a registered domain. First set the domain
while leaving `enable_custom_domain = false`, then apply and retrieve
`terraform output route53_name_servers`. Delegate those name servers at the
registrar and wait for DNS propagation. Then set `enable_custom_domain = true`
and apply again to request/validate the ACM certificate and configure the API
domain and DNS aliases. Enabling the custom domain with a blank domain is
invalid.

The Route 53 hosted zone incurs a recurring charge when created (check current
AWS pricing); domain registration may cost extra. Lambda, HTTP API, S3, and
CloudWatch Logs also have usage-based charges. S3 versioning retains previous
object versions; delete test objects and review the plan before destroying the
stack.

## Existing state and teardown

`moved.tf` declares state moves for resources moved into modules. The previous
public-subnet/Internet-Gateway networking path is retired in favor of private
subnets and the S3 gateway endpoint. If using existing state, inspect the
Terraform plan carefully; removal of retired resources may be expected, but
must be verified for your environment before applying.

Destroy this stack from this directory when testing is complete, after
reviewing the plan. The retired EC2 test scope and its former state key are not
managed or deleted by this configuration.
# `multi-f` modular serverless test stack

This Terraform root composes focused modules under `modules/`:

- `network`: VPC, two private subnets in separate AZs, isolated route tables,
	Lambda security group, and an S3 gateway endpoint. There is no NAT gateway
	or paid interface endpoint.
- `storage`: private, versioned, AES-256-encrypted S3 bucket with public access
	blocked and TLS-only bucket policy.
- `app`: Python Lambda in the private subnets, least-privilege S3 access,
	shared account concurrency (no reserved allocation), log retention,
	published version, and stable `live` alias. API Gateway throttling limits
	request rates without consuming the account's reserved-concurrency budget.
- `api`: HTTP API with IAM/SigV4 authorization, throttling, KMS-encrypted
	access logs, and Lambda alias integration. CORS is enabled only when
	`allowed_origins` contains explicit origins.
- `dns`: Route 53 public hosted zone, plus optional ACM certificate, API
	Gateway custom domain, and DNS aliases after domain delegation.
- `test-support`: the original on-demand DynamoDB table and SNS topic.

The Lambda exposes `GET /health`, `PUT /objects/{key}`, and
`GET /objects/{key}`. HTTP API routes require AWS IAM authorization; callers
must sign requests with SigV4. The API Gateway endpoint is disabled when the
custom domain is enabled.

## Provisioning sequence

The scope uses `multi_f/terraform.tfstate`, independent of the Lambda scope.
Run `./check_scopes.ps1` from `infra-test/` first. `domain_name` defaults to
blank, so you can provision the API without owning a domain.

With a blank domain and the default `enable_custom_domain=false`, the DNS module
creates no hosted zone or certificate. The IAM-authorized regional API endpoint
is still available through `terraform output api_url`.

When you later own a registered domain, first apply with
`-var domain_name="example.com"` and `-var enable_custom_domain=false`. Read
`route53_name_servers` and delegate them at the registrar. After delegation
propagates, apply again with the same domain and
`-var enable_custom_domain=true`; Terraform then requests/validates the ACM
certificate, configures the API domain, and creates A/AAAA alias records. Using
`enable_custom_domain=true` without a domain fails with a clear precondition.

The Route 53 hosted zone is billable at about **$0.50/month only after you
provide a domain name**; a domain registration may cost extra. Lambda, HTTP API, S3 storage,
and CloudWatch Logs have usage-based charges and account-dependent Free Tier
eligibility. S3 versioning retains overwritten object versions; delete test
objects and destroy the stack when finished. This design avoids NAT gateway
and interface endpoint hourly charges.

The previous multi-f resources have state-move declarations in `moved.tf` so
retained objects can keep their Terraform identities as they enter modules.
The old public subnet/Internet Gateway path is retired in favor of private
Lambda subnets and the S3 gateway endpoint. Review the Terraform plan carefully
before applying: removal of the old public networking resources is expected.
No plan or apply has been run as part of this code change.

The standalone EC2 test scope is retired. Its remote state object, if present,
is not destroyed or removed by this configuration change.
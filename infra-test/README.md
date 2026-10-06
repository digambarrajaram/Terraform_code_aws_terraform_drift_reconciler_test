# Infrastructure test scopes

Each scope below is an independent Terraform root with its own configuration,
role, and remote state key. They share only this routing manifest and preflight
script; do not combine their state.

| Scope | Configuration | Resources | Remote state key | Approximate cost |
| --- | --- | --- | --- | --- |
| Lambda | `lambda/` | Small Python Lambda function, execution role/policy, and a CloudWatch log group (14-day retention). | `lambda_scope_a/terraform.tfstate` | Near **$0/month** at low request volume; requests, duration, and logs are usage-based. |
| Multi-f | `multi-f/` | Private VPC subnets in two AZs, S3 gateway endpoint, encrypted/versioned private S3, VPC-attached Lambda, IAM-authorized HTTP API, optional Route 53/ACM custom domain, and retained DynamoDB/SNS test-support resources. | `multi_f/terraform.tfstate` | No NAT or interface endpoint charges. Lambda/API/S3/log usage is metered; the Route 53 public hosted zone costs about **$0.50/month**, plus domain registration if needed. |

Free Tier allowances depend on account age, plan, region, and current AWS pricing;
they are not a guarantee of zero cost. S3 versioning retains prior object versions,
so remove test objects and destroy the stack when finished. A Route 53 hosted zone
is created and billed only after you configure a domain name.

Run `./check_scopes.ps1` from this directory to verify each manifest path and
backend configuration before using a scope. `scope-registry.json` routes all
three scopes; its role ARNs, backend buckets, backend keys, and region values
remain specific to each scope.

The standalone EC2 test scope has been retired. Its remote state key
(`ec2_scope_a/terraform.tfstate`) is intentionally no longer routed by this
registry; no AWS resources were destroyed as part of removing its configuration.

**Remove the multi-f test stack when finished testing** to avoid hosted-zone and
usage-based charges. The Lambda scope is also test infrastructure; remove it
when no longer needed.

















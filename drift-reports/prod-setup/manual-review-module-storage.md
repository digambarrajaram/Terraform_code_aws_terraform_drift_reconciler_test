# Manual review: `module.storage`

- **`AWS-0094`** — no applicable automated fix
- **`AWS-0086`** — automated fix did not clear Trivy finding
- **`AWS-0087`** — automated fix did not clear Trivy finding
- **`AWS-0091`** — automated fix did not clear Trivy finding
- **`AWS-0093`** — automated fix did not clear Trivy finding
- **`AWS-0090`** — automated fix did not clear Trivy finding

### Why no automated fix

```text
AWS-0094 (module.storage): Define a aws_s3_bucket_public_access_block for the given bucket to control public access policies
AWS-0086 (module.storage): LLM rewrote block for: S3 Access block should block public ACL
AWS-0087 (module.storage): LLM rewrote block for: S3 Access block should block public policy
AWS-0091 (module.storage): LLM rewrote block for: S3 Access Block should Ignore Public ACL
AWS-0093 (module.storage): LLM rewrote block for: S3 Access block should restrict public bucket to limit access
AWS-0090 (module.storage): LLM rewrote block for: S3 Data should be versioned
```

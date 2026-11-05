# Unmanaged resource: aws_s3_bucket.demo-acct-unmanaged-test

Resource exists in AWS but is not tracked in Terraform state and has no ManagedBy tag. It was likely created manually or by another tool. Consider importing it or adding a .tf resource block.

```json
{
  "type": "aws_s3_bucket",
  "id": "demo-acct-unmanaged-test",
  "arn": "arn:aws:s3:::demo-acct-unmanaged-test",
  "tags": {},
  "is_default": false,
  "raw_name": "demo-acct-unmanaged-test",
  "created_at": "2026-11-04T12:57:13+00:00"
}
```

**Action:** Import this resource into Terraform or create the corresponding `.tf` resource block, then re-run the drift reconciler to track it.
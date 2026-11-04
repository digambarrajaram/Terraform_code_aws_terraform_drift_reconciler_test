# Unmanaged resource: aws_s3_bucket.prod-demo-tf-state-285629514281

Resource exists in AWS but is not tracked in Terraform state and has no ManagedBy tag. It was likely created manually or by another tool. Consider importing it or adding a .tf resource block.

```json
{
  "type": "aws_s3_bucket",
  "id": "prod-demo-tf-state-285629514281",
  "arn": "arn:aws:s3:::prod-demo-tf-state-285629514281",
  "tags": {},
  "is_default": false,
  "raw_name": "prod-demo-tf-state-285629514281",
  "created_at": "2026-11-04T10:13:22+00:00"
}
```

**Action:** Import this resource into Terraform or create the corresponding `.tf` resource block, then re-run the drift reconciler to track it.
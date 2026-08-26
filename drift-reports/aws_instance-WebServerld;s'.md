# Unmanaged resource: aws_instance.WebServerld;s'

Resource exists in AWS but is not tracked in Terraform state and has no ManagedBy tag. It was likely created manually or by another tool. Consider importing it or adding a .tf resource block. Estimated cost: $7.59/mo ($0.0104/hr). Accrued: $0.07.

```json
{
  "type": "aws_instance",
  "id": "i-022136c58192a6827",
  "arn": "arn:aws:ec2:us-east-1:285629514281:instance/i-022136c58192a6827",
  "tags": {
    "Name": "WebServerld;s'"
  },
  "is_default": false,
  "raw_name": "WebServerld;s'",
  "spec": "t3.micro",
  "state": "running",
  "created_at": "2026-08-24T05:29:50+00:00"
}
```

**Action:** Import this resource into Terraform or create the corresponding `.tf` resource block, then re-run the drift reconciler to track it.

### Cost Estimate

- Hourly rate: $0.0104
- Estimated monthly: **$7.59**
- Accrued since creation: $0.07
- Running for: 7.0 hours

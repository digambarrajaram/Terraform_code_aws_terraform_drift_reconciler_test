# Unmanaged resource: aws_instance.WebServer

Resource exists in AWS but is not tracked in Terraform state and has no ManagedBy tag. It was likely created manually or by another tool. Consider importing it or adding a .tf resource block. Estimated cost: $8.47/mo ($0.0116/hr). Accrued: $0.28.

```json
{
  "type": "aws_instance",
  "id": "i-083567724a54ab6e5",
  "arn": "arn:aws:ec2:us-east-1:605134452604:instance/i-083567724a54ab6e5",
  "tags": {
    "Name": "WebServer"
  },
  "is_default": false,
  "raw_name": "WebServer",
  "spec": "t2.micro",
  "state": "running",
  "created_at": "2026-09-10T10:28:21+00:00"
}
```

**Action:** Import this resource into Terraform or create the corresponding `.tf` resource block, then re-run the drift reconciler to track it.

### Cost Estimate

- Hourly rate: $0.0116
- Estimated monthly: **$8.47**
- Accrued since creation: $0.28
- Running for: 23.8 hours

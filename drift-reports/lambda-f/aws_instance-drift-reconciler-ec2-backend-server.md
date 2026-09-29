# Unmanaged resource: aws_instance.drift-reconciler-ec2-backend-server

Resource exists in AWS but is not tracked in Terraform state and has no ManagedBy tag. It was likely created manually or by another tool. Consider importing it or adding a .tf resource block.

```json
{
  "type": "aws_instance",
  "id": "i-01b972487c551350b",
  "arn": "arn:aws:ec2:us-east-1:285629514281:instance/i-01b972487c551350b",
  "tags": {
    "Name": "drift-reconciler-ec2-backend-server"
  },
  "is_default": false,
  "raw_name": "drift-reconciler-ec2-backend-server",
  "spec": "m7i-flex.large",
  "state": "running",
  "created_at": "2026-09-10T15:58:23+00:00"
}
```

**Action:** Import this resource into Terraform or create the corresponding `.tf` resource block, then re-run the drift reconciler to track it.
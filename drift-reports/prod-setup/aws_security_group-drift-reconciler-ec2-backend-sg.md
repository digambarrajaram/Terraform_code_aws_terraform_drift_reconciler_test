# Unmanaged resource: aws_security_group.drift-reconciler-ec2-backend-sg

Resource exists in AWS but is not tracked in Terraform state and has no ManagedBy tag. It was likely created manually or by another tool. Consider importing it or adding a .tf resource block.

```json
{
  "type": "aws_security_group",
  "id": "sg-0eb602a8985a5fb6e",
  "arn": "arn:aws:ec2:us-east-1:285629514281:security-group/sg-0eb602a8985a5fb6e",
  "tags": {},
  "is_default": false,
  "raw_name": "drift-reconciler-ec2-backend-sg",
  "created_at": null
}
```

**Action:** Import this resource into Terraform or create the corresponding `.tf` resource block, then re-run the drift reconciler to track it.
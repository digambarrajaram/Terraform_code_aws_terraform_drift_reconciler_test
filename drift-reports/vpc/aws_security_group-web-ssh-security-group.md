# Unmanaged resource: aws_security_group.web-ssh-security-group

Resource exists in AWS but is not tracked in Terraform state and has no ManagedBy tag. It was likely created manually or by another tool. Consider importing it or adding a .tf resource block.

```json
{
  "type": "aws_security_group",
  "id": "sg-0c77198be0dec41ff",
  "arn": "arn:aws:ec2:us-east-1:605134452604:security-group/sg-0c77198be0dec41ff",
  "tags": {
    "Name": "drift-web-ssh-sg"
  },
  "is_default": false,
  "raw_name": "web-ssh-security-group",
  "created_at": null
}
```

**Action:** Import this resource into Terraform or create the corresponding `.tf` resource block, then re-run the drift reconciler to track it.
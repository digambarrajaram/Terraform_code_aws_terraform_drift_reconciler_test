# Unmanaged resource: aws_internet_gateway.drift-igw

Resource exists in AWS but is not tracked in Terraform state and has no ManagedBy tag. It was likely created manually or by another tool. Consider importing it or adding a .tf resource block.

```json
{
  "type": "aws_internet_gateway",
  "id": "igw-091b518f859153244",
  "arn": "arn:aws:ec2:us-east-1:285629514281:internet-gateway/igw-091b518f859153244",
  "tags": {
    "Name": "drift-igw"
  },
  "is_default": false,
  "raw_name": "drift-igw",
  "created_at": null
}
```

**Action:** Import this resource into Terraform or create the corresponding `.tf` resource block, then re-run the drift reconciler to track it.
# Unmanaged resource: aws_internet_gateway.drift-igw

Resource exists in AWS but is not tracked in Terraform state and has no ManagedBy tag. It was likely created manually or by another tool. Consider importing it or adding a .tf resource block.

```json
{
  "type": "aws_internet_gateway",
  "id": "igw-0888ea93e6fc76ed8",
  "arn": "arn:aws:ec2:us-east-1:605134452604:internet-gateway/igw-0888ea93e6fc76ed8",
  "tags": {
    "Name": "drift-igw"
  },
  "is_default": false,
  "raw_name": "drift-igw",
  "created_at": null
}
```

**Action:** Import this resource into Terraform or create the corresponding `.tf` resource block, then re-run the drift reconciler to track it.
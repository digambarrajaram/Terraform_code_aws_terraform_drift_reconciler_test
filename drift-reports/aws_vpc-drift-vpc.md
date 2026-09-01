# Unmanaged resource: aws_vpc.drift-vpc

Resource exists in AWS but is not tracked in Terraform state and has no ManagedBy tag. It was likely created manually or by another tool. Consider importing it or adding a .tf resource block.

```json
{
  "type": "aws_vpc",
  "id": "vpc-083ac4f49b47c0335",
  "arn": "arn:aws:ec2:us-east-1:285629514281:vpc/vpc-083ac4f49b47c0335",
  "tags": {
    "Name": "drift-vpc"
  },
  "is_default": false,
  "raw_name": "drift-vpc",
  "created_at": null
}
```

**Action:** Import this resource into Terraform or create the corresponding `.tf` resource block, then re-run the drift reconciler to track it.
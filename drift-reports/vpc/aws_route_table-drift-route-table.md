# Unmanaged resource: aws_route_table.drift-route-table

Resource exists in AWS but is not tracked in Terraform state and has no ManagedBy tag. It was likely created manually or by another tool. Consider importing it or adding a .tf resource block.

```json
{
  "type": "aws_route_table",
  "id": "rtb-08bebac4bd25985eb",
  "arn": "arn:aws:ec2:us-east-1:605134452604:route-table/rtb-08bebac4bd25985eb",
  "tags": {
    "Name": "drift-route-table"
  },
  "is_default": false,
  "raw_name": "drift-route-table",
  "created_at": null
}
```

**Action:** Import this resource into Terraform or create the corresponding `.tf` resource block, then re-run the drift reconciler to track it.
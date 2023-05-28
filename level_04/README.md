---
creation date: 2023-05-25 19:15
modification date: Thursday 25th May 2023 19:15:42
dg-publish: true
title: "Lab 04: Terraform Output"
---

## Terraform output

- What is terraform output 


## Hand on Lab

- Create new file call `outputs.tf`
- Input content bellow:

```hcl
# outputs.tf
output "bucket_name" {
  description = "S3 bucket name."
  value       = aws_s3_bucket.level_4.id
}
output "bucket_arn" {
  description = "S3 bucket ARN."
  value       = aws_s3_bucket.level_4.arn
}
```

- Run plan command: `terraform plan`
- run apply command : `terraform apply -auto-approve -var-fille=s3.tfvars`
- Observe expected result
![lab04-tf-apply-result](../artifacts/lab04-tf-apply-result.png)
> We are what we repeatedly do. Excellence, then, is not an act, but a habit.
> — <cite>Aristotle</cite>

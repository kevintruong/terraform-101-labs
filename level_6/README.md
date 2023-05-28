---
creation date: 2023-05-28 10:53
modification date: Sunday 28th May 2023 10:53:31
dg-publish: false
title: "Lab 06: Module output"
---

## Module output declarative syntax 

```hcl
#outputs.tf 

output "s3_bucket_name" {
  description = "S3 bucket name."
  value       = module.s3.bucket_name
}

output "s3_bucket_arn" {
  description = "S3 bucket ARN."
  value       = module.s3.bucket_arn
}
```

 `value = module.s3.bucket_name`


## Hand on lab

```shell
terraform plan -var-file=s3_module.tfvars
```

![lab06-tf-plan-result](../artifacts/lab06-tf-plan-result.png)

```shell
terraform apply -var-file=s3_module.tfvars -auto-approve
```

![lab06-tf-apply-result](../artifacts/lab06-tf-apply-result.png)


> To fly as fast as thought, you must begin by knowing that you have already arrived.
> — <cite>Richard Bach</cite>

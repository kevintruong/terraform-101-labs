---
creation date: 2023-05-28 09:53
modification date: Sunday 28th May 2023 09:53:25
dg-publish: true
title: Terraform module 
---

## What is terraform module 

## Terraform module pattern ? 

## Hand on lab 

```shell
terraform init 
```

```shell 
terraform plan -var-file=s3_module.tfvars
```

![lab05-tf-plan-result](../artifacts/lab05-tf-plan-result.png)

```shell
terraform apply -var-file=s3_module.tfvars -auto-approve
```

![lab05-tf-apply-result](../../../../artifacts/lab05-tf-apply-result.png)

> The most formidable weapon against errors of every kind is reason.
> — <cite>Thomas Paine</cite>

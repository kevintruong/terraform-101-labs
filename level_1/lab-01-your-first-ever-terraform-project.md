---
dg-publish: true
creation date: 2023-05-21 08:59
modification date:: Sunday 21st May 2023 08:59:04
title: Lab 01 - Your first ever Terraform project
---


## Hand-on Lab : 


![lab1-files-hierachy](../artifacts/lab01/lab1-files-hierachy.png)


```hcl
#provider.hcl 

provider "aws" {  
region = "ap-southeast-1"  
}
```

```hcl
# main.hcl

resource "aws_s3_bucket" "level_1" {  
	# TODO ,add bucket name follow convention
	# <your_name>_tf_l1_devops
	bucket = ""
}  
  
resource "aws_s3_bucket_public_access_block" "level_1" {  
	bucket = aws_s3_bucket.level_1.id  
	block_public_acls = true  
	block_public_policy = true  
	ignore_public_acls = true  
	restrict_public_buckets = true  
}
```

```hcl
# version.hcl 

terraform {
  required_version = ">= 0.14"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}
```

### Getting start

What is provider ?

What is resource ?

### Deploy 

#### Terraform init
```shell 
terraform init
```

![lab1-tf-init](../artifacts/lab01/lab1-tf-init.png)
#### Terraform plan

```shell
terraform plan 
```

![lab01_tf_plan](../artifacts/lab01/lab01_tf_plan.png)


#### Terraform apply

```shell
terraform apply
```

![lab01-tf-apply](../artifacts/lab01/lab01-tf-apply.png)
- Check output resource is created by terraform 

![lab01-resource-after-deploy](../artifacts/lab01/lab01-resource-after-deploy.png)

### Terraform destroy 

```shell
terraform destroy
```

![lab01-tf-destroy](../artifacts/lab01/lab01-tf-destroy.png)



> Let none find fault with others; let none see the omissions and commissions of others. But let one see one's own acts, done and undone.
> — <cite>The Buddha</cite>




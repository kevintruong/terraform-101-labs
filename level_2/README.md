---
creation date: 2023-05-21 09:36
modification date: Sunday 21st May 2023 09:36:25
dg-publish: true
title: Lab 02: Learn About Terraform Variable
---

# LAB 02 : Terraform variables

Introduce concept of variable 

Based on Lab1, customized the lab following guide line:


```hcl
# main.hcl 

resource "aws_s3_bucket" "level_2" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_public_access_block" "level_2" {
  bucket                  = aws_s3_bucket.level_2.id
  block_public_acls       = var.block_public_acls
  block_public_policy     = var.block_public_policy
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets
}

```

```hcl
#file variable variables.hcl

variable "region" {  
	description = "AWS region."  
	type = string  
	default = "ap-southeast-1"  
}  
 
variable "bucket_name" {  
	description = "S3 bucket name."  
	type = string  
	# TODO default follow convention 
	# <your_name>_tf_l2_devops_11
	default = ""
}  
  
variable "block_public_acls" {  
	description = "S3 should block public ACLs for this bucket."  
	type = bool  
	default = true  
}  
variable "block_public_policy" {  
	description = "S3 should block public bucket policies for this bucket."  
	type = bool  
	default = true  
}  
  
variable "ignore_public_acls" {  
	description = "S3 should ignore public ACLs for this bucket."  
	type = bool  
	default = true  
}  
variable "restrict_public_buckets" {  
	description = "S3 should restrict public bucket policies for this bucket."  
	type = bool  
	default = true  
}
```


## Variables 

### variable block syntax 

```hcl 
variable "ignore_public_acls" {  
	description = "S3 should ignore public ACLs for this bucket."  
	type = bool  
	default = true  
}
```

### Variable type



> Whoso loves, believes the impossible.
> — <cite>Elizabeth Browning</cite>

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.25"
    }
  }

  required_version = ">= 1.2.5"
}

provider "aws" {
  region = "ap-southeast-1"
}


module "default_subnet" {
  source = "./module_data_subnet" #get data only
}

module "ec2_with_rds" {
  source            = "./module"
  #  ec2_ami_id        = "ami-04e693a2622dd7913"
  ec2_ami_id        = "ami-0b23bed5722f17060"
  ec2_instance_type = "t2.micro"
}

output "ec2_ssh_cmd" {
  value = module.ec2_with_rds.ssh_ec2_instance
}

output "rds_endpoint" {
  value = module.ec2_with_rds.rds_instance
}

output "rds_db" {
  value = module.default_subnet.default_subnet_id
}


output "port_fwd_rds" {
  value = "ssh -i private_key.pem 5432:${module.default_subnet.rds_db}:5432 ubuntu@${module.ec2_with_rds.ec2_instance_public_ip}"
}
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = "ap-southeast-1"
}
EOF
}

generate "versions" {
  path      = "versions.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  required_providers {
    aws = "4.54.0"
  }
}
EOF
}

remote_state {
  backend = "s3"
  config  = {
    key            = "${path_relative_to_include()}/output/terraform.tfstate"
    encrypt        = true
    bucket         = "aws-training-vutch"
    dynamodb_table = "tf-locks"
    region         = "ap-southeast-1"
  }

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }
}
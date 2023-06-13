variable "dynamodb_tabl" {
  type = map(object({
    stream_enable = bool
    stream_arn    = any
  }))
}

variable "kds_list" {
  type = map(object({
    shard_count      = number
    retention_period = number
    stream_mode      = string
  }))
}

provider "aws" {
  region = "ap-southeast-1"
}

module "aws_data_stream" {
  source   = "../../../../tf_modules/aws_kinesis"
  kds_list = var.kds_list
}

module "aws_dynamodb" {
  source              = "../../../../tf_modules/aws_dynamodb"
  dynamodb_table_list = var.dynamodb_tabl
}
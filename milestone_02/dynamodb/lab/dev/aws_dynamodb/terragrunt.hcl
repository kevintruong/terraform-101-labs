include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../../tf_modules//aws_dynamodb"
}

dependency "kinesis-stream" {
  config_path = "../aws_kinesis_data_stream"
}

inputs = {
  dynamodb_table_list = {
    "StateTable" = {
      stream_enable = true
      stream_arn    = dependency.kinesis-stream.outputs.kds_stream["BackupStream"].arn
    }
  }
}
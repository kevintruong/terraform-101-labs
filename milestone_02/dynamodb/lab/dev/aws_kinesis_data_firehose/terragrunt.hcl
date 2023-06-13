include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../../tf_modules//aws_kinesis_firehose"
}

dependency "kinesis-stream" {
  config_path = "../aws_kinesis_data_stream"
}

inputs = {
  kdf_list = {
    "BackupStream" = {
      kds = dependency.kinesis-stream.outputs.kds_stream["BackupStream"]
    }
  }
}
include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../../tf_modules//aws_kinesis"
}


inputs = {
  kds_list = {
    "IncomingDataStream" = {
      shard_count      = 1
      retention_period = 24
      stream_mode      = "ON_DEMAND"
    },
    "BackupStream" = {
      shard_count      = 1
      retention_period = 24
      stream_mode      = "ON_DEMAND"
    },
  }
}
resource "aws_kinesis_stream" "aws_kds" {
  name             = each.key
  for_each         = {for kds_name, kds_cfg in var.kds_list : kds_name=> kds_cfg}
  #  shard_count      = each.value.shard_count
  retention_period = each.value.retention_period

  stream_mode_details {
    stream_mode = each.value.stream_mode
  }

  tags = {
    Environment = "test"
  }
}

output "kds_stream_arn" {
  value = {
    for k, bd in aws_kinesis_stream.aws_kds : k => bd.arn
  }
}

output "kds_stream" {
  value = {
    for k, bd in aws_kinesis_stream.aws_kds : k => bd
  }
}
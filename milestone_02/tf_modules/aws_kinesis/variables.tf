variable "kds_list" {
  type = map(object({
    shard_count      = number
    retention_period = number
    stream_mode      = string
  }))
}
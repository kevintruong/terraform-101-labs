variable "dynamodb_table_list" {
  type = map(object({
    stream_enable = bool
    stream_arn    = any
  }))
}
variable "lambda_funcs" {
  description = "map between lambda function with its configure "
  type        = map(
    object(
      {
        handle_func   = string
        source_file   = string
        output_path   = string
        event_map     = bool
        event_src_arn = string
      }
    )
  )
}
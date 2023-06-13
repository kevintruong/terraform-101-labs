include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../../tf_modules//aws_lambda"
}

dependency "kinesis-stream" {
  config_path = "../aws_kinesis_data_stream"
}


inputs = {
  lambda_funcs = {
    "source_fake" = {
      handle_func   = "source_fake.lambda_handler"
      source_file   = "${get_repo_root()}/milestone_02/dynamodb/lab/lambda/source_fake/source_fake.py"
      output_path   = "${get_repo_root()}/artifacts/source_fake.zip"
      event_map     = false
      event_src_arn = ""
    },
    "dynamodb_ingest" = {
      handle_func   = "dynamodb_ingest.lambda_handler"
      source_file   = "${get_repo_root()}/milestone_02/dynamodb/lab/lambda/dynamodb_ingest/dynamodb_ingest.py"
      output_path   = "${get_repo_root()}/artifacts/dynamodb_ingest.zip"
      event_map     = true
      event_src_arn = dependency.kinesis-stream.outputs.kds_stream_arn["IncomingDataStream"]
    },
    "kdf_transform" = {
      handle_func   = "kdf_transform.lambda_handler"
      source_file   = "${get_repo_root()}/milestone_02/dynamodb/lab/lambda/kdf_transform/kdf_transform.py"
      output_path   = "${get_repo_root()}/artifacts/kdf_transform.zip"
      event_map     = false
      event_src_arn = "abc"
    }
  }
}
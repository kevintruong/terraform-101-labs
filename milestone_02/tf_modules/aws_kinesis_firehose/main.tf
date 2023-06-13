resource "aws_cloudwatch_log_group" "yada" {
  name              = "kinesis_firehose_loggroup"
  retention_in_days = 1

  tags = {
    Environment = "production"
    Application = "serviceA"
  }
}

resource "aws_cloudwatch_log_stream" "foo" {
  for_each       = {for kds_name, kds_cfg in var.kdf_list : kds_name=> kds_cfg}
  name           = format("%s-%s", each.key, "logstream")
  log_group_name = aws_cloudwatch_log_group.yada.name
}


resource "aws_kinesis_firehose_delivery_stream" "extended_s3_stream" {
  for_each = {for kds_name, kds_cfg in var.kdf_list : kds_name=> kds_cfg}

  name        = each.key
  destination = "extended_s3"

  kinesis_source_configuration {
    kinesis_stream_arn = each.value.kds.arn
    role_arn           = aws_iam_role.firehose_role.arn
  }

  extended_s3_configuration {
    //The ARN of the AWS credentials.
    role_arn = aws_iam_role.firehose_role.arn

    //The ARN of the S3 bucket
    bucket_arn = aws_s3_bucket.bucket.arn

    //Buffer incoming data to the specified size, in MBs, before delivering it to the destination.
    buffer_size = 1

    //Buffer incoming data for the specified period of time, in seconds, before delivering it to the destination.
    buffer_interval = 60

    cloudwatch_logging_options {
      enabled         = true
      log_group_name  = aws_cloudwatch_log_group.yada.name
      log_stream_name = aws_cloudwatch_log_stream.foo[each.key].name
    }
  }

}

resource "aws_s3_bucket" "bucket" {
  bucket = "vutch-tf-test-bucket"
}

resource "aws_s3_bucket_acl" "bucket_acl" {
  bucket = aws_s3_bucket.bucket.id
  acl    = "private"
}

data "aws_iam_policy_document" "firehose_assume_role" {

  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["firehose.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}


resource "aws_iam_policy" "kinesis_access_policy" {
  name = "kinesis_access_policy"

  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Action   = ["kinesis:*"]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:PutLogEventsBatch"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "s3:*",
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}


resource "aws_iam_role" "firehose_role" {
  name                = "firehose_test_role"
  assume_role_policy  = data.aws_iam_policy_document.firehose_assume_role.json
  managed_policy_arns = [
    aws_iam_policy.kinesis_access_policy.arn
  ]
}

data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}
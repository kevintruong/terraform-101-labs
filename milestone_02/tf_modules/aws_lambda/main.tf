resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}


resource "aws_iam_policy" "iam_policy_for_lambda" {

  name        = "aws_iam_policy_for_terraform_aws_lambda_role"
  path        = "/"
  description = "AWS IAM Policy for managing aws lambda role"
  policy      = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": [
       "logs:CreateLogGroup",
       "logs:CreateLogStream",
       "logs:PutLogEvents"
     ],
     "Resource": "arn:aws:logs:*:*:*",
     "Effect": "Allow"
   },
   {
     "Action": [
       "kinesis:*"
     ],
     "Resource": "*",
     "Effect": "Allow"
   },
   {
     "Action": [
       "dynamodb:*"
     ],
     "Resource": "*",
     "Effect": "Allow"
   }
 ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "attach_iam_policy_to_iam_role" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.iam_policy_for_lambda.arn
}

data "archive_file" "lambda_func_src" {
  for_each = {
    for key, value in var.lambda_funcs :
    key => value
  }
  source_file      = each.value.source_file
  output_file_mode = ""
  output_path      = each.value.output_path
  type             = "zip"
}


resource "aws_lambda_function" "lambda_func" {
  for_each = {for func_name, func_cfg in var.lambda_funcs : func_name=> func_cfg}

  function_name    = each.key
  role             = aws_iam_role.iam_for_lambda.arn
  handler          = each.value.handle_func
  runtime          = "python3.8"
  filename         = data.archive_file.lambda_func_src[each.key].output_path
  source_code_hash = data.archive_file.lambda_func_src[each.key].output_base64sha256
}
resource "aws_lambda_event_source_mapping" "lambda_evt_src_mapping" {
  for_each          = {for func_name, func_cfg in var.lambda_funcs : func_name=> func_cfg if func_cfg.event_map}
  function_name     = aws_lambda_function.lambda_func[each.key].arn
  event_source_arn  = each.value.event_src_arn
  starting_position = "LATEST"
}

output "lambda_func" {
  value = [for each in aws_lambda_function.lambda_func : each.handler]
}

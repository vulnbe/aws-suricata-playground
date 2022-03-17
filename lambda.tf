resource "aws_lambda_function" "mirror_lambda" {
  filename         = data.archive_file.mirror_lambda.output_path
  function_name    = var.lambda_name
  role             = aws_iam_role.mirror_lambda.arn
  handler          = "lambda_function.lambda_handler"
  source_code_hash = filebase64sha256("${data.archive_file.mirror_lambda.output_path}")
  runtime          = "python3.9"

  environment {
    variables = {
      LAMBDA_LOG_LEVEL = "INFO"
      MIRROR_FILTER_ID = "${aws_ec2_traffic_mirror_filter.all_non_local.id}"
      MIRROR_SKIP_TAGS = "application=suricata"
      MIRROR_TARGET_ID = "${aws_ec2_traffic_mirror_target.suricata_nlb.id}"
    }
  }
  depends_on = [
    aws_iam_role_policy_attachment.mirror_lambda_logs,
    aws_iam_role_policy_attachment.mirror_lambda_actions,
    aws_cloudwatch_log_group.mirror_lambda,
  ]
}

resource "aws_cloudwatch_event_target" "mirror_lambda" {
  target_id = var.lambda_name
  rule      = aws_cloudwatch_event_rule.ec2_startup.name
  arn       = aws_lambda_function.mirror_lambda.arn
}

resource "aws_lambda_permission" "mirror_lambda_from_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.mirror_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.ec2_startup.arn
}

resource "aws_cloudwatch_event_rule" "ec2_startup" {
  name        = "CaptureEC2StartupEvents"
  description = "Capture all EC2 startup events"

  event_pattern = <<PATTERN
{
  "source": ["aws.ec2"],
  "detail-type": ["EC2 Instance State-change Notification"],
  "detail": {
    "state": ["running"]
  }
}
PATTERN
}

resource "aws_cloudwatch_log_group" "mirror_lambda" {
  name              = "/aws/lambda/${var.lambda_name}"
  retention_in_days = 14
}

data "archive_file" "mirror_lambda" {
  type        = "zip"
  output_path = "${path.module}/files/mirror_lambda.zip"
  source {
    content  = data.http.lambda.body
    filename = "lambda_function.py"
  }
}

data "http" "lambda" {
  url = var.lambda_url
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

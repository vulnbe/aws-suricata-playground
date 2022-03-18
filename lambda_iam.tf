resource "aws_iam_role" "mirror_lambda" {
  name               = "${var.lambda_name}Role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "mirror_lambda_logs" {
  role       = aws_iam_role.mirror_lambda.name
  policy_arn = aws_iam_policy.mirror_lambda_logs.arn
}

resource "aws_iam_policy" "mirror_lambda_logs" {
  name   = "${var.lambda_name}LogPolicy"
  policy = data.aws_iam_policy_document.mirror_lambda_logs.json
  tags   = var.tags
}

resource "aws_iam_role_policy_attachment" "mirror_lambda_actions" {
  role       = aws_iam_role.mirror_lambda.name
  policy_arn = aws_iam_policy.mirror_lambda_actions.arn
}

resource "aws_iam_policy" "mirror_lambda_actions" {
  name   = "${var.lambda_name}ActionsPolicy"
  policy = data.aws_iam_policy_document.mirror_lambda_actions.json
  tags   = var.tags
}

data "aws_iam_policy_document" "lambda_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "mirror_lambda_actions" {
  statement {
    actions   = ["ec2:CreateTrafficMirrorSession", "ec2:DescribeTrafficMirrorSessions", "ec2:DescribeInstances"]
    effect    = "Allow"
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "mirror_lambda_logs" {
  statement {
    actions = ["logs:CreateLogGroup"]
    effect  = "Allow"
    resources = [
    "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"]
  }
  statement {
    actions = ["logs:CreateLogStream", "logs:PutLogEvents"]
    effect  = "Allow"
    resources = [
    "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${var.lambda_name}:*"]
  }
}


# EC2 Power Up
data "archive_file" "ec2_powerup" {
  type        = "zip"
  source_file = "${path.module}/ec2_powerup.py"
  output_path = "ec2_powerup.zip"
}

resource "aws_lambda_function" "ec2_powerup" {
  description      = "Scan EC2 resources and turn on based on tagged schedule"
  filename         = data.archive_file.ec2_powerup.output_path
  function_name    = "ec2_powerup"
  role             = aws_iam_role.this.arn
  handler          = "ec2_powerup.lambda_handler"
  source_code_hash = filebase64sha256(data.archive_file.ec2_powerup.output_path)
  runtime          = "python2.7"
  timeout          = 300

  depends_on = [data.archive_file.ec2_powerup]
}

resource "aws_lambda_permission" "ec2_powerup" {
  statement_id  = "Ec2PowerUpAllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ec2_powerup.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.this.arn
}

# EC2 Power Down
data "archive_file" "ec2_powerdown" {
  type        = "zip"
  source_file = "${path.module}/ec2_powerdown.py"
  output_path = "ec2_powerdown.zip"
}

resource "aws_lambda_function" "ec2_powerdown" {
  description      = "Scan EC2 resources and turn on based on tagged schedule"
  filename         = data.archive_file.ec2_powerdown.output_path
  function_name    = "ec2_powerdown"
  role             = aws_iam_role.this.arn
  handler          = "ec2_powerdown.lambda_handler"
  source_code_hash = filebase64sha256(data.archive_file.ec2_powerdown.output_path)
  runtime          = "python2.7"
  timeout          = 300

  depends_on = [data.archive_file.ec2_powerdown]
}

resource "aws_lambda_permission" "ec2_powerdown" {
  statement_id  = "Ec2PowerDownAllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ec2_powerdown.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.this.arn
}

# RDS Power Up
data "archive_file" "rds_powerup" {
  type        = "zip"
  source_file = "${path.module}/rds_powerup.py"
  output_path = "rds_powerup.zip"
}
resource "aws_lambda_function" "rds_powerup" {
  depends_on       = [data.archive_file.rds_powerup]
  description      = "Scan RDS resources and turn on based on tagged schedule"
  filename         = data.archive_file.rds_powerup.output_path
  function_name    = "rds_powerup"
  role             = aws_iam_role.this.arn
  handler          = "rds_powerup.lambda_handler"
  source_code_hash = filebase64sha256(data.archive_file.rds_powerup.output_path)
  runtime          = "python2.7"
  timeout          = 300
}
resource "aws_lambda_permission" "rds_powerup" {
  statement_id  = "Rds2PowerUpAllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.rds_powerup.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.fivemin.arn
}

# Common Resources

# IAM Permissions for lambda function
resource "aws_iam_role" "this" {
  description        = "Scheduler Lambda Function Role"
  assume_role_policy = file("${path.module}/assume-role-policy.json")
}
resource "aws_iam_role_policy" "this" {
  role   = aws_iam_role.this.name
  policy = file("${path.module}/policy.json")
}

# Trigger every 1 hour
resource "aws_cloudwatch_event_rule" "this" {
  name                = "scheduler-trigger"
  description         = "Trigger scheduler lambdas every hour"
  schedule_expression = "rate(1 hour)"
}

# RDS Powerdown
data "archive_file" "rds_powerdown" {
  type        = "zip"
  source_file = "${path.module}/rds_powerdown.py"
  output_path = "rds_powerdown.zip"
}
resource "aws_lambda_function" "rds_powerdown" {
  depends_on       = [data.archive_file.rds_powerdown]
  description      = "Scan rds resources and turn down based on tagged schedule"
  filename         = data.archive_file.rds_powerdown.output_path
  function_name    = "rds_powerdown"
  role             = aws_iam_role.this.arn
  handler          = "rds_powerdown.lambda_handler"
  source_code_hash = filebase64sha256(data.archive_file.rds_powerdown.output_path)
  runtime          = "python2.7"
  timeout          = 500
}

resource "aws_lambda_permission" "rds_powerdown" {
  statement_id  = "Rds2PowerDownAllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.rds_powerdown.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.twentymin.arn
}

# RDS MultiAZ to SingleAZ
data "archive_file" "rds_multi_to_single_az" {
  type        = "zip"
  source_file = "${path.module}/rds_multi_to_single_az.py"
  output_path = "rds_multi_to_single_az.zip"
}
resource "aws_lambda_function" "rds_multi_to_single_az" {
  depends_on       = [data.archive_file.rds_multi_to_single_az]
  description      = "Scan rds resources and switch from MultiAZ to Single if powerdown tag available"
  filename         = data.archive_file.rds_multi_to_single_az.output_path
  function_name    = "rds_multi_to_single_az"
  role             = aws_iam_role.this.arn
  handler          = "rds_multi_to_single_az.lambda_handler"
  source_code_hash = filebase64sha256(data.archive_file.rds_multi_to_single_az.output_path)
  runtime          = "python2.7"
  timeout          = 300
}

resource "aws_lambda_permission" "rds_multi_to_single_az" {
  statement_id  = "RdsMultiAZ2SingleAZAllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.rds_multi_to_single_az.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.fivemin.arn
}

# RDS SingleAZ to MultiAZ 
data "archive_file" "rds_single_to_multi_az" {
  type        = "zip"
  source_file = "${path.module}/rds_single_to_multi_az.py"
  output_path = "rds_single_to_multi_az.zip"
}
resource "aws_lambda_function" "rds_single_to_multi_az" {
  depends_on       = [data.archive_file.rds_single_to_multi_az]
  description      = "Scan rds resources and switch from Single to MultiAZ if powerup tag available "
  filename         = data.archive_file.rds_single_to_multi_az.output_path
  function_name    = "rds_single_to_multi_az"
  role             = aws_iam_role.this.arn
  handler          = "rds_single_to_multi_az.lambda_handler"
  source_code_hash = filebase64sha256(data.archive_file.rds_single_to_multi_az.output_path)
  runtime          = "python2.7"
  timeout          = 300
}

resource "aws_lambda_permission" "rds_single_to_multi_az" {
  statement_id  = "RdsSingleAZ2MultiAZAllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.rds_single_to_multi_az.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.fivemin.arn
}

# Trigger every 5 minutes
resource "aws_cloudwatch_event_rule" "fivemin" {
  name                = "5min-scheduler-trigger"
  description         = "Trigger scheduler lambdas every 5 minutes"
  schedule_expression = "rate(5 minutes)"
}
resource "aws_cloudwatch_event_rule" "twentymin" {
  name                = "20min-scheduler-trigger"
  description         = "Trigger scheduler lambdas every 20 minutes"
  schedule_expression = "rate(20 minutes)"
}
resource "aws_cloudwatch_event_target" "rds_powerdown" {
  rule      = aws_cloudwatch_event_rule.twentymin.name
  target_id = "rds_powerdown"
  arn       = aws_lambda_function.rds_powerdown.arn
}
resource "aws_cloudwatch_event_target" "rds_multi_to_single_az" {
  count     = var.enable_az_switch ? 1 : 0
  rule      = aws_cloudwatch_event_rule.fivemin.name
  target_id = "rds_multi_to_single_az"
  arn       = aws_lambda_function.rds_multi_to_single_az.arn
}
resource "aws_cloudwatch_event_target" "rds_single_to_multi_az" {
  count     = var.enable_az_switch ? 1 : 0
  rule      = aws_cloudwatch_event_rule.fivemin.name
  target_id = "rds_single_to_multi_az"
  arn       = aws_lambda_function.rds_single_to_multi_az.arn
}
resource "aws_cloudwatch_event_target" "rds_powerup" {
  rule      = aws_cloudwatch_event_rule.fivemin.name
  target_id = "rds_powerup"
  arn       = aws_lambda_function.rds_powerup.arn
}


##########################################################################
# Cloudwatch log group - Log stream - Flow logs for VPCs
##########################################################################

resource "aws_cloudwatch_log_group" "cw-log-group" {
  name = "cw-log-group"
}

resource "aws_cloudwatch_log_stream" "primary-vpc-logstream" {
  name           = "primary-vpc-logstream"
  log_group_name = aws_cloudwatch_log_group.cw-log-group.name
}

resource "aws_cloudwatch_log_stream" "secondary-vpc-logstream" {
  name           = "secondary-vpc-logstream"
  log_group_name = aws_cloudwatch_log_group.cw-log-group.name
}

resource "aws_flow_log" "primary-vpc-flowlog" {
  iam_role_arn    = aws_iam_role.cw-iam-role.arn
  log_destination = aws_cloudwatch_log_group.cw-log-group.arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.primary-vpc.id
}

resource "aws_flow_log" "secondary-vpc-flowlog" {
  iam_role_arn    = aws_iam_role.cw-iam-role.arn
  log_destination = aws_cloudwatch_log_group.cw-log-group.arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.secondary-vpc.id
}
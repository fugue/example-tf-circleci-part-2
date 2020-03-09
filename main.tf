provider "aws" {
  region = "us-west-1"
}

resource "aws_vpc" "my_fugue_cicd_vpc" {
  cidr_block = "10.0.0.0/16"
  
  tags = {
    Name = "my-fugue-cicd-vpc"
  }
}

resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.my_fugue_cicd_vpc.id

  # ingress {
  #   from_port   = 0
  #   to_port     = 0
  #   protocol    = "-1"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }
}

# resource "aws_flow_log" "valid_vpc_flow_log" {
#   iam_role_arn    = aws_iam_role.example.arn
#   log_destination = aws_cloudwatch_log_group.example.arn
#   traffic_type    = "ALL"
#   vpc_id          = aws_vpc.my_fugue_cicd_vpc.id
# }
# 
# resource "aws_cloudwatch_log_group" "example" {
#   name = "example-log-group"
# }
# 
# resource "aws_iam_role" "example" {
#   name = "example-role"
# 
#   assume_role_policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Sid": "",
#       "Effect": "Allow",
#       "Principal": {
#         "Service": "vpc-flow-logs.amazonaws.com"
#       },
#       "Action": "sts:AssumeRole"
#     }
#   ]
# }
# EOF
# }
# 
# resource "aws_iam_role_policy" "example" {
#   name = "example-role-policy"
#   role = aws_iam_role.example.id
# 
#   policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Action": [
#         "logs:CreateLogGroup",
#         "logs:CreateLogStream",
#         "logs:PutLogEvents",
#         "logs:DescribeLogGroups",
#         "logs:DescribeLogStreams"
#       ],
#       "Effect": "Allow",
#       "Resource": "*"
#     }
#   ]
# }
# EOF
# }
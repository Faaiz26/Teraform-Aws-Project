# vpc

resource "aws_vpc" "lambda_vpc" {
    cidr_block = "10.0.0.0/16"
}

#subnet

resource "aws_subnet" "lambda_subnet" {
    vpc_id = aws_vpc.lambda_vpc.id
    cidr_block = "10.0.1.0/24" 
    availability_zone = "ap-south-1a" 
}

#SG group

resource "aws_security_group" "lambda_sg" {
    vpc_id = aws_vpc.lambda_vpc.id
    name = "lambda_sg"
 
}

resource "aws_vpc_security_group_ingress_rule" "all_traffic" {
    security_group_id = aws_security_group.lambda_sg.id
    ip_protocol = "-1"
    cidr_ipv4 = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "all_traffic_engress" {
    security_group_id = aws_security_group.lambda_sg.id
    ip_protocol = "-1"
    cidr_ipv4 = "0.0.0.0/0"
}

resource "aws_iam_role" "lambda_role" {
    name = "lambda_execution_role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17",
        Statement = [{
            Action = "sts:AssumeRole",
            Effect = "Allow",
            Principal = {
                Service = "lambda.amazonaws.com"
            },
        }],

    })
  
}

resource "aws_iam_policy" "lambda_policy" {
    name = "lambda_policy"
    policy = jsonencode({
        Version = "2012-10-17",
        Statement = [{
            Action = [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents",
            ],
            Effect = "Allow",
            Resource = "arn:aws:logs:*:*:*",
        }],
    })
  
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
    role = aws_iam_role.lambda_role.name
    policy_arn = aws_iam_policy.lambda_policy.arn
  
}


resource "aws_lambda_function" "py_lambda" {
  function_name = "python-lambda-function"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.12"
  role          = aws_iam_role.lambda_role.arn
  filename      = "${path.module}/lambda_function.zip"  # safer path
  source_code_hash = filebase64sha256("${path.module}/lambda_function.zip")
}

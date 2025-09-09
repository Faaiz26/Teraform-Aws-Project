resource "aws_vpc" "custom_vpc" {
  cidr_block = var.cidr
}

resource "aws_subnet" "sub1" {
  vpc_id                  = aws_vpc.custom_vpc.id
  cidr_block              = var.cidr_subnet
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "sub2" {
  vpc_id                  = aws_vpc.custom_vpc.id
  cidr_block              = var.cidr_subnet_2
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = true

}

resource "aws_internet_gateway" "mumbai_gw" {
  vpc_id = aws_vpc.custom_vpc.id
}

resource "aws_route_table" "route_mumbai" {
  vpc_id = aws_vpc.custom_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.mumbai_gw.id
  }

}

resource "aws_route_table_association" "sub1_a" {
  subnet_id      = aws_subnet.sub1.id
  route_table_id = aws_route_table.route_mumbai.id
}

resource "aws_route_table_association" "sub2_b" {
  subnet_id      = aws_subnet.sub2.id
  route_table_id = aws_route_table.route_mumbai.id
}

resource "aws_security_group" "mumbai_sg" {
  name        = "mumbai_sg"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.custom_vpc.id

  tags = {
    Name = "mumbai-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "mumbai_ingress_http" {
  security_group_id = aws_security_group.mumbai_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
  description       = "HTTP from VPC"

}

resource "aws_vpc_security_group_ingress_rule" "mumbai_ingress_ssh" {
  security_group_id = aws_security_group.mumbai_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
  description       = "SSH from VPC"
}

resource "aws_vpc_security_group_egress_rule" "mumbai_egress_http" {
  security_group_id = aws_security_group.mumbai_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"

}

resource "aws_s3_bucket" "mumbai_bucket" {
  bucket = "mumbai-bucket-20251"
}

resource "aws_s3_bucket_ownership_controls" "mumbai_bucket" {
  bucket = aws_s3_bucket.mumbai_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "mumbai_bucket" {
  bucket = aws_s3_bucket.mumbai_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "example" {
  depends_on = [
    aws_s3_bucket_ownership_controls.mumbai_bucket,
    aws_s3_bucket_public_access_block.mumbai_bucket,
  ]

  bucket = aws_s3_bucket.mumbai_bucket.id
  acl    = "public-read"
}

resource "aws_instance" "mumbai_server_1" {
  ami                    = var.ami_image
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.mumbai_sg.id]
  subnet_id              = aws_subnet.sub1.id
  user_data              = base64encode(file("userdata.sh"))

}

resource "aws_instance" "mumbai_server_2" {
  ami                    = var.ami_image
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.mumbai_sg.id]
  subnet_id              = aws_subnet.sub2.id
  user_data              = base64encode(file("userdata1.sh"))

}

resource "aws_lb" "mumbailb" {
  name               = "mumbaiLb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.mumbai_sg.id]
  subnets            = [aws_subnet.sub1.id, aws_subnet.sub2.id]
}

resource "aws_lb_target_group" "mumbai_tg" {
  name     = "mumbaiTg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.custom_vpc.id
  health_check {
    path = "/"
    port = "traffic-port"

  }

}

resource "aws_lb_target_group_attachment" "mumbai_attach1" {
  target_group_arn = aws_lb_target_group.mumbai_tg.arn
  target_id        = aws_instance.mumbai_server_1.id
  port             = 80

}

resource "aws_lb_target_group_attachment" "mumbai_attach2" {
  target_group_arn = aws_lb_target_group.mumbai_tg.arn
  target_id        = aws_instance.mumbai_server_2.id
  port             = 80

}

resource "aws_lb_listener" "mumbai_listner" {
  load_balancer_arn = aws_lb.mumbailb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.mumbai_tg.arn
    type             = "forward"
  }

}

output "loadbalancedns" {
  value = aws_lb.mumbailb.dns_name

}
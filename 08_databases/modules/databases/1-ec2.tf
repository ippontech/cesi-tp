data "aws_ami" "amazon_linux_2_ami" {
  most_recent = true
  name_regex  = "^amzn2-ami-hvm-[\\d.]+-x86_64-gp2$"
  owners      = ["amazon"]
}

data "aws_iam_instance_profile" "ssm_instance_profile" {
  name = "LabInstanceProfile"
}

resource "aws_security_group" "aws_security_group" {
  vpc_id      = var.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "aws_ingress_rule" {
  security_group_id = aws_security_group.aws_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "example" {
  security_group_id = aws_security_group.aws_security_group.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}



# TODO STEP 7: Choose a subnet for your instance, add a Security Group to it and complete the user data to pass the right variables to it.
# TODO STEP 7: Check out 'cloud_init.sh.tpl' file to know which variables you need.
resource "aws_instance" "http_server" {
  ami                  = data.aws_ami.amazon_linux_2_ami.id
  instance_type        = "t3.small"
  iam_instance_profile = data.aws_iam_instance_profile.ssm_instance_profile.name
  vpc_security_group_ids = [aws_security_group.aws_security_group.id]
  subnet_id = var.public_subnet_a_id
  user_data = templatefile("${path.module}/cloud_init.sh.tpl", {
    rds_endpoint = aws_db_instance.main.endpoint,
    database_name = aws_db_instance.main.db_name,
    database_username=aws_db_instance.main.username,
    database_password=aws_db_instance.main.password
  })

  tags = {
    Name = "${var.project}-http-server"
  }
}

resource "random_password" "password" {
  length    = 10
  special   = false
  min_lower = 10
}

resource "aws_db_subnet_group" "aws_main" {
  name       = "main"
  subnet_ids = [var.subnet_a_id, var.subnet_b_id]

  tags = {
    Name = "My DB subnet group"
  }
}

resource "aws_security_group" "security_group" {
  name        = "security_group"
  description = "security_group"
  vpc_id      = var.vpc_id

  tags = {
    Name = "security_group"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ingress_rule" {
  security_group_id = aws_security_group.security_group.id

  cidr_ipv4   = "10.0.0.0/16"
  from_port   = 5432
  ip_protocol = "tcp"
  to_port     = 5432
}

resource "aws_db_instance" "main" {
  allocated_storage    = 10
  db_name              = "main"
  engine               = "postgres"
  engine_version       = "16.3"
  instance_class       = "db.t3.small"
  username             = "main"
  password             = "mainmain"
  
  db_subnet_group_name = aws_db_subnet_group.aws_main.name
  vpc_security_group_ids = [aws_security_group.security_group.id]
}

resource "aws_vpc" "VPC" {
  cidr_block = var.cidr
}

resource "aws_subnet" "SUBNET1" {
  vpc_id                  = aws_vpc.VPC.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "SUBNET2" {
  vpc_id                  = aws_vpc.VPC.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "IGW" {
  vpc_id = aws_vpc.VPC.id
}

resource "aws_route_table" "RT" {
  vpc_id = aws_vpc.VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW.id
  }
}

resource "aws_route_table_association" "RTA1" {
  subnet_id      = aws_subnet.SUBNET1.id
  route_table_id = aws_route_table.RT.id
}

resource "aws_route_table_association" "RTA2" {
  subnet_id      = aws_subnet.SUBNET2.id
  route_table_id = aws_route_table.RT.id
}

resource "aws_security_group" "SG" {
  name   = "SG"
  vpc_id = aws_vpc.VPC.id
}

resource "aws_vpc_security_group_ingress_rule" "ISG" {
  security_group_id = aws_security_group.SG.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "ISG1" {
  security_group_id = aws_security_group.SG.id
  cidr_ipv4         = aws_vpc.VPC.cidr_block
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "ESG" {
  security_group_id = aws_security_group.SG.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_instance" "Server1" {
  ami                    = "ami-0e86e20dae9224db8"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.SG.id]
  subnet_id              = aws_subnet.SUBNET1.id
  user_data              = base64encode(file("userdata.sh"))
}

resource "aws_instance" "Server2" {
  ami                    = "ami-0e86e20dae9224db8"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.SG.id]
  subnet_id              = aws_subnet.SUBNET2.id
  user_data              = base64encode(file("userdata1.sh"))
}

resource "aws_lb" "App-LB" {
  name               = "App-LB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.SG.id]
  subnets            = [aws_subnet.SUBNET1.id, aws_subnet.SUBNET2.id]
}

resource "aws_lb_target_group" "TG" {
  name     = "TG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.VPC.id

  health_check {
    path = "/"
    port = "traffic-port"
  }
}

resource "aws_lb_target_group_attachment" "Attachment1" {
  target_group_arn = aws_lb_target_group.TG.arn
  target_id        = aws_instance.Server1.id
}

resource "aws_lb_target_group_attachment" "Attachment2" {
  target_group_arn = aws_lb_target_group.TG.arn
  target_id        = aws_instance.Server2.id
}

resource "aws_lb_listener" "Listner" {
  load_balancer_arn = aws_lb.App-LB.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.TG.arn
  }
}

resource "aws_db_subnet_group" "db-subnet-group" {
  name = "db-subnet-group"
  subnet_ids = [ aws_subnet.SUBNET1.id, aws_subnet.SUBNET2.id ]
}

resource "aws_db_instance" "DB-Instance" {
  identifier = "mydbinstance"
  engine = "mysql"
  instance_class = "db.t3.micro"
  engine_version = "8.0"
  username = "admin"
  password = "test#123"
  allocated_storage = 20
  storage_type = "gp2"
  db_name = "MyDatabase"
  parameter_group_name = "default.mysql8.0"
  backup_retention_period = 7
  multi_az = false 
  publicly_accessible = false
  vpc_security_group_ids = [ aws_security_group.SG.id ]
  db_subnet_group_name = aws_db_subnet_group.db-subnet-group.id
  skip_final_snapshot = true 
}

resource "aws_security_group_rule" "db_ingress" {
  type = "ingress"
  from_port = 3306
  to_port = 3306
  protocol = "tcp"
  security_group_id = aws_security_group.SG.id
  cidr_blocks = [ aws_vpc.VPC.cidr_block ]
}

output "AppLB-DNSname" {
  value = aws_lb.App-LB.dns_name
}

output "Endpoint-of-RDS" {
  value = aws_db_instance.DB-Instance.endpoint
}
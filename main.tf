provider "aws" {
  region     = "ap-south-1"
  access_key = ""
  secret_key = ""
}


resource "aws_vpc" "vpc_demo" {
  cidr_block       = "192.168.5.0/24"
  instance_tenancy = "default"
  tags = {
    Name = "vpc_demo"
  }
}


resource "aws_subnet" "subnet_1_public" {
  vpc_id                  = aws_vpc.vpc_demo.id
  cidr_block              = "192.168.5.0/28"
  map_public_ip_on_launch = true
  availability_zone       = "ap-south-1a"
  tags = {
    Name = "subnet-1-public"
  }
}

resource "aws_subnet" "subnet_2_public" {
  vpc_id                  = aws_vpc.vpc_demo.id
  cidr_block              = "192.168.5.16/28"
  map_public_ip_on_launch = true
  availability_zone       = "ap-south-1b"
  tags = {
    Name = "subnet-2-public"
  }
}

resource "aws_subnet" "subnet_3_private" {
  vpc_id                  = aws_vpc.vpc_demo.id
  cidr_block              = "192.168.5.32/28"
  map_public_ip_on_launch = false
  availability_zone       = "ap-south-1a"
  tags = {
    Name = "subnet-3-private"
  }
}

resource "aws_subnet" "subnet_4_private" {
  vpc_id                  = aws_vpc.vpc_demo.id
  cidr_block              = "192.168.5.48/28"
  map_public_ip_on_launch = false
  availability_zone       = "ap-south-1b"
  tags = {
    Name = "subnet-4-private"
  }
}

resource "aws_subnet" "subnet_5_private" {
  vpc_id                  = aws_vpc.vpc_demo.id
  cidr_block              = "192.168.5.64/28"
  map_public_ip_on_launch = false
  availability_zone       = "ap-south-1a"
  tags = {
    Name = "subnet-5-private"
  }
}

resource "aws_subnet" "subnet_6_private" {
  vpc_id                  = aws_vpc.vpc_demo.id
  cidr_block              = "192.168.5.80/28"
  map_public_ip_on_launch = false
  availability_zone       = "ap-south-1b"
  tags = {
    Name = "subnet-6-private"
  }
}

# Define Internet Gateway
resource "aws_internet_gateway" "igw_1" {
  vpc_id = aws_vpc.vpc_demo.id
  tags = {
    Name = "igw-1"
  }
}

# Define Route Table
resource "aws_route_table" "rt_1" {
  vpc_id = aws_vpc.vpc_demo.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_1.id
  }

  tags = {
    Name = "rt-1"
  }
}

# Associate Subnets with Route Table
resource "aws_route_table_association" "association_1" {
  subnet_id      = aws_subnet.subnet_1_public.id
  route_table_id = aws_route_table.rt_1.id
}

resource "aws_route_table_association" "association_2" {
  subnet_id      = aws_subnet.subnet_2_public.id
  route_table_id = aws_route_table.rt_1.id
}

resource "aws_route_table_association" "association_3" {
  subnet_id      = aws_subnet.subnet_3_private.id
  route_table_id = aws_route_table.rt_2_subnet_5.id
}

resource "aws_route_table_association" "association_4" {
  subnet_id      = aws_subnet.subnet_4_private.id
  route_table_id = aws_route_table.rt_2_subnet_5.id
}

# Fetch AMI
data "aws_ami" "ami" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023.4.20240513.0-kernel-6.1-x86_64"]
  }
}

data "aws_key_pair" "key_pair" {
  key_name = "Mumbai-key"
}


# Define Security Group for Instances
resource "aws_security_group" "sg_1" {
  vpc_id = aws_vpc.vpc_demo.id

  # Inbound Rules
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "sg_1"
  }
}

resource "aws_security_group" "database_sg" {
  name   = "Database SG"
  vpc_id = aws_vpc.vpc_demo.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_1.id]
  }

  egress {
    from_port   = 32768
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Database SG"
  }
}

resource "aws_instance" "demo_1" {
  ami                         = data.aws_ami.ami.id
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.subnet_1_public.id
  key_name                    = "Mumbai-key"
  vpc_security_group_ids      = [aws_security_group.sg_1.id]
  availability_zone           = "ap-south-1a"
  associate_public_ip_address = true

  tags = {
    Name = "demo-1"
  }
}

resource "aws_instance" "demo_2" {
  ami                         = data.aws_ami.ami.id
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.subnet_2_public.id
  key_name                    = "Mumbai-key"
  vpc_security_group_ids      = [aws_security_group.sg_1.id]
  availability_zone           = "ap-south-1b"
  associate_public_ip_address = true

  tags = {
    Name = "demo-2"
  }
}

resource "aws_instance" "demo_3" {
  ami                         = data.aws_ami.ami.id
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.subnet_3_private.id
  key_name                    = "Mumbai-key"
  vpc_security_group_ids      = [aws_security_group.sg_1.id]
  availability_zone           = "ap-south-1a"
  associate_public_ip_address = false

  tags = {
    Name = "demo-3"
  }
}

resource "aws_instance" "demo_4" {
  ami                         = data.aws_ami.ami.id
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.subnet_4_private.id
  key_name                    = "Mumbai-key"
  vpc_security_group_ids      = [aws_security_group.sg_1.id]
  availability_zone           = "ap-south-1b"
  associate_public_ip_address = false

  tags = {
    Name = "demo-4"
  }
}

resource "aws_eip" "elastic_ip" {
  domain = "vpc"
  tags = {
    Name = "demo-eip"
  }
}

resource "aws_nat_gateway" "test_nat" {
  allocation_id = aws_eip.elastic_ip.id
  subnet_id     = aws_subnet.subnet_1_public.id
  tags = {
    Name = "demo-nat"
  }
}

resource "aws_route_table" "rt_2_subnet_5" {
  vpc_id = aws_vpc.vpc_demo.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.test_nat.id
  }

  tags = {
    Name = "rt-2-subnet-5"
  }
}

resource "aws_route_table_association" "association_7" {
  subnet_id      = aws_subnet.subnet_5_private.id
  route_table_id = aws_route_table.rt_2_subnet_5.id
}

resource "aws_route_table" "rt_2_subnet_6" {
  vpc_id = aws_vpc.vpc_demo.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.test_nat.id
  }

  tags = {
    Name = "rt-2-subnet-6"
  }
}

resource "aws_route_table_association" "association_8" {
  subnet_id      = aws_subnet.subnet_6_private.id
  route_table_id = aws_route_table.rt_2_subnet_6.id
}

resource "aws_lb" "alb_1" {
  name               = "alb-1"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg_1.id]
  subnets            = [aws_subnet.subnet_1_public.id, aws_subnet.subnet_2_public.id]
}

resource "aws_lb" "alb_2" {
  name               = "alb-2"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg_1.id]
  subnets            = [aws_subnet.subnet_3_private.id, aws_subnet.subnet_4_private.id]
}

resource "aws_lb_target_group" "tg_1" {
  name     = "tg-1"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc_demo.id
}

resource "aws_lb_target_group" "tg_2" {
  name     = "tg-2"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc_demo.id
}

resource "aws_lb_target_group_attachment" "attachment_1" {
  target_group_arn = aws_lb_target_group.tg_1.arn
  target_id        = aws_instance.demo_1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "attachment_2" {
  target_group_arn = aws_lb_target_group.tg_1.arn
  target_id        = aws_instance.demo_2.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "attachment_3" {
  target_group_arn = aws_lb_target_group.tg_2.arn
  target_id        = aws_instance.demo_3.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "attachment_4" {
  target_group_arn = aws_lb_target_group.tg_2.arn
  target_id        = aws_instance.demo_4.id
  port             = 80
}

resource "aws_lb_listener" "alb_listener_1" {
  load_balancer_arn = aws_lb.alb_1.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_1.arn
  }
}

resource "aws_lb_listener" "alb_listener_2" {
  load_balancer_arn = aws_lb.alb_2.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_2.arn
  }
}

resource "aws_launch_template" "template_1" {
  name          = "template-1"
  image_id      = data.aws_ami.ami.id
  instance_type = "t2.micro"
  key_name      = "asdf"

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.sg_1.id]
  }
}

resource "aws_launch_template" "template_2" {
  name          = "template-2"
  image_id      = data.aws_ami.ami.id
  instance_type = "t2.micro"
  key_name      = "asdf"

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.sg_1.id]
  }
}

resource "aws_autoscaling_group" "asg_1" {
  name                = "asg-1"
  max_size            = 1
  min_size            = 1
  desired_capacity    = 1
  target_group_arns   = [aws_lb_target_group.tg_1.arn]
  vpc_zone_identifier = [aws_subnet.subnet_1_public.id, aws_subnet.subnet_2_public.id]

  launch_template {
    id = aws_launch_template.template_1.id
  }
}

resource "aws_autoscaling_group" "asg_2" {
  name                = "asg-2"
  max_size            = 1
  min_size            = 1
  desired_capacity    = 1
  target_group_arns   = [aws_lb_target_group.tg_2.arn]
  vpc_zone_identifier = [aws_subnet.subnet_3_private.id, aws_subnet.subnet_4_private.id]

  launch_template {
    id = aws_launch_template.template_2.id
  }
}

resource "aws_db_subnet_group" "subnet_group" {
  name       = "subnet_group"
  subnet_ids = [aws_subnet.subnet_5_private.id, aws_subnet.subnet_6_private.id]
}

resource "aws_db_instance" "mariadb" {
  allocated_storage      = 8
  db_subnet_group_name   = aws_db_subnet_group.subnet_group.id
  engine                 = "mariadb"
  engine_version         = "10.5"
  instance_class         = "db.t3.micro"
  multi_az               = true
  identifier             = "mariadb"  # Use identifier instead of name
  username               = "admin"
  password               = "root1234"
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.database_sg.id]
  tags = {
    Name = "MariaDB"
  }
}

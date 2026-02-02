resource "aws_vpc" "practice_vpc" {
  cidr_block = "192.168.0.0/16"

  tags = {
    Name = "practice_vpc"
  }

}

resource "aws_subnet" "public_sub" {
  vpc_id                  = aws_vpc.practice_vpc.id
  cidr_block              = "192.168.1.0/24"
  availability_zone       = "ap-northeast-3a"
  map_public_ip_on_launch = true
  tags = {
    Name = "public_sub"
  }
}

resource "aws_internet_gateway" "my_ig" {
  vpc_id = aws_vpc.practice_vpc.id
  tags = {
    Name = "my_ig"
  }

}

resource "aws_route_table" "my_rt" {
  vpc_id = aws_vpc.practice_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_ig.id
  }

  tags = {
    Name = " my_rt"
  }
}

resource "aws_route_table_association" "My_asso" {
  subnet_id      = aws_subnet.public_sub.id
  route_table_id = aws_route_table.my_rt.id
}

resource "aws_security_group" "firewall" {
  name   = "terraform-sec"
  vpc_id = aws_vpc.practice_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_instance" "terra_web" {
  ami                         = "ami-0ef44b9f9f20f3e57"
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public_sub.id
  key_name                    = "vpc_key"
  vpc_security_group_ids      = [aws_security_group.firewall.id]
  associate_public_ip_address = true

  user_data = <<-EOF
    #!/bin/bash
    apt update -y
    apt install apache2 -y
    systemctl start apache2
    systemctl enable apache2
    echo "Hii I am Sakshi Khele" > /var/www/html/index.html
  EOF

  tags = {
    Name = "web"
  }
}

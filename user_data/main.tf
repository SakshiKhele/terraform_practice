
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
  ami                         = var.ami
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public_sub.id
  key_name                    = var.key_name
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

resource "aws_subnet" "private_sub" {
  vpc_id            = aws_vpc.practice_vpc.id
  cidr_block        = "192.168.2.0/24"
  availability_zone = "ap-northeast-3b"
  tags = {
    Name = "private_sub"
  }
}
resource "aws_eip" "nat_eip" {
  domain = "vpc"

  tags = {
    Name = "nat-eip"
  }
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_sub.id

  tags = {
    Name = "nat-gateway"
  }

}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.practice_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }

  tags = {
    Name = "private-route-table"
  }
}

resource "aws_route_table_association" "private_rt_assoc" {
  subnet_id      = aws_subnet.private_sub.id
  route_table_id = aws_route_table.private_rt.id
}



resource "aws_instance" "private_web" {
  ami                    = var.ami
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.private_sub.id
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.firewall.id]

  tags = {
    Name = "private_web"
  }
}



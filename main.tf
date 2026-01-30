resource "aws_security_group" "firewall" {
  name   = "terraform-sec"
  vpc_id = "vpc-0ae59d33f4763dea9"

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

resource "aws_instance" "vm" {
  ami                    = "ami-0ef44b9f9f20f3e57"
  instance_type          = "t3.micro"
  key_name               = "vpc_key"
  vpc_security_group_ids = [aws_security_group.firewall.id]
  user_data              = file("user_data.sh")
  tags = {
    Name = "temp"
  }
}

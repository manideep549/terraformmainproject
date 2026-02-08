
resource "aws_security_group" "web_sg" {
  name        = "web-sg"
  description = "Allow SSH, HTTPS, 8080"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
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
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web1" {
  ami           = "ami-0f58b397bc5c1f2e8"
  instance_type = var.instance_type
  subnet_id     = aws_subnet.public1.id
  security_groups = [aws_security_group.web_sg.id]
  tags = { Name = "WebServer1" }
}

resource "aws_instance" "web2" {
  ami           = "ami-0f58b397bc5c1f2e8"
  instance_type = var.instance_type
  subnet_id     = aws_subnet.public2.id
  security_groups = [aws_security_group.web_sg.id]
  tags = { Name = "WebServer2" }
}

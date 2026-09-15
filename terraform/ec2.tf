data "aws_ami" "amazon_linux" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type

  subnet_id = aws_subnet.public.id

  vpc_security_group_ids = [
    aws_security_group.web.id
  ]

  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash

              dnf update -y

              dnf install -y httpd

              systemctl enable httpd
              systemctl start httpd

              echo "<h1>Hello from Hruday</h1>" > /var/www/html/index.html

              echo "<p>Welcome to my Webserver</p>" >> /var/www/html/index.html
              EOF

  tags = {
    Name    = "${var.project_name}-web-server"
    Project = var.project_name
  }
}
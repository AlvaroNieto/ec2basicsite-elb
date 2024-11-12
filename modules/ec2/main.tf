resource "aws_instance" "nginx" {
  ami                    = "ami-0ac1254314ec70353" # Amazon Linux 3 AMI x64
  instance_type          = "t3.micro"
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group]

  tags = {
    Name = var.instance_name
  }

  user_data = <<-EOF
        #!/bin/bash
        sudo yum update -y
        sudo yum install nginx -y
        sudo systemctl start nginx
        sudo systemctl enable nginx
        echo '<html><body><h1>Hello from ${var.instance_name}!</h1></body></html>' | sudo tee /usr/share/nginx/html/index.html > /dev/null
    EOF
}

resource "aws_lb_target_group_attachment" "target_attachment" {
  target_group_arn = var.target_group_arn
  target_id        = aws_instance.nginx.id
  port             = 80
}

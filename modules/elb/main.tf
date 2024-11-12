resource "aws_lb" "app_elb" {
  name               = "nginx-elb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.security_group_ids
  subnets            = var.subnet_ids
}

resource "aws_lb_target_group" "targetgroup" {
  name        = var.target_group_name
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"
}

# HTTP to HTTPS redirection listener
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.app_elb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      protocol    = "HTTPS"
      port        = "443"
      status_code = "HTTP_301"
    }
  }
}

# HTTPS listener with SSL certificate
resource "aws_lb_listener" "https_listener" {
  load_balancer_arn = aws_lb.app_elb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn = var.cert_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.targetgroup.arn
  }
}
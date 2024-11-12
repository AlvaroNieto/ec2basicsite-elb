output "elb_dns_name" {
  value = aws_lb.app_elb.dns_name
}

output "elb_zone_id" {
  value = aws_lb.app_elb.zone_id
}

output "target_group_arn" {
  value = aws_lb_target_group.targetgroup.arn
}

output "elb_https_dns_name" {
  value = aws_lb.app_elb.dns_name
}
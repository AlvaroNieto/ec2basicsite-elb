output "mainvpc_id" {
  value = aws_vpc.mainvpc.id
}

output "subnet_a_id" {
  value = aws_subnet.subnet_a.id
}

output "subnet_b_id" {
  value = aws_subnet.subnet_b.id
}

output "sec_group" {
  value = aws_security_group.allow_http_https.id
}
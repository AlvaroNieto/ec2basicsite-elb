output "instance_id" {
  value = aws_instance.nginx.id
}

output "instance_public_ip" {
  value = aws_instance.nginx.public_ip
}

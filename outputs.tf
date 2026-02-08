
output "web_instance_1_public_ip" {
  value = aws_instance.web1.public_ip
}

output "web_instance_2_public_ip" {
  value = aws_instance.web2.public_ip
}

output "rds_endpoint" {
  value = aws_db_instance.mysql.endpoint
}

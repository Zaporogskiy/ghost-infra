output "my_ip" {
  value = chomp(data.http.myip.response_body)
}

output "alb_dns_name" {
  value = aws_lb.alb_ghost.dns_name
}

output "rds_host" {
  value = aws_db_instance.ghost.address
}
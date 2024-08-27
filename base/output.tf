output "my_ip" {
  value = chomp(data.http.myip.response_body)
}

output "alb_dns_name" {
  value = aws_lb.alb_ghost.dns_name
}

output "rds_url" {
  value = aws_db_instance.ghost.address
}

output "user_data" {
  value = aws_launch_template.ghost_launch_template.user_data
}
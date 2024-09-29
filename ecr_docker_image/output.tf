output "my_ip" {
  value = chomp(data.http.myip.response_body)
}

output "ecr_repository_uri" {
  value = local.ecr_repository_uri
}
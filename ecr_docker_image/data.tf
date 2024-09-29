data "http" "myip" {
  url                = "https://api.ipify.org"
  request_timeout_ms = 5000
}
data "aws_caller_identity" "current" {}
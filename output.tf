output "app_url" {
  value = "http://${aws_instance.ubuntu.public_ip}/hello"
}
output "public_ip" {
  value = aws_instance.ubuntu.public_ip
}


 
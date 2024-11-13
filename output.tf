# outputs.tf

output "addition_app_public_ip" {
  description = "Public IP of the addition app server"
  value       = aws_instance.addition_app.public_ip
}

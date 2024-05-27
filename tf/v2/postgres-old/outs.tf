output "username" {
  sensitive = false
  value = "postgres"
}

output "password" {
  sensitive = true
  value = random_password.password.result
}

output "username" {
  sensitive = false
  value = "postgres"
}

output "service" {
  sensitive = false
  value = kubernetes_service.service.id
}
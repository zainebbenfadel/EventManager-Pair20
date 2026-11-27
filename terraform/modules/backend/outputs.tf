output "service_name" {
  value = kubernetes_service.backend-service.metadata[0].name
}
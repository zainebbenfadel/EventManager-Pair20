output "frontend_service_name" {
  value = kubernetes_service.frontend-service.metadata[0].name
}
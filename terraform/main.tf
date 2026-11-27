terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.20"
    }
  }
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "docker-desktop"
}

module "backend" {
  source          = "./modules/backend"
  docker_username = var.docker_username
}

module "frontend" {
  source          = "./modules/frontend"
  docker_username = var.docker_username
  laptop_a_ip     = var.laptop_a_ip
}
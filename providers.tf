terraform {
  required_version = ">= 1.0.0"

  # Define os provedores necessários para provisionar AWS e Kubernetes.
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }

  # Salva o estado do Terraform no LocalStack, simulando um bucket S3.
  backend "s3" {
    bucket                      = "terraform-state-sandbox"
    key                         = "dev/terraform.tfstate"
    region                      = "us-east-1"
    
    # Truques para o Terraform aceitar o LocalStack sem reclamar de SSL e rotas
    endpoint                    = "http://localhost:4566"
    use_path_style              = true
    skip_credentials_validation = true
    #skip_metadata_validation    = true
    skip_region_validation      = true
  }
}

# Configura o provedor AWS para apontar ao LocalStack do laboratório.
provider "aws" {
  region                      = "us-east-1"
  access_key                  = "mock_access_key"
  secret_key                  = "mock_secret_key"
  
  # Força o Terraform a usar o IP local para absolutamente tudo
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_region_validation      = true
  skip_requesting_account_id  = true

  # Formato robusto de mapeamento de endpoints
  endpoints {
    s3  = "http://127.0.0.1:4566"
    sts = "http://127.0.0.1:4566"
  }
}

# Usa o contexto do Minikube para aplicar os recursos no cluster local.
provider "kubernetes" {
  config_path = "~/.kube/config"
  config_context = "minikube"
}
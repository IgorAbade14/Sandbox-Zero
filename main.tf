# Arquivo: main.tf

# Bucket usado para armazenar logs da aplicação no futuro.
resource "aws_s3_bucket" "app_logs" {
  bucket = "sandbox-zero-app-logs"

  tags = {
    Environment = "Dev"
    Project     = "Sandbox-Zero"
    ManagedBy   = "Terraform"
  }
}

# Deploy da aplicação web simples para validar o funcionamento do cluster.
resource "kubernetes_deployment" "web_app" {
  metadata {
    name      = "sandbox-web-app"
    namespace = "default"
    labels = {
      app = "Sandbox-Web-App"
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "Sandbox-Web-App"
      }
    }

    template {
      metadata {
        labels = {
          app = "Sandbox-Web-App"
        }
      }

      spec {
        container {
          name  = "nginx"
          image = "nginx:alpine"

          port {
            container_port = 80
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "web_app_service" {
  metadata {
    name      = "sandbox-web-app-service"
    namespace = "default"
  }

  spec {
    selector = {
      app = kubernetes_deployment.web_app.spec[0].template[0].metadata[0].labels.app
    }

    port {
      port        = 80
      target_port = 80
      node_port   = 30080
    }

    type = "NodePort"
  }
}

# Armazena o banco de dados do laboratório em um volume persistente.
resource "kubernetes_persistent_volume_claim" "postgres_pvc" {
  metadata {
    name = "sandbox-postgres-pvc"
  }

  spec {
    access_modes = ["ReadWriteOnce"]

    resources {
      requests = {
        storage = "1Gi"
      }
    }
  }
}

resource "kubernetes_deployment" "postgres" {
  metadata {
    name      = "sandbox-postgres"
    namespace = "default"
    labels = {
      app = "Sandbox-Postgres"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "Sandbox-Postgres"
      }
    }

    template {
      metadata {
        labels = {
          app = "Sandbox-Postgres"
        }
      }

      spec {
        container {
          name  = "postgres"
          image = "postgres:15-alpine"

          port {
            container_port = 5432
          }

          env {
            name  = "POSTGRES_DB"
            value = "sandboxdb"
          }

          env {
            name  = "POSTGRES_USER"
            value = "db_user"
          }

          env {
            name  = "POSTGRES_PASSWORD"
            value = "SenhaSegura123"
          }

          volume_mount {
            name       = "postgres-storage"
            mount_path = "/var/lib/postgresql/data"
          }
        }

        volume {
          name = "postgres-storage"

          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.postgres_pvc.metadata[0].name
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "postgres_service" {
  metadata {
    name      = "postgres-service"
    namespace = "default"
  }

  spec {
    selector = {
      app = kubernetes_deployment.postgres.spec[0].template[0].metadata[0].labels.app
    }

    port {
      port        = 5432
      target_port = 5432
    }

    type = "ClusterIP"
  }
}

# Stack de observabilidade com Grafana e Prometheus.
resource "kubernetes_deployment" "grafana" {
  metadata {
    name = "sandbox-grafana"
    labels = {
      App = "SandboxGrafana"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        App = "SandboxGrafana"
      }
    }

    template {
      metadata {
        labels = {
          App = "SandboxGrafana"
        }
      }

      spec {
        container {
          image = "grafana/grafana:10.0.0" # Imagem oficial do Grafana
          name  = "grafana"

          port {
            container_port = 3000 # Porta padrão interna do Grafana
          }
        }
      }
    }
  }
}

# 2. SERVICE: Abrindo a porta do Grafana para o seu navegador
resource "kubernetes_service" "grafana_service" {
  metadata {
    name = "grafana-service"
  }

  spec {
    selector = {
      App = kubernetes_deployment.grafana.metadata[0].labels.App
    }

    port {
      port        = 3000
      target_port = 3000
      node_port   = 32000 # Porta fixa que você vai digitar no navegador
    }

    type = "NodePort"
  }
}

resource "kubernetes_deployment" "prometheus" {
  metadata {
    name = "sandbox-prometheus"
    labels = {
      App = "SandboxPrometheus"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        App = "SandboxPrometheus"
      }
    }

    template {
      metadata {
        labels = {
          App = "SandboxPrometheus"
        }
      }

      spec {
        container {
          image = "prom/prometheus:v2.45.0" # Imagem oficial estável do Prometheus
          name  = "prometheus"

          # Configuração básica padrão para o Prometheus rodar sem precisar de arquivo externo complexo por enquanto
          args = [
            "--config.file=/etc/prometheus/prometheus.yml",
            "--storage.tsdb.path=/prometheus"
          ]

          port {
            container_port = 9090 # Porta padrão interna do Prometheus
          }
        }
      }
    }
  }
}

# 2. SERVICE: Abrindo a porta do Prometheus internamente
resource "kubernetes_service" "prometheus_service" {
  metadata {
    name = "prometheus-service"
  }

  spec {
    selector = {
      App = kubernetes_deployment.prometheus.metadata[0].labels.App
    }

    port {
      port        = 9090
      target_port = 9090
    }

    type = "ClusterIP" # Fica isolado dentro do cluster, o Grafana vai conversar com ele por aqui
  }
}
# Sandbox-Zero 🌌 [![Sandbox-Zero CI/CD](https://github.com/IgorAbade14/Sandbox-Zero/actions/workflows/ci-cd.yml/badge.svg)](https://github.com/IgorAbade14/Sandbox-Zero/actions/workflows/ci-cd.yml)

> **Laboratório isolado DevOps** — Simule AWS completo localmente com Kubernetes, Infrastructure as Code e observabilidade.

---

## 📌 O Que É?

Sandbox-Zero é um ambiente educacional que replica AWS em sua máquina local, permitindo:
- ✅ Aprender **Terraform** (IaC)
- ✅ Dominar **Kubernetes** (Minikube)
- ✅ Implementar **observabilidade** (Prometheus + Grafana)
- ✅ Testar deployments **offline e isolado**

---

## 🛠️ Stack Tecnológico

- **Terraform**: Provisiona toda infraestrutura
- **LocalStack**: Emula AWS S3 (porta 4566)
- **Kubernetes**: Minikube como orquestrador
- **Observabilidade**: Prometheus + Grafana (porta 3000)
- **Banco de Dados**: PostgreSQL (PVC 1Gi)
- **Web App**: Nginx (2 replicas)

---

## 🏗️ Arquitetura

```
┌────────────────────────────────────┐
│  🐳 Docker (LocalStack S3)         │
│  ☸️  Kubernetes (Minikube)         │
│  ├─ Nginx (porta 30080)           │
│  ├─ PostgreSQL (porta 5432)       │
│  ├─ Prometheus (scrape 1m)        │
│  └─ Grafana (localhost:3000)      │
└────────────────────────────────────┘
```

**Fluxo:** Grafana → CoreDNS → Prometheus:9090 → Nginx/Apps → Métricas → Alertas (< 95%)

---

## 🚀 Como Usar

### **Pré-requisitos**
- Docker e Docker Compose instalados
- Minikube instalado e funcionando
- Terraform >= 1.0
- kubectl configurado
- Driver de virtualização compatível com o Minikube (por exemplo, Docker)
- Acesso ao Docker da máquina local

> ⚠️ Importante: este laboratório não funciona apenas com o código. Ele também depende do ambiente da máquina onde será executado. Em outro computador, é necessário ter essas ferramentas instaladas e corretamente configuradas para que o [ligar-lab.sh](ligar-lab.sh) funcione como aqui.

### **1. Iniciar Tudo**
```bash
./ligar-lab.sh
```
Script faz: LocalStack ↔ Minikube ↔ Terraform apply ↔ Grafana setup

### **2. Acessar**
```
Grafana: http://localhost:3000
Prometheus: http://localhost:9090
Nginx: http://localhost:30080
```

### **3. Desligar**
```bash
./desligar-lab.sh
```

---

## ⚠️ **Arquivos Sensíveis (Ignorados via .gitignore)**

Este projeto **contém credenciais hardcoded** apenas para **fins educacionais**. 

📝 **Todos os valores sensíveis estão documentados em `CREDENTIALS.txt`** (arquivo de referência):

| Arquivo | Sensível | Valor Padrão |
|---------|----------|-------------|
| `main.tf` | PostgreSQL senha | `SenhaSegura123` |
| `main.tf` | PostgreSQL usuário | `db_user` |
| `docker-compose.yml` | LocalStack mock | N/A (sem auth) |
| `ligar-lab.sh` | Grafana padrão | `admin:admin` |
| `providers.tf` | AWS mock keys | mock_access_key |

### **🔧 Para Usar Este Projeto**

1. **Baixe o repositório**
2. **Abra `CREDENTIALS.txt`** e copie os valores conforme necessário
3. **Substitua os valores** nos arquivos:
   - `main.tf` → linhas com `POSTGRES_PASSWORD`, `POSTGRES_USER`
   - `ligar-lab.sh` → linhas com `admin:admin`
4. **Adicione seus próprios valores** se quiser em produção
5. **Esses arquivos estarão no `.gitignore`** (não fazem push automático)

### **Credenciais Padrão (CREDENTIALS.txt)**
```
=== PostgreSQL ===
POSTGRES_DB: sandboxdb
POSTGRES_USER: db_user
POSTGRES_PASSWORD: SenhaSegura123

=== Grafana ===
Admin User: admin
Admin Password: admin

=== AWS Mock (LocalStack) ===
Access Key: mock_access_key
Secret Key: mock_secret_key
Region: us-east-1
Endpoint: http://127.0.0.1:4566
```

---

## 📊 Ciclo de Observabilidade

1. **Coleta**: Prometheus raspa métricas HTTP a cada 1 minuto
2. **Visualização**: Dashboard Grafana com Taxa de Sucesso (0-100%)
3. **Alertas**: Regra dispara se disponibilidade **< 95%** (a cada 10s)
4. **Dados**: Armazenados em séries temporais locais

---

## 📁 Estrutura

```
Sandbox-Zero/
├── main.tf                  # Infraestrutura K8s + Prometheus + Grafana
├── providers.tf             # AWS (LocalStack) + Kubernetes
├── docker-compose.yml       # LocalStack
├── ligar-lab.sh            # Init automático
├── desligar-lab.sh         # Cleanup
├── dashboard-sandbox.json  # Grafana dashboard
├── CREDENTIALS.txt         # Referência de valores sensíveis
└── localstack/             # Cache LocalStack
```

---

## 🔐 Segurança

⚠️ **Este é um laboratório educacional LOCAL.** Credenciais hardcoded são apenas para aprendizado.

**Em produção:**
- Use variáveis de ambiente ou Vault
- Implemente RBAC no K8s
- Ative TLS/SSL
- Nunca faça commit de `.env` ou secrets

---

## 📝 Licença

Código aberto para fins educacionais.

---

**Desenvolvido para aprender DevOps offline. 🚀**

#!/bin/bash
echo "🚀 Iniciando os motores do laboratório..."

# Sobe os serviços locais que o laboratório depende.
docker compose up -d

# Inicia o cluster Kubernetes local para a infraestrutura.
minikube start --driver=docker --wait=all --extra-config=apiserver.v=2

# Aguarda o LocalStack ficar disponível antes de prosseguir.
echo "⏳ Aguardando o LocalStack abrir a porta 4566 de verdade..."
while ! nc -z localhost 4566; do   
  sleep 1
done
echo "✅ LocalStack está totalmente acordado!"

echo "🧹 Limpando resquícios antigos do Minikube para evitar erros..."
kubectl delete deployment sandbox-web-app sandbox-postgres sandbox-grafana sandbox-prometheus --ignore-not-found
kubectl delete service sandbox-web-app-service postgres-service grafana-service prometheus-service --ignore-not-found
kubectl delete pvc sandbox-postgres-pvc --ignore-not-found

echo "🪣 Recriando o cérebro do Terraform no LocalStack..."
curl -X PUT http://127.0.0.1:4566/terraform-state-sandbox

echo "🏁 Inicializando e aplicando a infraestrutura..."
terraform init -upgrade
terraform apply -auto-approve

echo "🔗 Acoplando o Grafana do laboratório no localhost:3000..."
# Expõe o Grafana no host para facilitar o acesso pelo navegador.
kubectl port-forward deployment/sandbox-grafana 3000:3000 > /dev/null 2>&1 &

echo "📊 Aguardando o túnel do localhost:3000 responder..."
while ! nc -z localhost 3000; do   
  sleep 1
done
echo "✅ Grafana do laboratório acoplado com sucesso na porta 3000!"

echo "🚀 Automatizando a criação do Dashboard via API do Grafana..."
# Importa o dashboard JSON já preparado para o laboratório.
curl -X POST http://admin:admin@localhost:3000/api/dashboards/db \
  -H "Content-Type: application/json" \
  -d "{\"dashboard\": $(cat dashboard-sandbox.json), \"overwrite\": true}"

echo "✅ TUDO PRONTO E SINCRONIZADO!"

#http://prometheus-service:9090
#!/bin/bash

echo "🛑 Desligando os motores do laboratório..."

# Para o cluster local e os containers do Docker.
minikube stop
docker compose down

if lsof -i :3000 -t >/dev/null 2>&1; then
  echo "⚠️ Porta 3000 está ocupada, liberando..."
  # Libera a porta local caso o redirecionamento do Grafana ainda esteja preso.
  sudo fuser -k -9 3000/tcp >/dev/null 2>&1
  sleep 2 # Dá um tempinho para o processo ser finalizado de fato
fi

echo "✅ Laboratório desligado com sucesso!"
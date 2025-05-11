#!/bin/bash

# ===== CONFIGURAÇÕES =====

ec2_ip=$(terraform output -raw ec2_ip)
KEY_PATH="~/.ssh/tech_key"  # caminho da sua chave privada
SSH_USER="ubuntu"
REMOTE_PROJECT_DIR="/home/ubuntu/tech-challenge3-lanchonete"

# ===== PASSO 1: Acessa EC2 via SSH e destrói o RDS =====

echo "🧨 Acessando a EC2 e iniciando 'terraform destroy' no projeto RDS..."

ssh -i ${KEY_PATH} -o StrictHostKeyChecking=no ${SSH_USER}@${ec2_ip} <<EOF
  echo "📦 Acessando diretório do projeto RDS..."
  cd ${REMOTE_PROJECT_DIR}

  sudo su

  echo "🧹 Executando 'terraform destroy' no RDS..."
  terraform destroy -auto-approve

  echo "✅ RDS destruído. Saindo da EC2..."
  exit
EOF

# ===== PASSO 2: Aguarda e destrói EC2 localmente =====

echo "⌛ Aguardando término da execução na EC2..."
sleep 10

echo "🔥 Agora destruindo a EC2 localmente com Terraform..."
terraform destroy -auto-approve

echo "✅ Tudo limpo com sucesso!"

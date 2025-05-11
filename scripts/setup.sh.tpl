#!/bin/bash

# Variáveis para loop de espera
MAX_RETRIES=30
RETRY_INTERVAL=20

# Captura variaveis de ambiente
RDS_USER="${db_user}"
RDS_PASS="${db_password}"
RDS_DB_NAME="${db_name}"

# Adiciona as chaves de acesso seguramente
echo "Adicionando chaves de acesso..."
mkdir -p /home/ubuntu/.aws
cat > /home/ubuntu/.aws/config <<EOF
[default]
aws_access_key_id = ${aws_access_key}
aws_secret_access_key = ${aws_secret_key}
EOF
chmod 600 /home/ubuntu/.aws/config

# Atualiza pacotes e instala dependências
apt-get update -y
apt-get install -y unzip wget git mysql-client

# Instala o Terraform
wget https://releases.hashicorp.com/terraform/1.8.2/terraform_1.8.2_linux_amd64.zip
unzip terraform_1.8.2_linux_amd64.zip
mv terraform /usr/local/bin/

# Clona o repositório do projeto RDS
cd /home/ubuntu
echo "Clonando repositório do projeto..."
git clone https://github.com/ju-c-lopes/tech-challenge3-lanchonete
cd tech-challenge3-lanchonete

# Captura IP privado da EC2
ec2_ip=$(hostname -I | awk '{print $1"/32"}')

# Cria o arquivo terraform.tfvars dentro da EC2
cat > terraform.tfvars <<EOF
db_name     = "${db_name}"
db_user     = "${db_user}"
db_password = "${db_password}"
my_ip       = "${my_ip}"
ec2_ip      = "$ec2_ip"
EOF

# Configura variáveis de ambiente para a AWS
export AWS_ACCESS_KEY_ID="${aws_access_key}"
export AWS_SECRET_ACCESS_KEY="${aws_secret_key}"

# Roda Terraform (não interativo)
terraform init
terraform apply -auto-approve

echo "Instância RDS iniciada!"

RDS_HOST=$(terraform output -raw rds_endpoint | cut -d':' -f1)

# Aguarda RDS ficar disponível
echo "Waiting for RDS to become available..."
for ((i=1; i<=MAX_RETRIES; i++)); do
    # Try connecting to the RDS instance
    if mysqladmin ping -h "$RDS_HOST" -P 3306 --silent; then
        echo "RDS is available!"
        break
    fi

    # If the maximum retries are reached, exit with an error
    if [ "$i" -eq "$MAX_RETRIES" ]; then
        echo "RDS did not become available within the expected time. Exiting."
        exit 1
    fi

    # Wait before the next retry
    echo "RDS not available yet. Retrying in $RETRY_INTERVAL seconds... ($i/$MAX_RETRIES)"
    sleep "$RETRY_INTERVAL"
done

echo "Usuário MySQL: $RDS_USER"
echo "Senha MySQL: $RDS_PASS"
echo "Host MySQL: $RDS_HOST"
echo "Banco de dados: $RDS_DB_NAME"

sleep 10
# Cria o banco caso não exista
mysql -h "$RDS_HOST" -P 3306 -u "$RDS_USER" -p"$RDS_PASS" -e "CREATE DATABASE IF NOT EXISTS \`$RDS_DB_NAME\` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;"
sleep 10

# Executa os scripts SQL no banco
mysql -h "$RDS_HOST" -P 3306 -u "$RDS_USER" -p"$RDS_PASS" "$RDS_DB_NAME" < ./scripts/schema.sql

# Tech Challenge - Fase 3: Infraestrutura RDS MySQL com Terraform

Este projeto provisiona automaticamente uma instância RDS MySQL na AWS utilizando Terraform, com opção de popular o banco via EC2 provisionada para executar os scripts SQL.

---

## Pré-requisitos

- Conta AWS válida com acesso à criação de recursos EC2, RDS e IAM
- Chave pública SSH gerada localmente (`~/.ssh/tech_key.pub`)
- Terraform instalado (recomendado via `tfenv`)
```bash
git clone https://github.com/tfutils/tfenv.git ~/.tfenv
echo 'export PATH="$HOME/.tfenv/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```
- Acesso à internet e permissões para clonar repositórios

---

## Configurando credenciais AWS

Crie o arquivo `~/.aws/credentials` com o seguinte conteúdo:

```ini
[default]
aws_access_key_id = SUA_ACCESS_KEY
aws_secret_access_key = SUA_SECRET_KEY
```

**SUPER-IMPORTANTE:** nunca adicione esse arquivo ao Git.

---

## Arquivo terraform.tfvars

Na raiz do projeto, crie um arquivo chamado `terraform.tfvars` com conteúdo semelhante ao exemplo a seguir:

```hcl
db_name     = "lanchonete"
db_user     = "SEU_USUARIO"
db_password = "SUA_SENHA"
my_ip       = "SEU_IP_PUBLICO/32"
aws_access_key = "SUA_ACCESS_KEY"
aws_secret_key = "SUA_SECRET_KEY"
```

Dica: para descobrir seu IP, acesse https://www.meuip.com.br/

---

## Antes de rodar o provisionamento

Para que o provisionamento ocorra com sucesso, antes de rodar os comandos do terraform, você precisa exportar as variáveis de ambiente no terminal

```bash
export TF_VAR_aws_access_key="SUA_CHAVE_PUBLICA"
export TF_VAR_aws_secret_key="SUA_CHAVE_PRIVADA"
```

## Rodando o provisionamento

```bash
terraform init
terraform apply -auto-approve
```

Isso criará:
- A instância EC2 com Terraform pré-instalado
- A EC2 clonará o repositório RDS, aplicará o Terraform e criará o banco na AWS RDS
- O banco será populado com os dados do dump SQL automaticamente

---

## Destruindo os recursos

Execute o script `destroy.sh`:

```bash
chmod +x destroy.sh
./destroy.sh
```

Esse script:
1. Acessa a EC2 via SSH
2. Executa `terraform destroy` no projeto RDS
3. Aguarda a finalização do RDS
4. Desconecta da EC2
5. Executa `terraform destroy` localmente para remover a EC2

---

## Segurança

- As chaves AWS devem estar apenas em `~/.aws/credentials` ou como variáveis de ambiente
- O arquivo `terraform.tfvars` deve estar listado no `.gitignore`
- Use `aws_access_key` e `aws_secret_key` apenas em ambientes seguros
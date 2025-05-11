variable "region" {
    default = "us-east-1"
}
variable "my_ip" {
    sensitive = true
}
variable "db_name" {
    sensitive = true
}
variable "db_user" {
    sensitive = true
}
variable "db_password" {
    sensitive = true
}

variable "github_repo_url" {
    default = "https://github.com/ju-c-lopes/tech-challenge3-lanchonete"
}

variable "aws_access_key" {
    description = "AWS Access Key ID"
    sensitive   = true
}

variable "aws_secret_key" {
    description = "AWS Secret Access Key"
    sensitive   = true
}



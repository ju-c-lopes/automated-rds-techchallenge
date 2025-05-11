provider "aws" {
    region = var.region
    profile = "default"
}

data "aws_ami" "ubuntu" {
    most_recent = true
    owners      = ["099720109477"]
    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
    }
}

resource "aws_key_pair" "default" {
    key_name   = "techchallenge-key"
    public_key = file("~/.ssh/tech_key.pub")
}

resource "aws_security_group" "ec2_sg" {
    name   = "ec2-sg"
    vpc_id = data.aws_vpc.default.id

    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = [var.my_ip]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

data "aws_vpc" "default" {
    default = true
}

data "aws_subnets" "default" {
    filter {
        name   = "vpc-id"
        values = [data.aws_vpc.default.id]
    }
}

resource "aws_instance" "rds_provisioner" {
    ami                    = data.aws_ami.ubuntu.id
    instance_type          = "t2.micro"
    subnet_id              = data.aws_subnets.default.ids[0]
    key_name               = aws_key_pair.default.key_name
    vpc_security_group_ids = [aws_security_group.ec2_sg.id]

    user_data = templatefile("scripts/setup.sh.tpl", {
        db_user     = var.db_user,
        db_password = var.db_password,
        db_name     = var.db_name,
        my_ip       = var.my_ip,
        aws_access_key = var.aws_access_key,
        aws_secret_key = var.aws_secret_key
    })

    tags = {
        Name = "rds-provisioner"
    }
}

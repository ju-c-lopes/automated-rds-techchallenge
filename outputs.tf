output "ec2_ip" {
  value = aws_instance.rds_provisioner.public_ip
}

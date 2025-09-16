# Outputs for EC2 IPs, intern login URL, IAM info

# this output will show the public IP of the development instance
output "dev_instance_ip" {
  value = aws_instance.nextwork_dev.public_ip
}

# this output will show the login URL for the intern user
output "intern_login_url" {
  value = "https://${aws_iam_account_alias.nextwork_alias.account_alias}.signin.aws.amazon.com/console/"
}

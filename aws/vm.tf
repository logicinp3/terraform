# AWS EC2 Instance Configuration

# 创建 EC2 实例
resource "aws_instance" "web_server" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name
  subnet_id     = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.web_server_sg.id]

  # 根卷配置
  root_block_device {
    volume_size           = 8
    volume_type           = "gp2"
    delete_on_termination = true
  }

  # 标签
  tags = {
    Name = var.instance_name
  }

  # 启动脚本（可选）
  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd
    systemctl start httpd
    systemctl enable httpd
    echo "<h1>Hello from Terraform on AWS!</h1>" > /var/www/html/index.html
  EOF

  # 监控设置
  monitoring = true
}

# 创建弹性 IP（可选）
resource "aws_eip" "web_server_eip" {
  instance = aws_instance.web_server.id
  vpc      = true
}

# 输出信息
output "instance_public_ip" {
  value       = aws_eip.web_server_eip.public_ip
  description = "The public IP address of the EC2 instance"
}

output "instance_private_ip" {
  value       = aws_instance.web_server.private_ip
  description = "The private IP address of the EC2 instance"
}

output "instance_id" {
  value       = aws_instance.web_server.id
  description = "The ID of the EC2 instance"
}
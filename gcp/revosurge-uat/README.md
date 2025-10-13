# GCP VM 实例部署

这个 Terraform 配置用于在 GCP 上创建多个区域的 VM 实例，使用现有的 VPC 和子网。

## 项目信息

- **项目 ID**: revosurge-uat
- **项目名称**: revosurge-uat

## 现有网络资源

该配置使用以下现有的子网：

| 子网名称 | 区域 | IP 范围 |
|---------|------|---------|
| algorithm-ew1 | europe-west1 | 172.20.10.0/24 |
| algorithm-uc1 | us-central1 | 172.20.11.0/24 |
| algorithm-as1 | asia-southeast1 | 172.20.12.0/24 |

## 部署的 VM 实例

该配置将在欧洲西部1区域创建 VM 实例：

1. **algorithm-ew1-vm1** - 欧洲西部1 (europe-west1-a)
   - 机器类型：自定义 8 vCPU, 16GB RAM
   - 操作系统：Ubuntu 22.04 LTS
   - 磁盘：500GB Balanced Persistent Disk
   - 网络标签：algorithm
   - 外部 IP：禁用

## 使用步骤

### 1. 准备工作

确保你已经：
- 安装了 Terraform
- 配置了 GCP 认证（通过 `gcloud auth application-default login` 或服务账户密钥）
- 具有对项目 `revosurge-uat` 的适当权限

### 2. 配置变量

复制示例变量文件并修改：

```bash
cp terraform.tfvars.example terraform.tfvars
```

根据需要修改 `terraform.tfvars` 文件中的变量。

### 3. 初始化 Terraform

```bash
terraform init
```

### 4. 查看执行计划

```bash
terraform plan
```

### 5. 应用配置

```bash
terraform apply
```

### 6. 查看输出

部署完成后，Terraform 将输出所有 VM 实例的信息，包括外部和内部 IP 地址。

## 配置说明

### 主要文件

- `provider.tf` - GCP provider 配置
- `variables.tf` - 变量定义
- `data.tf` - 数据源配置（获取现有资源）
- `vpc.tf` - 防火墙规则配置
- `vm.tf` - VM 实例配置

### 自定义配置

你可以通过修改 `terraform.tfvars` 文件来自定义：

- VM 实例名称
- 机器类型
- 磁盘大小
- 操作系统镜像
- 区域和可用区

### 示例自定义配置

```hcl
vm_instance = {
  name         = "my-custom-ew1-vm"
  machine_type = "e2-standard-4"  # 4 vCPU, 16GB RAM
  zone         = "europe-west1-a"
  region       = "europe-west1"
  subnet_name  = "algorithm-ew1"
  network_tags = ["algorithm", "production"]
}

# 启用外部 IP
enable_external_ip = true

# 使用不同的磁盘类型
vm_disk_type = "pd-ssd"  # SSD 持久化磁盘
```

## 安全注意事项

- 防火墙规则允许 SSH 访问（端口 22）从任何 IP
- 建议在生产环境中限制 SSH 访问的源 IP 范围
- VM 实例使用默认服务账户，具有完整的云平台访问权限

## 清理资源

要删除所有创建的资源：

```bash
terraform destroy
```

## 最佳实践

1. **使用数据源**: 该配置使用数据源来引用现有资源，避免重复创建
2. **模块化设计**: 通过变量配置实现灵活的部署选项
3. **资源命名**: 使用一致的命名约定
4. **输出信息**: 提供详细的输出信息便于管理

## 故障排除

如果遇到权限问题，确保你的服务账户具有以下角色：
- Compute Instance Admin
- Compute Network Admin
- Service Account User

如果遇到网络问题，检查：
- VPC 和子网是否存在
- 防火墙规则是否正确配置
- 子网名称是否与现有资源匹配

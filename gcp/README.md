# GCP Terraform 项目管理

本目录包含多个 GCP 项目的 Terraform 配置，每个子目录代表一个独立的 GCP 项目环境。

## 目录结构

```
gcp/
├── README.md                    # 本文件
├── revosurge-uat/              # revosurge-uat 项目配置
│   ├── provider.tf             # Provider 配置
│   ├── variables.tf            # 变量定义
│   ├── vpc.tf                  # VPC 和防火墙规则
│   ├── vm.tf                   # VM 实例配置
│   ├── nat.tf                  # Cloud NAT 配置
│   ├── terraform.tfvars        # 实际变量值（gitignored）
│   └── terraform.tfvars.example # 变量示例文件
└── [其他项目目录]/             # 其他 GCP 项目
```

## 前置要求

### 1. 安装 Terraform

```bash
# macOS
brew install terraform

# 验证安装
terraform version
```

### 2. 配置 GCP 认证

**方式 1：使用 gcloud CLI（推荐）**

```bash
# 安装 gcloud CLI
brew install --cask google-cloud-sdk

# 登录 Google 账号
gcloud auth login

# 设置应用默认凭证
gcloud auth application-default login

# 设置默认项目
gcloud config set project YOUR_PROJECT_ID
```

**方式 2：使用服务账号密钥**

```bash
# 下载服务账号密钥文件到安全位置
# 例如：~/.gcp/your-project-key.json

# 设置环境变量
export GOOGLE_CREDENTIALS="~/.gcp/your-project-key.json"
```

## 快速开始

### 1. 选择项目目录

```bash
cd gcp/revosurge-uat  # 或其他项目目录
```

### 2. 配置变量

```bash
# 复制示例文件
cp terraform.tfvars.example terraform.tfvars

# 编辑配置文件
vim terraform.tfvars
```

**重要配置项说明：**

#### subnet_configs（子网配置）
```hcl
subnet_configs = {
  "subnet-name" = {
    region             = "region-name"
    primary_ipv4_range = "CIDR-range"
  }
}
```

#### vm_instances（VM 实例配置）
```hcl
vm_instances = {
  "region-key" = {
    instances = [
      {
        name          = "vm-name"
        machine_type  = "machine-type"
        zone          = "zone-name"
        image_family  = "ubuntu-2204-lts"
        image_project = "ubuntu-os-cloud"
        disk_size     = 100
        disk_type     = "pd-balanced"
        network_tags  = ["tag1", "tag2"]
        network       = "vpc-network-name"
        subnetwork    = "subnet-name"  # 必须在 subnet_configs 中定义
      }
    ]
  }
}
```

### 3. 初始化 Terraform

```bash
# 初始化工作目录，下载 provider 插件
terraform init
```

### 4. 验证配置

```bash
# 验证配置语法
terraform validate

# 格式化代码
terraform fmt
```

### 5. 查看执行计划

```bash
# 查看将要创建/修改/删除的资源
terraform plan

# 保存执行计划到文件
terraform plan -out=tfplan
```

### 6. 应用配置

```bash
# 交互式应用（需要确认）
terraform apply

# 自动批准应用
terraform apply -auto-approve

# 使用保存的计划文件
terraform apply tfplan
```

### 7. 查看输出

```bash
# 查看所有输出
terraform output

# 查看特定输出
terraform output vm_instance_info
terraform output connection_info
```

## 导入现有资源

如果 GCP 中已经存在某些资源，需要将它们导入到 Terraform 状态中，避免冲突。

### 导入防火墙规则

```bash
terraform import google_compute_firewall.RESOURCE_NAME projects/PROJECT_ID/global/firewalls/FIREWALL_NAME
```

**示例：**
```bash
terraform import google_compute_firewall.revosurge_uat_allow_ssh projects/revosurge-uat/global/firewalls/revosurge-uat-allow-ssh
```

### 导入 VM 实例

```bash
terraform import google_compute_instance.RESOURCE_NAME["KEY"] projects/PROJECT_ID/zones/ZONE/instances/INSTANCE_NAME
```

**示例：**
```bash
terraform import google_compute_instance.vm_instance["europe-west1-0"] projects/revosurge-uat/zones/europe-west1-b/instances/algorithm-ew1-vm1
```

### 导入静态 IP 地址

```bash
terraform import google_compute_address.RESOURCE_NAME["KEY"] projects/PROJECT_ID/regions/REGION/addresses/ADDRESS_NAME
```

**示例：**
```bash
terraform import google_compute_address.vm_external_ip["europe-west1-0"] projects/revosurge-uat/regions/europe-west1/addresses/algorithm-ew1-vm1-external-ip
```

### 导入 VPC 网络

```bash
terraform import google_compute_network.RESOURCE_NAME projects/PROJECT_ID/global/networks/NETWORK_NAME
```

### 导入子网

```bash
terraform import google_compute_subnetwork.RESOURCE_NAME["KEY"] projects/PROJECT_ID/regions/REGION/subnetworks/SUBNET_NAME
```

## 常用操作

### 查看当前状态

```bash
# 列出所有资源
terraform state list

# 查看特定资源详情
terraform state show google_compute_instance.vm_instance[\"europe-west1-0\"]
```

### 刷新状态

```bash
# 从 GCP 刷新状态
terraform refresh
```

### 销毁资源

```bash
# 销毁所有资源（需要确认）
terraform destroy

# 自动批准销毁
terraform destroy -auto-approve

# 销毁特定资源
terraform destroy -target=google_compute_instance.vm_instance[\"europe-west1-0\"]
```

### 移除资源（不删除实际资源）

```bash
# 从 Terraform 状态中移除，但不删除 GCP 中的资源
terraform state rm google_compute_instance.vm_instance[\"europe-west1-0\"]
```

## 变量配置详解

### 项目基础配置

```hcl
project_id       = "your-project-id"        # GCP 项目 ID
project_name     = "your-project-name"      # 项目名称
default_region   = "asia-southeast1"        # 默认区域
default_zone     = "asia-southeast1-a"      # 默认可用区
current_vpc_name = "your-vpc-name"          # VPC 网络名称
```

### 常用 GCP 区域和可用区

| 区域 | 可用区 | 位置 |
|------|--------|------|
| `asia-southeast1` | a, b, c | 新加坡 |
| `asia-east1` | a, b, c | 台湾 |
| `asia-northeast1` | a, b, c | 东京 |
| `europe-west1` | b, c, d | 比利时 |
| `europe-west2` | a, b, c | 伦敦 |
| `us-central1` | a, b, c, f | 爱荷华 |
| `us-west1` | a, b, c | 俄勒冈 |
| `us-east1` | b, c, d | 南卡罗来纳 |

### 机器类型参考

| 类型 | 规格 | 说明 |
|------|------|------|
| `e2-micro` | 0.25-2 vCPU, 1GB RAM | 最小实例 |
| `e2-small` | 0.5-2 vCPU, 2GB RAM | 小型实例 |
| `e2-medium` | 1-2 vCPU, 4GB RAM | 中型实例 |
| `e2-standard-2` | 2 vCPU, 8GB RAM | 标准实例 |
| `e2-standard-4` | 4 vCPU, 16GB RAM | 标准实例 |
| `custom-8-16384` | 8 vCPU, 16GB RAM | 自定义实例 |
| `custom-16-32768` | 16 vCPU, 32GB RAM | 自定义实例 |

### 磁盘类型

| 类型 | 说明 | 性能 |
|------|------|------|
| `pd-standard` | 标准持久化磁盘 | 低成本，低性能 |
| `pd-balanced` | 平衡持久化磁盘 | 平衡性能和成本 |
| `pd-ssd` | SSD 持久化磁盘 | 高性能，高成本 |

## 故障排查

### 常见错误

#### 1. 认证错误

**错误信息：**
```
Error: Attempted to load application default credentials
```

**解决方案：**
```bash
gcloud auth application-default login
```

#### 2. Zone 不存在

**错误信息：**
```
Error: Error loading zone 'europe-west1-a': Unknown zone
```

**解决方案：**
检查并使用正确的可用区。例如 `europe-west1` 只有 `b`, `c`, `d`，没有 `a`。

#### 3. 资源已存在

**错误信息：**
```
Error: The resource already exists
```

**解决方案：**
使用 `terraform import` 导入现有资源。

#### 4. 权限不足

**错误信息：**
```
Error: Permission denied
```

**解决方案：**
确保你的账号或服务账号具有以下权限：
- Compute Admin
- Service Account User
- Network Admin

### 查看日志

```bash
# 启用详细日志
export TF_LOG=DEBUG
terraform apply

# 保存日志到文件
export TF_LOG_PATH=./terraform.log
terraform apply
```

## 最佳实践

### 1. 使用版本控制

```bash
# 初始化 git 仓库
git init

# 确保 .gitignore 包含敏感文件
echo "terraform.tfvars" >> .gitignore
echo "*.tfstate*" >> .gitignore
echo ".terraform/" >> .gitignore
```

### 2. 使用 Terraform Backend

在 `provider.tf` 中配置远程状态存储：

```hcl
terraform {
  backend "gcs" {
    bucket = "your-terraform-state-bucket"
    prefix = "terraform/state"
  }
}
```

### 3. 使用工作空间

```bash
# 创建新工作空间
terraform workspace new dev
terraform workspace new prod

# 切换工作空间
terraform workspace select dev

# 查看当前工作空间
terraform workspace show

# 列出所有工作空间
terraform workspace list
```

### 4. 使用变量文件

```bash
# 使用不同环境的变量文件
terraform apply -var-file="dev.tfvars"
terraform apply -var-file="prod.tfvars"
```

### 5. 定期备份状态文件

```bash
# 备份状态文件
terraform state pull > terraform.tfstate.backup.$(date +%Y%m%d)
```

## 安全建议

1. **不要提交敏感信息**
   - `terraform.tfvars` 应该在 `.gitignore` 中
   - 服务账号密钥文件不要提交到版本控制

2. **使用最小权限原则**
   - 为服务账号分配最小必要权限
   - 定期审查和轮换密钥

3. **启用防火墙规则**
   - 限制 SSH 访问的源 IP 范围
   - 使用网络标签管理访问控制

4. **使用私有 IP**
   - 考虑使用 Cloud NAT 而不是公网 IP
   - 通过 VPN 或 Cloud IAP 访问实例

5. **定期更新**
   - 定期更新 Terraform 版本
   - 定期更新 Provider 版本

## 资源链接

- [Terraform 官方文档](https://www.terraform.io/docs)
- [Google Provider 文档](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
- [GCP 区域和可用区](https://cloud.google.com/compute/docs/regions-zones)
- [GCP 机器类型](https://cloud.google.com/compute/docs/machine-types)
- [GCP 定价计算器](https://cloud.google.com/products/calculator)

## 支持

如有问题或建议，请联系基础设施团队。

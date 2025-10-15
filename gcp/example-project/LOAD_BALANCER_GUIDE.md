# GCP Load Balancer 配置指南

本文档说明如何配置和使用 GCP Global External Application Load Balancer。

## 架构概述

```
Internet
    ↓
[Global External IP: ortb-lb-external-ip]
    ↓
[Forwarding Rule: ortb-lb-forwarding-rule]
    ↓
[HTTP Target Proxy]
    ↓
[URL Map - Simple host and path rule]
    ↓
[Backend Service: ortb-global-backend]
    ↓
[Health Check: ortb-health-check (TCP:8080)]
    ↓
[Instance Groups]
    ├── algorithm-ew2-a-ig (europe-west2-a)
    ├── algorithm-ew1-ig (europe-west1-a)
    └── algorithm-uc1-ig (us-central1-a)
```

## 配置组件

### 1. Load Balancer 基础配置

| 配置项 | 值 | 说明 |
|--------|-----|------|
| **名称** | `ortb-lb` | Load Balancer 名称 |
| **类型** | Application Load Balancer | 应用层负载均衡 |
| **访问方式** | External | 外部访问 |
| **区域** | Global | 全球区域访问 |
| **代** | Global external Application Load Balancer | 新一代 ALB |

### 2. Frontend Configuration

| 配置项 | 值 | 说明 |
|--------|-----|------|
| **Forwarding Rule** | `ortb-lb-forwarding-rule` | 转发规则名称 |
| **Protocol** | HTTP | 协议类型 |
| **Port** | 80 | 监听端口 |
| **IP Version** | IPv4 | IP 地址版本 |
| **External IP** | `ortb-lb-external-ip` | 静态外部 IP 名称 |

### 3. Backend Service Configuration

| 配置项 | 值 | 说明 |
|--------|-----|------|
| **名称** | `ortb-global-backend` | Backend Service 名称 |
| **Backend Type** | Instance Group | 后端类型 |
| **Protocol** | HTTP | 协议 |
| **Named Port** | http | 命名端口 |
| **Timeout** | 30 秒 | 超时时间 |
| **IP Selection** | IPv4 only | IP 地址选择策略 |
| **Session Affinity** | Client IP | 会话亲和性 |
| **Locality LB Policy** | RING_HASH | 负载均衡策略 |
| **Consistent Hash** | 1024 | 一致性哈希环大小 |
| **Cloud CDN** | Disabled | 关闭 CDN |
| **Cloud Armor** | Disabled | 关闭安全策略 |
| **Logging** | Disabled | 关闭日志 |

### 4. Health Check Configuration

| 配置项 | 值 | 说明 |
|--------|-----|------|
| **名称** | `ortb-health-check` | Health Check 名称 |
| **Protocol** | TCP | 探测协议 |
| **Port** | 8080 | 探测端口 |
| **Check Interval** | 5 秒 | 检查间隔 |
| **Timeout** | 5 秒 | 超时时间 |
| **Healthy Threshold** | 2 | 健康阈值 |
| **Unhealthy Threshold** | 2 | 不健康阈值 |

### 5. Routing Rules

- **类型**: Simple host and path rule
- **默认行为**: 所有流量路由到 `ortb-global-backend`

## 变量配置

### 基础变量

```hcl
# Load Balancer 名称
lb_name = "ortb-lb"

# 外部 IP 名称
lb_external_ip_name = "ortb-lb-external-ip"

# Forwarding Rule 名称
lb_forwarding_rule_name = "ortb-lb-forwarding-rule"

# Backend Service 名称
lb_backend_service_name = "ortb-global-backend"

# Health Check 名称
lb_health_check_name = "ortb-health-check"
```

### Backend 配置

#### 单个 Backend

```hcl
lb_backends = {
  "backend-ew2-a" = {
    instance_group_key = "algorithm-ew2-a-ig"  # 对应 instance_groups 的 key
    balancing_mode     = "UTILIZATION"
    capacity_scaler    = 1.0
    max_utilization    = 0.8
  }
}
```

#### 多个 Backend（多区域）

```hcl
lb_backends = {
  "backend-ew1" = {
    instance_group_key = "algorithm-ew1-group"
    balancing_mode     = "UTILIZATION"
    capacity_scaler    = 1.0
    max_utilization    = 0.8
  }
  "backend-ew2" = {
    instance_group_key = "algorithm-ew2-a-ig"
    balancing_mode     = "UTILIZATION"
    capacity_scaler    = 1.0
    max_utilization    = 0.8
  }
  "backend-uc1" = {
    instance_group_key = "algorithm-uc1-group"
    balancing_mode     = "UTILIZATION"
    capacity_scaler    = 1.0
    max_utilization    = 0.8
  }
}
```

### Backend 参数说明

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `instance_group_key` | string | - | Instance Group 的 key（必填） |
| `balancing_mode` | string | "UTILIZATION" | 负载均衡模式 |
| `capacity_scaler` | number | 1.0 | 容量比例（0.0-1.0） |
| `max_utilization` | number | 0.8 | 最大利用率（0.0-1.0） |

#### Balancing Mode 选项

- **UTILIZATION**: 基于 CPU 利用率
- **RATE**: 基于每秒请求数
- **CONNECTION**: 基于连接数

## 使用步骤

### 1. 配置 Instance Groups

首先确保已经配置了 Instance Groups：

```hcl
instance_groups = {
  "algorithm-ew2-a" = {
    name        = "algorithm-ew2-a-ig"
    description = "Instance group for algorithm VMs in europe-west2-a"
    zone        = "europe-west2-a"
    instances   = ["algorithm-ew2-vm1"]
    named_ports = [
      {
        name = "http"
        port = 8080
      }
    ]
  }
}
```

**重要**: Named port 必须包含 `http` 端口，用于 Load Balancer。

### 2. 配置 Load Balancer

在 `terraform.tfvars` 中配置：

```hcl
# Load Balancer 基础配置
lb_name                  = "ortb-lb"
lb_external_ip_name      = "ortb-lb-external-ip"
lb_forwarding_rule_name  = "ortb-lb-forwarding-rule"
lb_backend_service_name  = "ortb-global-backend"
lb_health_check_name     = "ortb-health-check"

# Backend 配置
lb_backends = {
  "backend-ew2-a" = {
    instance_group_key = "algorithm-ew2-a-ig"
    balancing_mode     = "UTILIZATION"
    capacity_scaler    = 1.0
    max_utilization    = 0.8
  }
}
```

### 3. 应用配置

```bash
# 验证配置
terraform validate

# 查看执行计划
terraform plan

# 应用配置
terraform apply
```

### 4. 查看输出信息

```bash
# 查看 Load Balancer 信息
terraform output load_balancer_info

# 查看 Backend 信息
terraform output load_balancer_backends
```

## 输出信息

### load_balancer_info

```json
{
  "name": "ortb-lb",
  "external_ip": "34.120.45.67",
  "forwarding_rule": "ortb-lb-forwarding-rule",
  "backend_service": "ortb-global-backend",
  "health_check": "ortb-health-check",
  "url_map": "ortb-lb-url-map",
  "http_proxy": "ortb-lb-http-proxy",
  "access_url": "http://34.120.45.67"
}
```

### load_balancer_backends

```json
{
  "backend-ew2-a": {
    "instance_group": "algorithm-ew2-a",
    "instance_group_link": "https://www.googleapis.com/compute/v1/projects/...",
    "balancing_mode": "UTILIZATION",
    "capacity_scaler": 1.0
  }
}
```

## 测试 Load Balancer

### 1. 获取外部 IP

```bash
terraform output -json load_balancer_info | jq -r '.access_url'
```

### 2. 测试访问

```bash
# 获取 LB IP
LB_IP=$(terraform output -json load_balancer_info | jq -r '.external_ip')

# 测试 HTTP 访问
curl http://$LB_IP

# 测试多次请求（验证负载均衡）
for i in {1..10}; do
  curl -s http://$LB_IP
  echo ""
done
```

### 3. 检查 Health Check 状态

```bash
# 使用 gcloud 命令
gcloud compute backend-services get-health ortb-global-backend --global
```

## 添加新的 Backend

### 步骤 1: 创建新的 Instance Group

```hcl
instance_groups = {
  # 现有的 Instance Group
  "algorithm-ew2-a" = { ... }
  
  # 新增的 Instance Group
  "algorithm-uc1-a" = {
    name        = "algorithm-uc1-a-ig"
    description = "Instance group in us-central1-a"
    zone        = "us-central1-a"
    instances   = ["algorithm-uc1-vm1"]
    named_ports = [
      {
        name = "http"
        port = 8080
      }
    ]
  }
}
```

### 步骤 2: 添加到 Load Balancer Backends

```hcl
lb_backends = {
  "backend-ew2-a" = {
    instance_group_key = "algorithm-ew2-a-ig"
    balancing_mode     = "UTILIZATION"
    capacity_scaler    = 1.0
    max_utilization    = 0.8
  }
  # 新增 Backend
  "backend-uc1-a" = {
    instance_group_key = "algorithm-uc1-a-ig"
    balancing_mode     = "UTILIZATION"
    capacity_scaler    = 1.0
    max_utilization    = 0.8
  }
}
```

### 步骤 3: 应用配置

```bash
terraform plan
terraform apply
```

## 监控和维护

### 查看 Load Balancer 状态

```bash
# 查看 Forwarding Rule
gcloud compute forwarding-rules describe ortb-lb-forwarding-rule --global

# 查看 Backend Service
gcloud compute backend-services describe ortb-global-backend --global

# 查看 Health Check
gcloud compute health-checks describe ortb-health-check
```

### 查看流量分布

```bash
# 在 GCP Console 中查看
# Monitoring > Dashboards > Load Balancing
```

### 调整 Backend 权重

修改 `capacity_scaler` 值来调整流量分配：

```hcl
lb_backends = {
  "backend-ew2-a" = {
    instance_group_key = "algorithm-ew2-a-ig"
    capacity_scaler    = 1.0  # 100% 容量
  }
  "backend-uc1-a" = {
    instance_group_key = "algorithm-uc1-a-ig"
    capacity_scaler    = 0.5  # 50% 容量
  }
}
```

## 故障排查

### 1. Health Check 失败

**症状**: Backend 显示为 Unhealthy

**检查步骤**:

```bash
# 1. 检查 Health Check 配置
gcloud compute health-checks describe ortb-health-check

# 2. 检查防火墙规则（允许 Health Check 探测）
# Health Check 源 IP: 35.191.0.0/16, 130.211.0.0/22

# 3. 检查实例是否在监听 8080 端口
gcloud compute ssh INSTANCE_NAME --zone=ZONE -- "netstat -tlnp | grep 8080"
```

**解决方案**:

添加防火墙规则允许 Health Check：

```hcl
firewall_rules = {
  "allow-health-check" = {
    name          = "allow-health-check"
    description   = "Allow health check probes"
    priority      = 1000
    source_ranges = ["35.191.0.0/16", "130.211.0.0/22"]
    target_tags   = ["algorithm"]
    allow = [
      {
        protocol = "tcp"
        ports    = ["8080"]
      }
    ]
  }
}
```

### 2. 无法访问 Load Balancer

**症状**: 访问 LB IP 超时或拒绝连接

**检查步骤**:

```bash
# 1. 检查 Forwarding Rule
gcloud compute forwarding-rules describe ortb-lb-forwarding-rule --global

# 2. 检查 Backend Service
gcloud compute backend-services get-health ortb-global-backend --global

# 3. 测试直接访问 Instance
curl http://INSTANCE_EXTERNAL_IP:8080
```

### 3. 流量分配不均

**症状**: 某些 Backend 接收的流量过多或过少

**检查步骤**:

```bash
# 查看 Backend 配置
terraform state show google_compute_backend_service.global_backend
```

**解决方案**:

调整 `capacity_scaler` 和 `max_utilization` 参数。

### 4. Consistent Hash 配置错误

**错误信息**:
```
Error: ConsistentHash can be set only if the Locality Lb policy is set to MAGLEV or RING_HASH.
```

**原因**:
使用 `consistent_hash` 必须同时设置 `locality_lb_policy` 为 `RING_HASH` 或 `MAGLEV`。

**解决方案**:

已在 `load_balancer.tf` 中添加：

```hcl
resource "google_compute_backend_service" "global_backend" {
  # ...
  session_affinity = "CLIENT_IP"
  
  # 必须设置 locality_lb_policy
  locality_lb_policy = "RING_HASH"
  
  # 然后才能使用 consistent_hash
  consistent_hash {
    minimum_ring_size = 1024
  }
}
```

**Locality LB Policy 选项**:
- `ROUND_ROBIN` - 轮询（默认）
- `LEAST_REQUEST` - 最少请求
- `RING_HASH` - 环形哈希（支持 consistent_hash）
- `RANDOM` - 随机
- `ORIGINAL_DESTINATION` - 原始目标
- `MAGLEV` - Maglev 哈希（支持 consistent_hash）

### 5. Forwarding Rule IP 配置错误

**错误信息**:
```
Error: IP Version and IP Address cannot be specified at the same time.
```

**原因**:
在 `google_compute_global_forwarding_rule` 中不能同时指定 `ip_version` 和 `ip_address`。

**解决方案**:

移除 `ip_version` 字段，IP 版本会从 `ip_address` 自动推断：

```hcl
resource "google_compute_global_forwarding_rule" "lb_forwarding_rule" {
  name                  = var.lb_forwarding_rule_name
  target                = google_compute_target_http_proxy.lb_http_proxy.id
  port_range            = "80"
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  ip_address            = google_compute_global_address.lb_external_ip.address
  
  # ❌ 不要同时指定 ip_version
  # ip_version = "IPV4"  # 会自动从 ip_address 推断
}
```

## 高级配置

### 启用 HTTPS

如果需要 HTTPS，需要额外配置：

1. 创建 SSL 证书
2. 创建 HTTPS Target Proxy
3. 修改 Forwarding Rule 端口为 443

### 启用 Cloud CDN

修改 `load_balancer.tf`:

```hcl
resource "google_compute_backend_service" "global_backend" {
  # ...
  enable_cdn = true
  
  cdn_policy {
    cache_mode        = "CACHE_ALL_STATIC"
    default_ttl       = 3600
    max_ttl           = 86400
    client_ttl        = 3600
    negative_caching  = true
  }
}
```

### 启用 Logging

修改 `load_balancer.tf`:

```hcl
resource "google_compute_backend_service" "global_backend" {
  # ...
  log_config {
    enable      = true
    sample_rate = 1.0  # 100% 采样
  }
}
```

## 成本优化

### 1. 使用 Preemptible VMs

在 Backend Instance Groups 中使用抢占式实例降低成本。

### 2. 调整 Health Check 频率

```hcl
resource "google_compute_health_check" "backend_health_check" {
  # ...
  check_interval_sec = 10  # 增加间隔（默认 5 秒）
}
```

### 3. 优化 Session Affinity

根据应用需求选择合适的 Session Affinity 策略。

## 最佳实践

1. **多区域部署**: 在多个区域部署 Instance Groups 提高可用性
2. **Health Check 配置**: 合理设置健康检查参数，避免误判
3. **监控告警**: 配置 Cloud Monitoring 告警
4. **容量规划**: 根据流量预估合理设置 `max_utilization`
5. **安全配置**: 使用 Cloud Armor 保护应用（如需要）
6. **日志分析**: 启用日志用于故障排查和性能分析

## 相关资源

- [GCP Load Balancing 文档](https://cloud.google.com/load-balancing/docs)
- [Application Load Balancer 概述](https://cloud.google.com/load-balancing/docs/application-load-balancer)
- [Health Check 最佳实践](https://cloud.google.com/load-balancing/docs/health-check-concepts)
- [Backend Service 配置](https://cloud.google.com/load-balancing/docs/backend-service)

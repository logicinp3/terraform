# GCP IAM Service Account Configuration

# 创建 Service Account
resource "google_service_account" "service_accounts" {
  for_each = var.service_accounts

  account_id   = each.value.account_id
  display_name = each.value.display_name
  description  = each.value.description
  project      = var.project_id
}

# 为 Service Account 分配项目级别的 IAM 角色
resource "google_project_iam_member" "service_account_roles" {
  for_each = {
    for pair in flatten([
      for sa_key, sa in var.service_accounts : [
        for role in sa.roles : {
          sa_key = sa_key
          role   = role
          key    = "${sa_key}-${role}"
        }
      ]
    ]) : pair.key => pair
  }

  project = var.project_id
  role    = each.value.role
  member  = "serviceAccount:${google_service_account.service_accounts[each.value.sa_key].email}"
}

# 创建 Service Account Key（JSON 格式）
resource "google_service_account_key" "service_account_keys" {
  for_each = {
    for key, sa in var.service_accounts : key => sa
    if sa.create_key == true
  }

  service_account_id = google_service_account.service_accounts[each.key].name

  # Key 算法
  key_algorithm = "KEY_ALG_RSA_2048"

  # 私钥类型：JSON 格式
  private_key_type = "TYPE_GOOGLE_CREDENTIALS_FILE"
}

# 将 Service Account Key 保存到本地文件
resource "local_file" "service_account_key_files" {
  for_each = {
    for key, sa in var.service_accounts : key => sa
    if sa.create_key == true && sa.save_key_to_file == true
  }

  content  = base64decode(google_service_account_key.service_account_keys[each.key].private_key)
  filename = "${path.module}/keys/${var.service_accounts[each.key].account_id}-key.json"

  # 设置文件权限（仅所有者可读写）
  file_permission = "0600"
}

# 输出 Service Account 信息
output "service_accounts_info" {
  value = {
    for key, sa in google_service_account.service_accounts : key => {
      account_id   = sa.account_id
      email        = sa.email
      display_name = sa.display_name
      unique_id    = sa.unique_id
      roles        = var.service_accounts[key].roles
      key_created  = var.service_accounts[key].create_key
      key_file     = var.service_accounts[key].create_key && var.service_accounts[key].save_key_to_file ? "${path.module}/keys/${sa.account_id}-key.json" : null
    }
  }
  description = "Service Accounts information"
}

# 输出 Service Account Key（敏感信息）
output "service_account_keys_json" {
  value = {
    for key, sa_key in google_service_account_key.service_account_keys : key => {
      private_key_json = base64decode(sa_key.private_key)
    }
  }
  description = "Service Account Keys in JSON format (sensitive)"
  sensitive   = true
}

# 输出 Service Account Key 的 base64 编码（敏感信息）
output "service_account_keys_base64" {
  value = {
    for key, sa_key in google_service_account_key.service_account_keys : key => {
      private_key_base64 = sa_key.private_key
    }
  }
  description = "Service Account Keys in base64 format (sensitive)"
  sensitive   = true
}

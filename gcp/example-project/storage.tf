# GCP Cloud Storage Bucket Configuration

# 创建 GCS Bucket
resource "google_storage_bucket" "buckets" {
  for_each = var.gcs_buckets

  name          = each.value.name
  location      = each.value.location
  storage_class = each.value.storage_class

  # Public access prevention: enforced / inherited / null
  public_access_prevention = each.value.prevention_rule

  # Access control: Uniform
  uniform_bucket_level_access = true

  # Soft delete policy - Use default retention duration (7 days)
  soft_delete_policy {
    retention_duration_seconds = 604800 # 7 days = 7 * 24 * 60 * 60
  }

  # 数据加密：Google-managed encryption key (默认)
  # 不需要显式配置，默认就是 Google-managed

  # 版本控制（可选）
  versioning {
    enabled = each.value.versioning_enabled
  }

  # 生命周期规则（可选）
  dynamic "lifecycle_rule" {
    for_each = each.value.lifecycle_rules != null ? each.value.lifecycle_rules : []
    content {
      action {
        type          = lifecycle_rule.value.action.type
        storage_class = lookup(lifecycle_rule.value.action, "storage_class", null)
      }
      condition {
        age                   = lookup(lifecycle_rule.value.condition, "age", null)
        created_before        = lookup(lifecycle_rule.value.condition, "created_before", null)
        with_state            = lookup(lifecycle_rule.value.condition, "with_state", null)
        matches_storage_class = lookup(lifecycle_rule.value.condition, "matches_storage_class", null)
        num_newer_versions    = lookup(lifecycle_rule.value.condition, "num_newer_versions", null)
      }
    }
  }

  # 标签
  labels = each.value.labels

  # 防止意外删除
  lifecycle {
    prevent_destroy = false # 设置为 true 可以防止意外删除
  }
}

# 输出 Bucket 信息
output "gcs_buckets_info" {
  value = {
    for key, bucket in google_storage_bucket.buckets : key => {
      name                     = bucket.name
      url                      = bucket.url
      self_link                = bucket.self_link
      location                 = bucket.location
      storage_class            = bucket.storage_class
      public_access_prevention = bucket.public_access_prevention
      uniform_access           = bucket.uniform_bucket_level_access
      soft_delete_retention    = bucket.soft_delete_policy[0]
    }
  }
  description = "GCS Buckets information"
}

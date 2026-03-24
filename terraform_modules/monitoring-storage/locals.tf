#--------------------------------------------------------------
# Local Values
#--------------------------------------------------------------
locals {
  storage_accounts = var.storage_accounts != null && length(var.storage_accounts) > 0 ? {
    for k, v in var.storage_accounts : k => try(v.name, "${var.project_name}${k}")
    } : {
    "vpnglog"      = "${var.project_name}vpnglog"
    "kvlog"        = "${var.project_name}kvlog"
    "nsglog"       = "${var.project_name}nsglog"
    "vnetlog"      = "${var.project_name}vnetlog"
    "vmlog"        = "${var.project_name}vmlog"
    "stgstlog"     = "${var.project_name}stgstlog"
    "aoailog"      = "${var.project_name}aoailog"
    "apimlog"      = "${var.project_name}apimlog"
    "aifoundrylog" = "${var.project_name}aiflog"
    "acrlog"       = "${var.project_name}acrlog"
    "spkvlog"      = "${var.project_name}spkvlog"
  }

  common_tags = merge(
    var.tags,
    {
      Service     = "Storage"
      Purpose     = "Monitoring"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )

  key_vault_name = var.enable_key_vault ? "${var.key_vault_name}${random_string.storage_suffix.result}" : null
}

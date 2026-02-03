# log-analytics-workspace

Log Analytics Workspace 1개를 생성하는 공통 모듈입니다.

## 입력 변수

| 변수 | 필수 | 설명 |
|------|------|------|
| name | O | Workspace 이름 (4~63자) |
| location | O | Azure 리전 |
| resource_group_name | O | 리소스 그룹 이름 |
| retention_in_days | X | 보존 기간(일), 기본 30 |
| tags | X | 태그 |

## 출력

| 출력 | 설명 |
|------|------|
| id | Workspace 리소스 ID |
| name | Workspace 이름 |
| workspace_id | Customer ID (쿼리 등에서 사용) |

## 사용 예 (terraform-iac)

```hcl
module "log_analytics_workspace" {
  source = "git::https://github.com/kimchibee/terraform-modules.git//terraform_modules/log-analytics-workspace?ref=main"

  name                = local.hub_log_analytics_name
  location             = var.location
  resource_group_name  = module.hub_vnet.resource_group_name
  retention_in_days    = var.log_analytics_retention_days
  tags                 = var.tags
}
```

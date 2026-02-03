# Spoke VNet Module

Azure Hub-Spoke 아키텍처의 **Spoke Virtual Network**를 생성하는 공통 모듈입니다.

## 기능

- Virtual Network 생성
- Subnets 생성
- Network Security Groups (Private Endpoint용, 선택사항)
- VNet Peering to Hub (선택사항)
- Private DNS Zone Links (선택사항)

## 사용 예시

```hcl
module "spoke_vnet" {
  source = "git::https://github.com/kimchibee/terraform-modules.git//terraform_modules/spoke-vnet?ref=main"

  providers = {
    azurerm = azurerm.spoke
  }

  project_name = "myproject"
  environment  = "dev"
  location     = "Korea Central"
  tags         = {}

  resource_group_name = "myproject-dev-spoke-rg"
  vnet_name           = "myproject-dev-spoke-vnet"
  vnet_address_space  = ["10.1.0.0/16"]
  
  subnets = {
    "apim-snet" = {
      address_prefixes = ["10.1.0.0/24"]
    }
    "pep-snet" = {
      address_prefixes = ["10.1.1.0/24"]
    }
  }

  # Hub VNet Peering (Optional)
  enable_hub_peering     = true
  hub_vnet_id            = module.hub_vnet.vnet_id
  hub_resource_group_name = module.hub_vnet.resource_group_name

  # Private DNS Zone Links (Optional)
  enable_private_dns_links = true
  private_dns_zone_ids = {
    "blob" = "/subscriptions/.../privatelink.blob.core.windows.net"
  }

  # NSG for Private Endpoint (Optional)
  enable_pep_nsg = true
  pep_subnet_name = "pep-snet"
}
```

## 입력 변수

| 변수명 | 설명 | 타입 | 필수 | 기본값 |
|--------|------|------|------|--------|
| `project_name` | 프로젝트 이름 접두사 | `string` | ✅ | - |
| `environment` | 환경 이름 (dev, prod 등) | `string` | ✅ | - |
| `location` | Azure 리전 | `string` | ✅ | - |
| `resource_group_name` | Resource Group 이름 | `string` | ✅ | - |
| `vnet_name` | VNet 이름 | `string` | ✅ | - |
| `vnet_address_space` | VNet 주소 공간 | `list(string)` | ✅ | - |
| `subnets` | Subnet 설정 | `map(object)` | ✅ | - |
| `enable_hub_peering` | Hub VNet Peering 활성화 | `bool` | ❌ | `false` |
| `hub_vnet_id` | Hub VNet ID | `string` | ❌ | `""` |
| `enable_private_dns_links` | Private DNS Zone Links 활성화 | `bool` | ❌ | `false` |
| `private_dns_zone_ids` | Private DNS Zone ID 맵 | `map(string)` | ❌ | `{}` |
| `enable_pep_nsg` | Private Endpoint NSG 활성화 | `bool` | ❌ | `false` |

## 출력 값

| 출력명 | 설명 |
|--------|------|
| `resource_group_name` | Resource Group 이름 |
| `resource_group_id` | Resource Group ID |
| `vnet_id` | VNet ID |
| `vnet_name` | VNet 이름 |
| `subnet_ids` | Subnet ID 맵 |
| `nsg_pep_id` | Private Endpoint NSG ID |
| `vnet_peering_id` | VNet Peering ID |

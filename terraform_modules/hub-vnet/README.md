# Hub VNet Module

Azure Hub-Spoke 아키텍처의 **Hub Virtual Network**를 생성하는 공통 모듈입니다.

## 기능

- Virtual Network 생성
- Subnets 생성
- VPN Gateway (온프레미스 연결)
- DNS Private Resolver
- Private DNS Zones (Storage, Key Vault, OpenAI, APIM, AI Foundry 등)
- Network Security Groups (Monitoring VM, Private Endpoint용)

## 사용 예시

```hcl
module "hub_vnet" {
  source = "git::https://github.com/kimchibee/terraform-modules.git//terraform_modules/hub-vnet?ref=main"

  providers = {
    azurerm = azurerm.hub
  }

  project_name = "myproject"
  environment  = "dev"
  location     = "Korea Central"
  tags         = {}

  resource_group_name = "myproject-dev-rg"
  vnet_name           = "myproject-dev-hub-vnet"
  vnet_address_space  = ["10.0.0.0/16"]
  
  subnets = {
    "GatewaySubnet" = {
      address_prefixes = ["10.0.0.0/24"]
    }
    "Monitoring-VM-Subnet" = {
      address_prefixes = ["10.0.1.0/24"]
    }
    "pep-snet" = {
      address_prefixes = ["10.0.2.0/24"]
    }
  }

  # VPN Gateway (Optional)
  vpn_gateway_name      = "myproject-dev-vpng"
  vpn_gateway_sku       = "VpnGw1"
  vpn_gateway_type      = "Vpn"
  local_gateway_configs = []
  vpn_shared_key        = ""

  # DNS Private Resolver (Optional)
  dns_resolver_name = "myproject-dev-dns-resolver"
  enable_dns_forwarding_ruleset = true
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
| `vpn_gateway_name` | VPN Gateway 이름 | `string` | ❌ | - |
| `vpn_gateway_sku` | VPN Gateway SKU | `string` | ❌ | - |
| `dns_resolver_name` | DNS Private Resolver 이름 | `string` | ❌ | - |
| `enable_dns_forwarding_ruleset` | DNS Forwarding Ruleset 활성화 | `bool` | ❌ | `true` |

## 출력 값

| 출력명 | 설명 |
|--------|------|
| `resource_group_name` | Resource Group 이름 |
| `resource_group_id` | Resource Group ID |
| `vnet_id` | VNet ID |
| `vnet_name` | VNet 이름 |
| `subnet_ids` | Subnet ID 맵 |
| `vpn_gateway_id` | VPN Gateway ID |
| `dns_resolver_id` | DNS Private Resolver ID |
| `private_dns_zone_ids` | Private DNS Zone ID 맵 |
| `nsg_monitoring_vm_id` | Monitoring VM NSG ID |
| `nsg_pep_id` | Private Endpoint NSG ID |

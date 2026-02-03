# vnet-peering

VNet Peering 한 방향 1개를 생성하는 공통 모듈입니다. 양방향 Peering은 이 모듈을 각 VNet에서 한 번씩 호출하면 됩니다.

## 입력 변수

| 변수 | 필수 | 설명 |
|------|------|------|
| name | O | Peering 이름 (로컬 VNet 쪽) |
| resource_group_name | O | 로컬 VNet의 리소스 그룹 |
| virtual_network_name | O | 로컬 VNet 이름 |
| remote_virtual_network_id | O | 원격 VNet 리소스 ID |
| allow_virtual_network_access | X | 기본 true |
| allow_forwarded_traffic | X | 기본 false |
| allow_gateway_transit | X | 기본 false |
| use_remote_gateways | X | 기본 false |

## 출력

| 출력 | 설명 |
|------|------|
| id | Peering 리소스 ID |
| name | Peering 이름 |

## 사용 예 (terraform-iac, Hub → Spoke)

```hcl
module "vnet_peering_hub_to_spoke" {
  source = "git::https://github.com/kimchibee/terraform-modules.git//terraform_modules/vnet-peering?ref=main"

  name                         = "${module.hub_vnet.vnet_name}-to-spoke"
  resource_group_name          = module.hub_vnet.resource_group_name
  virtual_network_name         = module.hub_vnet.vnet_name
  remote_virtual_network_id    = module.spoke_vnet.vnet_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
  use_remote_gateways          = false
}
```

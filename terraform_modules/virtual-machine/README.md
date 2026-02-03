# virtual-machine

Linux/Windows VM 1대 + NIC + (선택) 확장을 생성하는 공통 모듈입니다.

## 입력 변수

| 변수 | 필수 | 설명 |
|------|------|------|
| name | O | VM 이름 |
| os_type | X | linux / windows, 기본 linux |
| size | O | VM SKU (예: Standard_B2s) |
| location | O | Azure 리전 |
| resource_group_name | O | 리소스 그룹 이름 |
| subnet_id | O | NIC 연결 서브넷 ID |
| admin_username | O | 관리자 사용자명 |
| admin_password | X | 관리자 비밀번호 (windows 필수, linux 시 비밀번호 인증) |
| admin_ssh_public_key | X | Linux SSH 공개키 (비어 있으면 비밀번호 인증만 사용) |
| tags | X | 태그 |
| enable_identity | X | 시스템 할당 Managed Identity, 기본 false |
| vm_extensions | X | VM 확장 목록 |

## 출력

| 출력 | 설명 |
|------|------|
| id | VM 리소스 ID |
| identity_principal_id | Managed Identity Principal ID |
| vm_private_ip | NIC Private IP |
| network_interface_id | NIC ID |

## 사용 예 (terraform-iac)

```hcl
module "monitoring_vm" {
  source = "git::https://github.com/kimchibee/terraform-modules.git//terraform_modules/virtual-machine?ref=main"

  name                = local.hub_vm_name
  os_type             = "linux"
  size                = var.vm_size
  location             = var.location
  resource_group_name  = module.hub_vnet.resource_group_name
  subnet_id            = module.hub_vnet.subnet_ids["Monitoring-VM-Subnet"]
  admin_username       = var.vm_admin_username
  admin_password       = var.vm_admin_password
  tags                 = var.tags
  enable_identity      = true
  vm_extensions = [ ... ]
}
```

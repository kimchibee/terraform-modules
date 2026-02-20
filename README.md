# Terraform Modules (공통 모듈)

Azure 인프라용 **재사용 가능한 Terraform 모듈** 라이브러리입니다.  
**이 레포에는 공통 모듈만** 있으며, 직접 `terraform apply` 하지 않고 **[terraform-iac](https://github.com/kimchibee/terraform-iac)** 등 IaC 레포에서 `source = "git::..."` 로 참조해 사용합니다.

---

## 사용자 환경 (이 레포를 다룰 때)

| 구분 | 내용 |
|------|------|
| **역할** | 이 저장소는 **모듈 라이브러리**입니다. 여기서 `terraform apply`를 실행하지 않습니다. |
| **Terraform** | 모듈 중 AVM(공식) 래퍼를 쓰는 것이 있어 **1.9 이상** 권장. [terraform-iac](https://github.com/kimchibee/terraform-iac)에서 실행 시 그쪽 Terraform 버전을 따릅니다. |
| **실제 사용처** | **[terraform-iac](https://github.com/kimchibee/terraform-iac)** 저장소의 `main.tf` 등에서 `source = "git::https://github.com/kimchibee/terraform-modules.git//terraform_modules/모듈명?ref=main"` 으로 참조. |
| **로컬에서 할 일** | 모듈 코드 수정·추가 후 **커밋·푸시**. terraform-iac에서 `terraform init -upgrade` 시 새 코드를 가져옵니다. `test/` 디렉터리로 로컬 init/validate 테스트 가능(선택). |

**정리:** 이 레포는 “부품(모듈)”만 제공합니다. 배포는 **terraform-iac**에서 스택 단위로 실행합니다.

---

## 이 저장소는 어떻게 구성되어 있는가

- **구성**  
  `terraform_modules/` 아래에 **모듈별 폴더**(hub-vnet, spoke-vnet, key-vault, log-analytics-workspace 등)가 있습니다. 각 폴더에는 `main.tf`, `variables.tf`, `outputs.tf`, `versions.tf` 등이 들어 있습니다.

- **terraform-iac와의 관계**  
  - **terraform-iac**: 스택별 디렉터리에서 `terraform init / plan / apply` 실행. Backend·Provider·변수 파일을 갖고, **여기(terraform-modules)의 모듈을 Git 주소로 불러와서** 사용.
  - **terraform-modules (이 레포)**: 공통 모듈만 보유. `apply` 대상이 아님. terraform-iac이 `git::https://github.com/kimchibee/terraform-modules.git//terraform_modules/모듈명?ref=main` 형태로 참조.

- **버전**  
  Git 브랜치·태그로 버전 관리. terraform-iac에서는 `?ref=main` 또는 `?ref=v1.0.0` 처럼 지정해 사용합니다.

- **모듈 종류**  
  일부는 Azure 공식(AVM) 모듈을 감싼 **래퍼**(key-vault, resource-group, log-analytics-workspace, private-endpoint). 나머지는 azurerm 리소스를 직접 쓴 모듈(hub-vnet, spoke-vnet, virtual-machine 등)입니다. 자세한 목록은 아래 "사용 가능한 모듈 목록" 참고.

---

## 이 레포에서 관리하는 것

| 구분 | 내용 |
|------|------|
| **모듈 위치** | `terraform_modules/` — 모든 공통 모듈이 이 디렉터리 아래에 있음. |
| **버전** | Git 브랜치·태그 기반. IaC에서는 `?ref=main` 또는 `?ref=v1.0.0` 등으로 참조. |
| **역할** | 단일 책임, 환경 무관, 라이브러리 전용. |

---

## 참조 방법 (terraform-iac 등에서)

**공통 모듈 참조는 IaC 레포의 `main.tf`에만 있습니다.**

- **형식**: `source = "git::https://github.com/kimchibee/terraform-modules.git//terraform_modules/모듈명?ref=main"`
- **태그 사용 시**: `?ref=main` 대신 `?ref=v1.0.0` 등으로 지정.

---

## 공식 모듈(AVM) 사용 현황

| 모듈 | 구현 방식 | 비고 |
|------|-----------|------|
| `key-vault` | **AVM 래퍼** | Azure/avm-res-keyvault-vault/azurerm |
| `resource-group` | **AVM 래퍼** | Azure/avm-res-resources-resourcegroup/azurerm |
| `log-analytics-workspace` | **AVM 래퍼** | Azure/avm-res-operationalinsights-workspace/azurerm |
| `hub-vnet`, `spoke-vnet`, `vnet`, `vnet-peering` | azurerm 인라인 | VPN/DNS/NSG/피어링 등 호환 인터페이스 유지 |
| `private-endpoint` | **AVM 래퍼** | Azure/avm-res-network-privateendpoint/azurerm |
| `virtual-machine`, `storage-account` | azurerm 인라인 | terraform-iac와 동일 변수/출력 유지 |

---

## 사용 가능한 모듈 목록

### 네트워킹

| 모듈명 | 설명 | 사용 예 |
|--------|------|---------|
| `hub-vnet` | Hub VNet (VPN Gateway, DNS Resolver, Private DNS Zones 포함) | Hub-Spoke 아키텍처의 Hub 네트워크 |
| `spoke-vnet` | Spoke VNet (VNet Peering 포함) | Hub-Spoke 아키텍처의 Spoke 네트워크 |
| `vnet` | 단순 VNet (서브넷만 포함) | 기본 VNet이 필요한 경우 |
| `vnet-peering` | VNet Peering | VNet 간 연결 |

### 컴퓨팅

| 모듈명 | 설명 | 사용 예 |
|--------|------|---------|
| `virtual-machine` | Linux/Windows Virtual Machine | VM 인스턴스 생성 |

### 스토리지

| 모듈명 | 설명 | 사용 예 |
|--------|------|---------|
| `storage-account` | Storage Account | 로그 저장, 데이터 저장 |
| `key-vault` | Key Vault | 시크릿/키 관리 |

### 모니터링 및 관리

| 모듈명 | 설명 | 사용 예 |
|--------|------|---------|
| `log-analytics-workspace` | Log Analytics Workspace | 중앙 집중식 로그 수집 및 분석 |

### 네트워크 보안

| 모듈명 | 설명 | 사용 예 |
|--------|------|---------|
| `private-endpoint` | Private Endpoint | Private Link를 통한 서비스 접근 |

### 기본 리소스

| 모듈명 | 설명 | 사용 예 |
|--------|------|---------|
| `resource-group` | Resource Group | 리소스 그룹 생성 |

---

## 디렉터리 구조

```
terraform-modules/
├── README.md
├── .gitignore
├── test/                      # 로컬 init/validate 테스트용
└── terraform_modules/
    ├── hub-vnet/              # Hub VNet (VPN Gateway, DNS Resolver 포함)
    ├── spoke-vnet/            # Spoke VNet (VNet Peering 포함)
    ├── vnet/                  # 단순 VNet
    ├── vnet-peering/          # VNet Peering
    ├── virtual-machine/       # Virtual Machine
    ├── log-analytics-workspace/  # Log Analytics Workspace (AVM 래퍼)
    ├── storage-account/       # Storage Account
    ├── key-vault/             # Key Vault (AVM 래퍼)
    ├── private-endpoint/      # Private Endpoint (AVM 래퍼)
    ├── resource-group/        # Resource Group (AVM 래퍼)
    └── ...
```

각 하위 모듈에는 `main.tf`, `variables.tf`, `outputs.tf`, `versions.tf` 등이 포함됩니다.

---

## terraform-iac와의 관계

- **terraform-iac**: 루트 모듈, Provider/Backend, **IaC 전용 모듈**(`modules/dev/hub`, `modules/dev/spoke`) 보유. 배포는 terraform-iac 루트에서 실행.
- **terraform-modules (이 레포)**: 공통 모듈만 보유. terraform-iac의 `main.tf`에서 `git::...terraform-modules.git//terraform_modules/모듈명?ref=...` 로 참조.

공통 모듈을 추가·수정할 때는 **이 레포(terraform-modules)** 만 변경하고, IaC 레포에서는 `source` 의 `ref=` 만 필요 시 변경하면 됩니다.

---

## 사용 예시

### Hub VNet 사용

```hcl
module "hub_vnet" {
  source = "git::https://github.com/kimchibee/terraform-modules.git//terraform_modules/hub-vnet?ref=main"

  project_name = var.project_name
  environment  = var.environment
  location     = var.location
  resource_group_name = local.hub_resource_group_name
  vnet_name    = local.hub_vnet_name
  vnet_address_space = var.hub_vnet_address_space
  subnets      = var.hub_subnets
  
  # VPN Gateway
  vpn_gateway_name = local.vpn_gateway_name
  vpn_gateway_sku  = var.vpn_gateway_sku
  
  # DNS Resolver
  dns_resolver_name = local.dns_resolver_name
  
  tags = var.tags
}
```

### Virtual Machine 사용

```hcl
module "monitoring_vm" {
  source = "git::https://github.com/kimchibee/terraform-modules.git//terraform_modules/virtual-machine?ref=main"

  project_name = var.project_name
  environment  = var.environment
  location     = var.location
  resource_group_name = var.resource_group_name
  
  vm_name      = "monitoring-vm"
  vm_size      = "Standard_B2s"
  admin_username = var.vm_admin_username
  admin_password = var.vm_admin_password
  
  subnet_id    = var.monitoring_vm_subnet_id
  
  tags = var.tags
}
```

---

## 버전(태그) 사용 (선택)

태그를 배포하면 IaC에서 고정 버전으로 참조할 수 있습니다.

```bash
git tag v1.0.0
git push origin v1.0.0
```

IaC의 `main.tf` 예: `source = "git::...//terraform_modules/hub-vnet?ref=v1.0.0"`

버전은 Git 태그로 관리하며, IaC에서는 `?ref=main` 또는 `?ref=v1.0.0` 등으로 참조합니다.

---

## 모듈 추가/수정 가이드

새로운 공통 모듈을 추가하거나 기존 모듈을 수정할 때는 다음 원칙을 따릅니다:

1. **단일 책임 원칙**: 각 모듈은 하나의 리소스 타입만 관리
2. **환경 무관**: dev/stage/prod 구분 없이 재사용 가능
3. **명확한 입력/출력**: `variables.tf`와 `outputs.tf`에 명확한 설명 포함
4. **문서화**: 입력/출력은 `variables.tf`, `outputs.tf`에 설명 포함

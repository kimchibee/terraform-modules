# Terraform Modules

Azure 인프라용 **재사용 가능한 Terraform 공용 모듈** 저장소입니다.  
이 저장소는 모듈 계약(contract)만 관리하며, 실제 `terraform apply`는 **[terraform-iac](https://github.com/kimchibee/terraform-iac)** 리프 스택에서 수행합니다.

## 운영 원칙

- 공용 모듈은 **리소스 단위**로 유지합니다.
- 표준은 **AVM-only** 입니다.
- 환경/토폴로지/워크로드를 한 번에 묶는 **복합(composite) 모듈 신규 추가는 금지**합니다.
- 배포 오케스트레이션은 모듈이 아니라 `terraform-iac` 리프에서 수행합니다.
- **폐쇄망 동작 보장**: AVM은 [`vendor/`](./vendor/) 하위에 특정 태그로 vendoring되며, wrapper는 `vendor/`만 참조합니다. `terraform init` 시 Terraform Registry나 GitHub로 외부 통신이 발생하지 않습니다.
- **wrapper에 azurerm 직접 호출 금지**: wrapper 코드에는 `resource "azurerm_*"`도 `data "azurerm_*"`도 0건이며, 부모 리소스 정보는 호출자(terraform-iac)가 ID로 주입합니다.

관련 문서:

- [docs/AVM_COVERAGE.md](./docs/AVM_COVERAGE.md)
- [docs/WORK_PLAN_AVM_STRATEGY.md](./docs/WORK_PLAN_AVM_STRATEGY.md)
- [docs/AS_IS_TO_BE_MAPPING.md](./docs/AS_IS_TO_BE_MAPPING.md)
- [docs/NETWORK_AS_IS_TO_BE.md](./docs/NETWORK_AS_IS_TO_BE.md)
- [docs/STRICT_AVM_DEFERRED_MODULES.md](./docs/STRICT_AVM_DEFERRED_MODULES.md)

## 모듈 참조 방식

IaC 리프에서 아래 형식으로 참조합니다.

```hcl
module "hub_vnet" {
  source = "git::https://github.com/kimchibee/terraform-modules.git//terraform_modules/vnet?ref=chore/avm-vendoring-and-id-injection"

  resource_group_id  = data.terraform_remote_state.hub_rg.outputs.resource_group_id
  vnet_name          = local.hub_vnet_name
  vnet_address_space = var.hub_vnet_address_space
  # ...
}
```

- 형식: `git::https://github.com/kimchibee/terraform-modules.git//terraform_modules/<module>?ref=<ref>`
- 루트 스택에서 `provider "azurerm"`를 선언하고 필요 시 alias provider를 자식 모듈에 전달합니다.
- 부모 리소스(VNet, RG, DNS Zone 등)는 wrapper에서 lookup하지 않으므로 호출자가 ID 변수로 주입해야 합니다. 자세한 인자 매핑은 `terraform-iac/README.md`의 "2.5 모듈 호출 규약 (ID 주입)" 섹션을 참고하세요.

## Vendoring (폐쇄망 대응)

이 저장소는 폐쇄망 환경에서 동작해야 하므로, AVM 레포 18개를 [`vendor/`](./vendor/) 하위에 직접 포함합니다. 각 wrapper의 `source`는 `../../vendor/<레포명>-<버전>` 상대경로를 가리킵니다.

- vendor 폴더 목록과 commit SHA: [`vendor/README.md`](./vendor/README.md)
- 재벤더링 절차: 같은 문서의 "재벤더링 절차" 섹션
- vendor 폴더에는 `.git` 디렉터리가 제거되어 있어 서브모듈/원격 fetch가 발생하지 않습니다.

### virtualnetwork AVM 통합

이전에는 `vnet` wrapper가 `avm-res-network-virtualnetwork` 0.7.1을 사용하고, `subnet`/`vnet-peering`은 같은 레포의 0.17.1 서브모듈을 사용해 두 버전이 공존했습니다. vendoring 작업과 함께 **0.17.1로 통일**되었습니다(미배포 시점에 일회성으로 처리). 이에 따른 주요 변경:

- `vnet` wrapper의 `resource_group_name` → `resource_group_id` (AVM `parent_id` 패턴)
- subnets 변환 로직: `delegation` → `delegations`, `service_endpoints` → `service_endpoints_with_location`
- 호출부(terraform-iac)에서 vnet 모듈에 RG ID를 주입해야 함

## Provider와 Module의 차이 (중요)

> **이 저장소의 모든 모듈은 AVM-only 정책을 100% 준수합니다.** `versions.tf`에 `hashicorp/azurerm`이 선언되어 있다고 해서 AVM이 아닌 모듈을 섞어 쓰는 것이 아닙니다. 이 문단은 그 오해를 방지하기 위한 설명입니다.

Terraform에는 **Provider**와 **Module**이라는 서로 다른 계층이 존재합니다.

| 구분 | `hashicorp/azurerm` | Azure Verified Modules (AVM) |
|---|---|---|
| 종류 | Terraform **Provider** (플러그인) | Terraform **Module** (HCL 코드 묶음) |
| 역할 | Azure REST API를 호출해 실제 리소스를 CRUD | `azurerm_*` / `azapi_*` 리소스를 조합한 베스트 프랙티스 래퍼 |
| 배포 주체 | HashiCorp + Microsoft | Microsoft (Azure 공식) |
| 선언 위치 | `required_providers` 블록 | `module "x" { source = ... }` 블록 |

즉, **AVM 모듈 내부에서도 결국 `resource "azurerm_*"`를 호출**하기 때문에, AVM을 사용하더라도 루트 스택과 각 모듈의 `versions.tf`에는 `hashicorp/azurerm` 프로바이더가 반드시 선언되어 있어야 합니다. AVM은 "프로바이더의 대체재"가 아니라 "프로바이더 위에 올라탄 표준 래퍼"입니다.

AVM 공식 스펙([SNFR24](https://azure.github.io/Azure-Verified-Modules/specs/shared/#id-snfr24))에서도 "모듈은 `provider` 블록을 선언하지 않지만 `required_providers`는 반드시 명시해야 한다"고 규정합니다.

### 각 모듈의 `versions.tf`에 선언되는 프로바이더

AVM 모듈이 내부적으로 요구하는 프로바이더이며, 이 저장소가 직접 사용하는 것은 아닙니다.

- `hashicorp/azurerm` — 실제 Azure 리소스 생성 (AVM이 내부에서 호출)
- `azure/azapi` — azurerm이 아직 지원하지 않는 최신 Azure API 피처 호출
- `azure/modtm` — AVM 텔레메트리 (사용량 집계)
- `hashicorp/random` — 고유 이름 생성 등

### `data "azurerm_*"` 블록 — 0건

이전에는 6개 wrapper(`key-vault`, `subnet`, `vnet-peering`, `private-dns-zone`, `private-dns-zone-vnet-link`, `virtual-network-gateway`)가 부모 리소스 참조를 위해 `data "azurerm_*"` 블록을 사용했으나, **모두 제거되었습니다**. 부모 리소스는 호출자(terraform-iac 리프)가 명시적으로 ID 변수로 주입합니다. 이렇게 하면:

- wrapper가 plan-time에 외부 API를 호출하지 않아 폐쇄망에서 안전합니다.
- AVM 0.17.x의 `parent_id` 패턴과 일치합니다.
- 호출자가 어떤 리소스를 참조하는지 코드에서 명시적으로 드러납니다.

### 검증: 이 저장소의 wrapper는 azurerm을 직접 호출하지 않습니다

```bash
# 직접 리소스 생성 0건
grep -r '^resource "azurerm_' terraform_modules/
# (결과 없음)

# 직접 lookup 0건
grep -r '^data "azurerm_' terraform_modules/
# (결과 없음)

# Registry/git URL source 0건 (모두 ../../vendor/* 로 전환)
grep -r 'source\s*=\s*"\(Azure/avm-\|git::https://github.com/Azure\)' terraform_modules/
# (결과 없음)
```

모든 모듈은 `vendor/` 하위의 AVM을 상대경로로 참조하는 wrapper로만 구성되어 있습니다.

## AVM 표준 모듈 목록

- `resource-group`
- `vnet`
- `subnet`
- `storage-account`
- `key-vault`
- `log-analytics-workspace`
- `private-endpoint`
- `private-dns-zone`
- `private-dns-zone-vnet-link`
- `dns-private-resolver`
- `public-ip`
- `virtual-network-gateway`
- `local-network-gateway`
- `virtual-network-gateway-connection`
- `virtual-machine`
- `vnet-peering`
- `firewall-policy`
- `route-table`
- `application-security-group`
- `network-security-group`
- `api-management-service`
- `cognitive-services-account`

## 제거/비권장 모듈

아래 레거시/조합형 모듈은 제거되었거나 신규 사용 금지입니다.

- 레거시 단일 모듈 제거: `dns-private-resolver-inbound-endpoint`, `network-security-rule`, `subnet-network-security-group-association`
- 조합형 모듈 사용 중단: `hub-vnet`, `spoke-vnet`, `spoke-workloads`, `shared-services`, `monitoring-storage`, `subnet-keyvault-sg`, `subnet-vm-access-sg`

## 현재 배포 상태와 문서 위치

- 최신 배포 상태는 `terraform-iac/docs/DEPLOYMENT_DASHBOARD.md`를 기준으로 관리합니다.
- 스택별 배포 절차/의존성은 `terraform-iac/azure/dev/*/README.md`에서 관리합니다.
- 이 저장소(`terraform-modules`)는 모듈 계약 중심 문서만 유지합니다.

## 디렉터리 구조

```text
terraform-modules/
├── README.md
├── docs/
├── vendor/                    # vendoring된 AVM 18개 (폐쇄망 대응)
│   ├── README.md              # vendor 정책, 버전 표, 재벤더링 절차
│   ├── terraform-azurerm-avm-res-network-virtualnetwork-0.17.1/
│   ├── terraform-azurerm-avm-res-keyvault-vault-0.10.2/
│   └── ... (총 18개 AVM)
└── terraform_modules/         # 22개 wrapper (vendor를 상대경로로 호출)
    ├── resource-group/
    ├── vnet/
    ├── application-security-group/
    ├── network-security-group/
    ├── log-analytics-workspace/
    ├── firewall-policy/
    ├── route-table/
    └── ... AVM wrapper modules
```

## 모듈 추가 규칙

1. 모듈은 가능한 한 하나의 Azure 리소스 경계를 가집니다.
2. 재사용되지 않는 조합은 공용 모듈이 아니라 IaC 리프에서 조합합니다.
3. 입력은 환경 무관한 계약(이름/ID/정책) 중심으로 노출합니다.
4. 출력은 다른 리프가 remote state로 소비하기 쉬운 ID/이름 중심으로 유지합니다.
5. Strict AVM 단계에서 비-AVM 모듈을 표준 목록에 추가하지 않습니다.

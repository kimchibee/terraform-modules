# Terraform Modules

Azure 인프라용 **재사용 가능한 Terraform 공용 모듈** 저장소입니다.  
이 저장소는 모듈 계약(contract)만 관리하며, 실제 `terraform apply`는 **[terraform-iac](https://github.com/kimchibee/terraform-iac)** 리프 스택에서 수행합니다.

## 운영 원칙

- 공용 모듈은 **리소스 단위**로 유지합니다.
- 표준은 **AVM-only** 입니다.
- 환경/토폴로지/워크로드를 한 번에 묶는 **복합(composite) 모듈 신규 추가는 금지**합니다.
- 배포 오케스트레이션은 모듈이 아니라 `terraform-iac` 리프에서 수행합니다.

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
  source = "git::https://github.com/kimchibee/terraform-modules.git//terraform_modules/vnet?ref=chore/avm-wave1-modules-prune-and-convert"
  # ...
}
```

- 형식: `git::https://github.com/kimchibee/terraform-modules.git//terraform_modules/<module>?ref=<ref>`
- 루트 스택에서 `provider "azurerm"`를 선언하고 필요 시 alias provider를 자식 모듈에 전달합니다.

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
└── terraform_modules/
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

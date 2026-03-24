# Terraform Modules

Azure 인프라용 **재사용 가능한 Terraform 공용 모듈** 저장소입니다.  
이 저장소에서는 `terraform apply`를 실행하지 않고, **[terraform-iac](https://github.com/kimchibee/terraform-iac)** 같은 IaC 저장소가 Git `source`로만 참조합니다.

## 원칙

- 공용 모듈은 **리소스 단위**로 유지합니다.
- 공용 모듈 표준은 **AVM-only** 입니다.
- AVM-only가 아닌 모듈은 foundation 단계에서 **deferred/out-of-scope** 로 분리합니다.
- 환경명, 토폴로지명, 워크로드명으로 묶인 **복합 모듈은 신규 사용 금지**입니다.

관련 문서:

- [docs/AVM_COVERAGE.md](./docs/AVM_COVERAGE.md)
- [docs/WORK_PLAN_AVM_STRATEGY.md](./docs/WORK_PLAN_AVM_STRATEGY.md)
- [docs/AS_IS_TO_BE_MAPPING.md](./docs/AS_IS_TO_BE_MAPPING.md)
- [docs/NETWORK_AS_IS_TO_BE.md](./docs/NETWORK_AS_IS_TO_BE.md)
- [docs/STRICT_AVM_DEFERRED_MODULES.md](./docs/STRICT_AVM_DEFERRED_MODULES.md)

## 사용 방법

IaC 리프 스택에서 아래 형식으로만 참조합니다.

```hcl
module "hub_vnet" {
  source = "git::https://github.com/kimchibee/terraform-modules.git//terraform_modules/vnet?ref=main"
  # ...
}
```

- 형식: `git::https://github.com/kimchibee/terraform-modules.git//terraform_modules/<module>?ref=<ref>`
- 루트 스택에서 `provider "azurerm"`를 선언하고 자식 모듈로 전달합니다.

## 현재 표준 모듈 (Strict AVM Foundation)

### AVM 래퍼

- `resource-group`
- `vnet`
- `subnet` (AVM submodule)
- `storage-account`
- `key-vault`
- `log-analytics-workspace`
- `private-endpoint`
- `private-dns-zone`
- `private-dns-zone-vnet-link` (AVM submodule)
- `dns-private-resolver`
- `public-ip`
- `virtual-network-gateway` (AVM pattern)
- `local-network-gateway`
- `virtual-network-gateway-connection`
- `virtual-machine`
- `vnet-peering` (AVM submodule)
- `firewall-policy`
- `route-table`
- `application-security-group`
- `network-security-group`

## Removed legacy modules

아래 레거시 단일 모듈은 더 이상 사용하지 않으며 모듈 파일을 제거했습니다.

- `dns-private-resolver-inbound-endpoint`
- `network-security-rule`
- `subnet-network-security-group-association`

## 분해 완료된 조합형 모듈

아래 조합형 모듈은 분해 완료 후 모듈 파일을 제거했습니다.
신규 IaC 리프에서는 반드시 리소스 단위 공용 모듈 조합만 사용합니다.

- `hub-vnet`
- `spoke-vnet`
- `spoke-workloads`
- `shared-services`
- `monitoring-storage`
- `subnet-keyvault-sg`
- `subnet-vm-access-sg`

대체 방향:

- `hub-vnet`, `spoke-vnet` -> `vnet` + `subnet` + NSG/DNS/Resolver/Gateway 관련 리프 조합
- `spoke-workloads` -> 서비스별 리프와 공용 리소스 모듈 조합
- `shared-services` -> `log-analytics-workspace` + shared leaf orchestration
- `monitoring-storage` -> `storage-account`, `private-endpoint`, `key-vault` 조합

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
    ├── ... AVM wrapper modules
    └── ... removed legacy modules
```

## 모듈 추가 규칙

1. 하나의 모듈은 가능한 한 하나의 Azure 리소스 경계만 가집니다.
2. 재사용되지 않는 배포 조합은 공용 모듈이 아니라 IaC 리프에서 조합합니다.
3. 입력은 환경 무관해야 하며, 이름/ID/정책 같은 순수 계약만 노출합니다.
4. 출력은 다른 리프가 remote state로 소비하기 쉬운 리소스 ID/이름 중심으로 유지합니다.
5. strict foundation 단계에서는 비-AVM 모듈을 표준 목록에 추가하지 않습니다.

# terraform-modules — AVM 적용 범위 (현재 기준)

공동 모듈은 **항상 이 레포**에서 관리하며, IaC는 Git `source`로만 참조한다.  
아래는 **AVM-only / AVM+azurerm 혼합 / azurerm-only(예외)** 분류다.

## 요약 표

| 모듈 | 분류 | 설명 |
|------|------|------|
| `route-table` | **AVM-only** | `avm-res-network-routetable` 래퍼 (`routes_legacy_mode` 등) |
| `firewall-policy` | **AVM-only** | `avm-res-network-firewallpolicy` 래퍼 |
| `private-endpoint` | **AVM-only** | `avm-res-network-privateendpoint` 래퍼 |
| `vnet` | **AVM-only** | `avm-res-network-virtualnetwork` 래퍼 |
| `storage-account` | **AVM-only** | `avm-res-storage-storageaccount` 래퍼 |
| `resource-group` | **AVM-only** | `avm-res-resources-resourcegroup` 래퍼 |
| `log-analytics-workspace` | **AVM-only** | `avm-res-operationalinsights-workspace` 래퍼 |
| `key-vault` | **AVM-only** | `avm-res-keyvault-vault` 래퍼 |
| `application-security-group` | **azurerm-only** | ASG 단일 리소스 예외 모듈 |
| `network-security-group` | **azurerm-only** | NSG + inline rule 단일 리소스 예외 모듈 |
| `monitoring-storage` | **AVM + azurerm** | 내부에서 `storage-account`·`private-endpoint`(AVM 래퍼) 조합 + **`azurerm_role_assignment` 예외** |
| `hub-vnet` | **azurerm 중심** (향후 AVM 점진 도입) | VNet/서브넷/NSG 등 복합·기존 계약. 전부 AVM만으로는 미정리 |
| `spoke-vnet` | **azurerm 중심** | 피어링·Private DNS·NSG 등 복합 |
| `spoke-workloads` | **azurerm 중심** | 워크로드용 VNet/NSG 등 복합 |
| `shared-services` | **azurerm 중심** | Log Analytics 솔루션·Action Group·대시보드 등 (AVM 단일로 미치환) |
| `virtual-machine` | **azurerm-only** | VM AVM 계약 불일치로 `azurerm` NIC/VM 유지 (레포 정책상 예외) |
| `vnet-peering` | **azurerm-only** | Peering 전용 경량 AVM 미사용 |
| `subnet-keyvault-sg` | **azurerm-only** | NSG/ASG 규칙 조합 — 적합 AVM으로 미전환 |
| `subnet-vm-access-sg` | **azurerm-only** | 동일 |

## IaC 스택 관점 (참고)

- **Route / Security-policy(Firewall Policy)** — 공동 모듈이 **AVM 래퍼**를 통해 배포.
- **Security-policy** 중 방화벽 VM·PIP는 현재 **IaC에 `azurerm` 직접** (다음 후보: `avm-res-network-azurefirewall` 등을 공동 모듈로).

## 용어

- **AVM-only**: 해당 모듈 `main.tf`에 Azure 리소스 생성은 **Registry AVM 서브모듈**만 사용.
- **AVM + azurerm**: AVM으로 만든 리소스에 **추가로** `azurerm_*` 예외 리소스가 **같은 모듈**에 존재.
- **azurerm-only (예외)**: 당분간 **AVM 미사용**, 레포에서 재사용 가능한 **표준 예외**로 관리.

# `as-is` -> `to-be` 매핑표

## 1. 목적

이 문서는 현재 작성되어 있는 Terraform 코드를 `as-is`로 보고,
이를 **공동 모듈 = AVM 우선 리소스 단위**, **IaC = 배포 스택 단위**라는 `to-be` 구조로
어떻게 옮길지 판단하기 위한 매핑표다.

Strict Foundation 기준에서는 AVM-only 모듈만 즉시 전환 대상으로 보고,
non-AVM 항목은 Deferred 파동으로 분리한다.

핵심 원칙은 다음과 같다.

- `as-is`의 기준은 **현재 폴더 이름**이 아니라 **실제로 만들려는 Azure 리소스와 연결 관계**다.
- `to-be`의 기준은 **실제 Azure 리소스 유형**과 **리프 스택 배포 경계**다.
- 매핑은 일부러 **과도한 미세 분해를 피한 중간 계층**에서 멈춘다.
- 어디까지 나눌지는 이 문서를 보고 **사용자가 최종 판단**한다.

## 2. 전체 스택 강제 규칙

아래 규칙은 **모든 도메인 / 모든 스택**에 공통으로 적용한다.

- 상위 디렉토리는 **리소스 종류**
- 리프 디렉토리는 **리소스명**
- 각 리프는 **자기 이름에 해당하는 리소스만 관리**
- 역할 이름이나 추상 이름으로 만든 별도 리프는 금지
- 보안 리소스와 컴퓨트 리소스도 예외 없이 **자기 리소스 종류 아래, 자기 리소스명 리프**에서 관리
- NSG, ASG, rule, association 같은 리소스도 **자기 리소스 기준**으로 분리
- 현재 남아 있는 `shared`, `workload`, `spoke-subnet-nsg` 같은 **legacy 리프명은 정리 대상**
- 단, Compute는 **서버명 리프**를 실제 배포 경계로 보고, 해당 서버 전용 NIC / OS Disk / Data Disk는 같은 `compute/<server-name>/`에서 함께 관리 가능

예:

- `vnet/hub-vnet/`
- `subnet/hub-pep-subnet/`
- `compute/linux-monitoring-vm/`
- `peering/hub-to-spoke/`

## 3. 계층 기준

| 계층 | 설명 | 예시 |
|------|------|------|
| **공동 모듈 계층** | 재사용 목적. AVM 우선 리소스 단위 모듈 | `vnet`, `route-table`, `firewall-policy`, `storage-account` |
| **스택 계층** | 실제 `plan/apply` 대상. 리프 디렉터리 | `01.network/vnet/hub-vnet`, `03.shared-services/shared` |
| **조합 계층** | 여러 리소스를 한 번에 다루는 묶음. state 이전이 끝날 때까지 deprecated 호환 자산으로만 유지 | `hub-vnet`, `shared-services`, `monitoring-storage` |

## 4. 공통 판단 기준

| 질문 | 판단 |
|------|------|
| AVM이 있는가? | 있으면 공동 모듈은 **AVM 래퍼 우선** |
| 단일 AVM으로 끝나는가? | 끝나면 **리소스 단위 모듈**로 유지 |
| AVM + 소량 보강이 필요한가? | 공동 모듈 안에서 **AVM + `azurerm` 예외** 허용 |
| 여러 리소스를 반복 조합하는가? | **조합 모듈** 또는 **IaC 조합 스택** 후보 |
| 한 번만 쓰는가? | 굳이 공동 모듈로 승격하지 않고 IaC에 둘 수 있음 |

## 5. 상위 매핑표

| 도메인 | `as-is` 기준 | 현재 성격 | `to-be` 공동 모듈 후보 | `to-be` IaC 스택 후보 | 사용자 판단 포인트 |
|--------|--------------|-----------|-------------------------|-----------------------|--------------------|
| Network | `hub-vnet` | Hub 네트워크 조합 모듈 | `vnet`, `subnet`, `network-security-group`, `network-security-rule`, `subnet-network-security-group-association`, `private-dns-zone`, `private-dns-zone-vnet-link`, `dns-private-resolver`, `dns-private-resolver-inbound-endpoint`, `public-ip`, `virtual-network-gateway`, `route-table`, `firewall-policy` | `01.network/vnet/hub-vnet`, `01.network/subnet/*`, `01.network/network-security-group/*`, `01.network/network-security-rule/*`, `01.network/subnet-network-security-group-association/*`, `01.network/private-dns-zone/*`, `01.network/private-dns-zone-vnet-link/*`, `01.network/dns-private-resolver/*`, `01.network/dns-private-resolver-inbound-endpoint/*`, `01.network/public-ip/*`, `01.network/virtual-network-gateway/*` | deprecated 후 리프 state로 이전 |
| Network | `spoke-vnet` | Spoke 네트워크 조합 모듈 | `vnet`, `subnet`, `network-security-group`, `subnet-network-security-group-association`, `private-dns-zone`, `private-dns-zone-vnet-link`, `route-table`, `vnet-peering` | `01.network/vnet/spoke-vnet`, `01.network/subnet/*`, `01.network/network-security-group/*`, `01.network/subnet-network-security-group-association/*`, `01.network/private-dns-zone/*`, `01.network/private-dns-zone-vnet-link/*`, `09.connectivity/peering/*` | deprecated 후 리프 state로 이전 |
| Network | `spoke-workloads` | 워크로드용 네트워크 조합 | `vnet`, `subnet`, 필요 시 `private-endpoint` | `04.apim/workload`, `05.ai-services/workload`, 필요 시 별도 spoke workload 리프 | phase 2 이후 서비스별 분해 |
| Network | `vnet-peering` | 단일 연결 리소스 | `vnet-peering` 또는 향후 AVM 대체 | `09.connectivity/peering/hub-to-spoke`, `09.connectivity/peering/spoke-to-hub` | 피어링을 항상 별도 스택으로 둘지 |
| Network | `subnet-keyvault-sg` | 특정 서브넷 보안 규칙 묶음 | `application-security-group`, `network-security-group`, `network-security-rule`, `subnet-network-security-group-association` | `01.network/application-security-group/*`, `01.network/network-security-group/*`, `01.network/network-security-rule/*`, `01.network/subnet-network-security-group-association/*` | Key Vault용 보안 규칙을 어떤 리소스명 리프로 나눌지 |
| Network | `subnet-vm-access-sg` | VM 접근 보안 규칙 묶음 | `application-security-group`, `network-security-group`, `network-security-rule` | `01.network/application-security-group/*`, `01.network/network-security-group/*`, `01.network/network-security-rule/*` | VM 접근 규칙을 어떤 리소스명 리프로 나눌지 |
| Storage | `monitoring-storage` | Storage + PE + 권한 보강 조합 | `storage-account`, `private-endpoint`, 필요 시 `key-vault` | `02.storage/monitoring` | deprecated 후 리소스별 리프 분해 |
| Shared | `log-analytics-workspace` | 단일 리소스 모듈 | `log-analytics-workspace` | `03.shared-services/log-analytics` | 분리 유지 |
| Shared | `shared-services` | Workspace 기반 서비스 묶음 | `shared-services` 조합 유지 또는 세부 서비스 분해 | `03.shared-services/shared` | 1차에서는 shared leaf 유지, 로컬 wrapper 제거 |
| Compute | `virtual-machine` | VM 배포 조합 모듈 | `virtual-machine` 내부에서 VM/NIC/Disk AVM 조합 | `06.compute/linux-monitoring-vm`, `06.compute/windows-example` | 서버 1대 기준으로 어디까지 같은 리프에서 관리할지 |
| APIM | APIM workload 코드 | 서비스 스택 | APIM용 AVM/공동 모듈 | `04.apim/workload` | APIM을 더 세분화할지 |
| AI | AI services workload 코드 | 서비스 스택 | OpenAI / ML Workspace / PE 관련 모듈 | `05.ai-services/workload` | AI 서비스를 서비스별 리프로 나눌지 |
| Identity/RBAC | 기존 `07.rbac` 묶음 코드 | 계정/권한 혼합 | 공통 모듈 최소화, 스택 분리 우선 | `07.identity/*`, `08.rbac/*` | RBAC를 더 일반화할지 |

## 6. 세부 매핑표

### 5.1 Network

| `as-is` 구성 | 실제 의도 리소스 | `to-be` 공동 모듈 기준 | `to-be` 스택 기준 |
|--------------|------------------|-------------------------|-------------------|
| `hub-vnet` | Hub VNet | `vnet` | `01.network/vnet/hub-vnet` |
| `hub-vnet` | Hub 기본 서브넷들 | `subnet` | `01.network/subnet/hub-*` |
| `hub-vnet` | Hub DNS Zone | `private-dns-zone` | `01.network/private-dns-zone/*` |
| `hub-vnet` | Hub DNS Resolver / Inbound Endpoint | `dns-private-resolver`, `dns-private-resolver-inbound-endpoint` | `01.network/dns-private-resolver/*`, `01.network/dns-private-resolver-inbound-endpoint/*` |
| `hub-vnet` | Hub VPN Gateway / Public IP | `virtual-network-gateway`, `public-ip`, 필요 시 `local-network-gateway`, `virtual-network-gateway-connection` | `01.network/virtual-network-gateway/*`, `01.network/public-ip/*` |
| `spoke-vnet` | Spoke VNet | `vnet` | `01.network/vnet/spoke-vnet` |
| `spoke-vnet` | Spoke 서브넷 | `subnet` | `01.network/subnet/spoke-*` |
| `subnet-keyvault-sg` | Key Vault 관련 NSG/ASG/규칙 | `application-security-group`, `network-security-group`, `network-security-rule`, `subnet-network-security-group-association` | `01.network/application-security-group/*`, `01.network/network-security-group/*`, `01.network/network-security-rule/*`, `01.network/subnet-network-security-group-association/*` |
| `subnet-vm-access-sg` | VM 접근 NSG/ASG/규칙 | `application-security-group`, `network-security-group`, `network-security-rule` | `01.network/application-security-group/*`, `01.network/network-security-group/*`, `01.network/network-security-rule/*` |
| Route 구성 | Hub/Spoke UDR | `route-table` | `01.network/route/hub-route-default`, `01.network/route/spoke-route-default` |
| Firewall 정책 | Firewall Policy | `firewall-policy` | `01.network/security-policy/hub-sg-policy-default`, `01.network/security-policy/spoke-sg-policy-default` |
| Peering | Hub <-> Spoke 연결 | `vnet-peering` | `09.connectivity/peering/*` |

추가 메모:

- `application-security-group`는 공식 AVM 확인 후 AVM 래퍼로 사용
- `network-security-group`도 공식 AVM를 재확인하여 AVM 래퍼로 사용
- `network-security-rule`, `subnet-network-security-group-association`, `private-dns-zone-vnet-link`는 단일 `azurerm` 예외 모듈 유지

### 5.2 Shared / Storage / Compute

| `as-is` 구성 | 실제 의도 리소스 | `to-be` 공동 모듈 기준 | `to-be` 스택 기준 |
|--------------|------------------|-------------------------|-------------------|
| `monitoring-storage` | Storage Account | `storage-account` | `02.storage/monitoring` |
| `monitoring-storage` | Private Endpoint | `private-endpoint` | `02.storage/monitoring` |
| `monitoring-storage` | 권한 보강 | `azurerm` 예외 유지 후보 | `02.storage/monitoring` |
| `log-analytics-workspace` | Log Analytics Workspace | `log-analytics-workspace` | `03.shared-services/log-analytics` |
| `shared-services` | Solutions / Action Group / Dashboard | 조합 모듈 유지 후보 | `03.shared-services/shared` |
| `virtual-machine` | Linux / Windows VM, NIC, Disk, MI | `virtual-machine` 내부에서 VM / NIC / Disk AVM 조합 | `06.compute/linux-monitoring-vm`, `06.compute/windows-example` |

### 5.3 Workload

| `as-is` 구성 | 실제 의도 리소스 | `to-be` 공동 모듈 기준 | `to-be` 스택 기준 |
|--------------|------------------|-------------------------|-------------------|
| APIM 코드 | APIM 및 연계 네트워크 | APIM용 공통 모듈 | `04.apim/workload` |
| AI services 코드 | OpenAI / AI Foundry / PE / DNS | 서비스별 공통 모듈 조합 | `05.ai-services/workload` |
| `spoke-workloads` | 워크로드 공통 네트워크 패턴 | `vnet`, `subnet`, `private-endpoint` 조합 후보 | `04.apim/workload`, `05.ai-services/workload` 또는 별도 workload 리프 |

## 7. 우선 구현 순서

1. **공동 모듈 AVM 정리**
   - 단일 리소스로 바로 바꿀 수 있는 모듈부터 AVM 래퍼로 정리
2. **Network 매핑 확정**
   - `hub-vnet`, `spoke-vnet`, `subnet-*`, `route`, `security-policy`, `peering`의 경계를 확정
3. **Shared / Storage / Compute 매핑 확정**
   - 유지할 조합 모듈과 더 쪼갤 후보를 구분
   - Compute는 서버 1대 기준으로 NIC / Disk 포함 경계를 확정
4. **Workload 계층 확정**
   - APIM, AI services를 서비스 스택 기준으로 둘지 더 나눌지 결정
5. **구현 착수**
   - 확정된 계층 기준으로 `terraform-modules`와 `terraform-iac` 코드를 정리

## 8. 이 문서를 보는 방법

- 이 표에서 **너무 잘게 쪼개진 항목**은 다시 묶는다.
- 반대로 **별도 state / 별도 apply**가 꼭 필요한 항목은 한 단계 더 세분화한다.
- 즉, 이 문서는 최종 구조가 아니라 **사용자 판단을 위한 중간 설계판**이다.

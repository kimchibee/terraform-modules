# terraform-modules — AVM 적용 범위 (Strict Foundation 기준)

공동 모듈은 **항상 이 레포**에서 관리하며, IaC는 Git `source`로만 참조한다.  
이 문서는 strict 정책 기준으로 모듈을 다음 3개로 나눈다.

- **Foundation (AVM-only)**: 현재 파동에서 유지/사용
- **Deferred (integrated-only)**: 독립 모듈을 두지 않고 상위 AVM 입력으로 통합
- **Deprecated composite**: state 이전 후 제거

## 요약 표

| 모듈 | 분류 | 상태 | 설명 |
|------|------|------|------|
| `route-table` | **AVM-only** | Foundation | `avm-res-network-routetable` 래퍼 (`routes_legacy_mode` 등) |
| `firewall-policy` | **AVM-only** | Foundation | `avm-res-network-firewallpolicy` 래퍼 |
| `private-endpoint` | **AVM-only** | Foundation | `avm-res-network-privateendpoint` 래퍼 |
| `vnet` | **AVM-only** | Foundation | `avm-res-network-virtualnetwork` 래퍼 |
| `storage-account` | **AVM-only** | Foundation | `avm-res-storage-storageaccount` 래퍼 |
| `resource-group` | **AVM-only** | Foundation | `avm-res-resources-resourcegroup` 래퍼 |
| `log-analytics-workspace` | **AVM-only** | Foundation | `avm-res-operationalinsights-workspace` 래퍼 |
| `key-vault` | **AVM-only** | Foundation | `avm-res-keyvault-vault` 래퍼 |
| `application-security-group` | **AVM-only** | Foundation | `avm-res-network-applicationsecuritygroup` 래퍼 |
| `network-security-group` | **AVM-only** | Foundation | `avm-res-network-networksecuritygroup` 래퍼 |
| `subnet` | **AVM-only** | Foundation | `avm-res-network-virtualnetwork//modules/subnet` 래퍼 |
| `private-dns-zone` | **AVM-only** | Foundation | `avm-res-network-privatednszone` 래퍼 |
| `private-dns-zone-vnet-link` | **AVM-only** | Foundation | `avm-res-network-privatednszone//modules/private_dns_virtual_network_link` 래퍼 |
| `dns-private-resolver` | **AVM-only** | Foundation | `avm-res-network-dnsresolver` 래퍼 |
| `public-ip` | **AVM-only** | Foundation | `avm-res-network-publicipaddress` 래퍼 |
| `virtual-network-gateway` | **AVM-only** | Foundation | `avm-ptn-vnetgateway` 패턴 모듈 래퍼 |
| `local-network-gateway` | **AVM-only** | Foundation | `avm-res-network-localnetworkgateway` 래퍼 |
| `virtual-network-gateway-connection` | **AVM-only** | Foundation | `avm-res-network-connection` 래퍼 |
| `virtual-machine` | **AVM-only** | Foundation | `avm-res-compute-virtualmachine` 래퍼 |
| `vnet-peering` | **AVM-only** | Foundation | `avm-res-network-virtualnetwork//modules/peering` 래퍼 |
| `dns-private-resolver-inbound-endpoint` | **removed** | Removed legacy | `dns-private-resolver`의 `inbound_endpoints`로 통합됨 |
| `network-security-rule` | **removed** | Removed legacy | `network-security-group`의 `security_rules`로 통합됨 |
| `subnet-network-security-group-association` | **removed** | Removed legacy | `subnet` 입력으로 통합됨 |
| `monitoring-storage` | **AVM + azurerm** | Deprecated composite | `azurerm_role_assignment` 예외 포함 혼합 모듈 |
| `hub-vnet` | **azurerm 중심** | Deprecated composite | VNet/서브넷/NSG/DNS/Resolver/VPN 복합 모듈 |
| `spoke-vnet` | **azurerm 중심** | Deprecated composite | 피어링·Private DNS·NSG 복합 모듈 |
| `spoke-workloads` | **azurerm 중심** | Deprecated composite | 워크로드용 네트워크/서비스 조합 모듈 |
| `shared-services` | **azurerm 중심** | Deprecated composite | Log Analytics 위에 붙는 복합 서비스 묶음 |
| `subnet-keyvault-sg` | **legacy azurerm-only** | Deprecated composite | NSG/ASG/rule/association 조합 모듈 |
| `subnet-vm-access-sg` | **legacy azurerm-only** | Deprecated composite | NSG/ASG/rule 조합 모듈 |

## 정리 원칙

- `Foundation`: strict AVM-only 파동에서 즉시 사용 가능
- `Deferred`: 독립 모듈은 없고 상위 AVM 입력으로만 통합 사용
- `Removed legacy`: 레거시 단일 모듈 파일 제거 완료
- `Deprecated composite`: 신규 사용 금지, state 이전 후 제거

## IaC 스택 관점 (참고)

- **Route / Security-policy(Firewall Policy)** — 공동 모듈이 **AVM 래퍼**를 통해 배포.
- **Security-policy** 중 방화벽 VM·PIP는 현재 **IaC에 `azurerm` 직접** (다음 후보: `avm-res-network-azurefirewall` 등을 공동 모듈로).

## 용어

- **AVM-only**: 해당 모듈 `main.tf`에 Azure 리소스 생성은 **Registry AVM 서브모듈**만 사용.
- **AVM + azurerm**: AVM으로 만든 리소스에 **추가로** `azurerm_*` 예외 리소스가 **같은 모듈**에 존재.
- **azurerm-only (예외)**: 당분간 **AVM 미사용**, 레포에서 재사용 가능한 **표준 예외**로 관리.

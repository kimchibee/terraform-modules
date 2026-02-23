# AVM 전환 예외 모듈

확장성을 위해 가능한 모듈은 **Azure Verified Modules(AVM)** 래퍼로 제공합니다.  
아래 모듈은 **AVM으로 전환 시 오히려 복잡성이 증가**하므로, 의도적으로 azurerm 인라인으로 유지합니다.

| 모듈 | 사유 |
|------|------|
| **hub-vnet** | RG + VNet + Subnets + **VPN Gateway** + **DNS Resolver** + **Private DNS Zones** + NSG 등 복합 구성. AVM `avm-res-network-virtualnetwork`는 VNet+서브넷 위주이며, Gateway/Resolver/Private DNS를 한 모듈로 커버하지 않음. AVM으로 전환 시 VNet만 AVM + 나머지 azurerm 분리로 코드 경로가 늘어나 복잡도 증가. |
| **spoke-vnet** | RG + VNet + Subnets 등으로 hub-vnet과 유사한 복합 구조. 동일 이유로 AVM 단일 대체가 어렵고, 부분 전환 시 일관성·가독성 저하. |
| **virtual-machine** | **Linux/Windows** 분기, **NIC + VM + vm_extensions** + **Managed Identity** 등 요구사항이 많음. AVM `avm-res-compute-virtualmachine`은 인터페이스·지원 범위가 상이하여, 래퍼로 맞추면 조건 분기와 예외 처리만 늘어나 복잡성 증가. |
| **vnet** | 단순 VNet+서브넷이지만, AVM `avm-res-network-virtualnetwork`는 서브넷/구성 방식이 달라 기존 호출부 변수와 1:1 매핑이 어렵고, 래퍼 복잡도 대비 이득이 적음. |
| **vnet-peering** | 단일 `azurerm_virtual_network_peering` 리소스로 인터페이스가 단순함. AVM peering 서브모듈은 부모 VNet 모듈 버전·입력 구조에 종속되어, 독립 사용 시 오버헤드만 커질 수 있어 유지. |

---

**AVM 래퍼로 제공 중인 모듈:**  
`log-analytics-workspace`, `key-vault`, `resource-group`, `private-endpoint`, `storage-account`

**문서 갱신:** AVM 전환 정책 변경 시 이 파일을 함께 수정합니다.

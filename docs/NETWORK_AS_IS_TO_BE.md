# 네트워크 `as-is` -> `to-be`

## 1. 강제 규칙

네트워크 스택은 아래 규칙을 **반드시** 지킨다.

`hub-vnet`, `spoke-vnet` 같은 복합 모듈은 이 규칙으로 이전하기 전까지의 **deprecated 호환 자산**으로만 본다.

- 스택 디렉토리는 **리소스 종류**로 먼저 나눈다.
- 그 하위 리프 디렉토리는 **리소스명**으로 만든다.
- 각 리프는 **자기 디렉토리 이름에 해당하는 리소스만** 관리한다.
- 다른 성격의 리소스를 역할 이름으로 다시 묶지 않는다.
- 특히 `보안 확장`, `공통 보안`, `추가 설정` 같은 **추상 이름 디렉토리는 만들지 않는다**.
- 보안 리소스와 컴퓨트 리소스도 예외 없이 **자기 리소스 종류 아래, 자기 리소스명 리프**에서 관리한다.

예:

```text
01.network/
  vnet/
    hub-vnet/
    spoke-vnet/
  subnet/
    hub-gateway-subnet/
    hub-dnsresolver-inbound-subnet/
    hub-azurefirewall-subnet/
    hub-azurefirewall-management-subnet/
    hub-appgateway-subnet/
    hub-monitoring-vm-subnet/
    hub-pep-subnet/
    spoke-apim-subnet/
    spoke-pep-subnet/
  route/
    hub-route-default/
    spoke-route-default/
  private-dns-zone/
    hub-blob/
    hub-vault/
    spoke-azure-api/
    spoke-openai/
    spoke-cognitiveservices/
    spoke-ml/
    spoke-notebooks/
  dns-private-resolver/
    hub/
  dns-private-resolver-inbound-endpoint/
    hub/
  public-ip/
    hub-vpn-gateway/
  virtual-network-gateway/
    hub-vpn-gateway/
  security-policy/
    hub-sg-policy-default/
    spoke-sg-policy-default/
  network-security-group/
    hub-monitoring-vm/
    hub-pep/
    keyvault-standalone/
    spoke-pep/
  application-security-group/
    keyvault-clients/
    vm-allowed-clients/
  network-security-rule/
    hub-monitoring-vm-allow-keyvault-outbound/
    hub-monitoring-vm-allow-vm-clients-22/
    hub-monitoring-vm-allow-vm-clients-3389/
    hub-pep-allow-keyvault-outbound/
    hub-pep-allow-keyvault-clients-443/
  subnet-network-security-group-association/
    hub-monitoring-vm-subnet/
    hub-pep-subnet/
    spoke-pep-subnet/
  network-security-rule/
    hub-monitoring-vm-allow-keyvault-outbound/
    hub-pep-allow-keyvault-clients-443/
  subnet-network-security-group-association/
    hub-monitoring-vm-subnet/
    hub-pep-subnet/
  private-dns-zone/
    hub-blob/
    hub-vault/
    spoke-openai/
  public-ip/
    hub-vpn-gateway/
  virtual-network-gateway/
    hub-vpn-gateway/
  dns-private-resolver/
    hub/
  dns-private-resolver-inbound-endpoint/
    hub/
```

## 2. 네트워크에서 이 규칙이 의미하는 것

- `vnet/hub-vnet`은 **Hub VNet** 스택이다.
- `vnet/spoke-vnet`은 **Spoke VNet** 스택이다.
- `subnet/hub-pep-subnet`은 **Hub PEP Subnet** 스택이다.
- `subnet/spoke-apim-subnet`은 **Spoke APIM Subnet** 스택이다.
- `route/hub-route-default`는 **Hub Route** 스택이다.
- `security-policy/hub-sg-policy-default`는 **Hub Security Policy** 스택이다.

즉, **리소스명으로 끊고, 그 리소스 자체만 관리**한다.

## 3. 하면 안 되는 것

아래처럼 하면 안 된다.

- `hub-security/`
- `hub-security-extension/`
- `hub-network-extra/`
- `subnet-security/`
- `shared-subnet-security/`

이런 디렉토리는 리소스명이 아니라 **역할·해석·추상화 이름**이기 때문이다.

예를 들어:

- NSG는 `network-security-group/<nsg-name>/`에서 관리
- ASG는 `application-security-group/<asg-name>/`에서 관리
- VM은 `compute/<vm-name>/`에서 관리

즉 **보안 리소스든 컴퓨트 리소스든, 연결 대상 리소스 안에 넣지 않고 자기 리소스 종류/리소스명으로 분리한다**.

## 4. `as-is`

| 현재 코드 | 현재 문제 |
|------|------|
| `hub-vnet` | VNet, Subnet, NSG, DNS Zone, DNS Link, Resolver, VPN이 너무 많이 섞여 있음 |
| `spoke-vnet` | VNet, Subnet, NSG, DNS Zone, DNS Link, Peering 성격이 섞여 있음 |
| `subnet-keyvault-sg` | 서브넷 leaf 안에서 ASG/NSG/rule/association을 같이 만들어 단일 리프 규칙에 어긋남 |
| `subnet-vm-access-sg` | VM 접근 보안 rule을 subnet 기준 helper로 묶고 있어 리소스명 규칙에 어긋남 |
| `spoke-subnet-nsg` 같은 helper 리프명 | 리소스명이 아니라 역할 이름이라 target 규칙에 맞지 않음 |

## 5. `to-be`

| 리소스 종류 | 리프 디렉토리 | 관리 대상 |
|------|------|------|
| `vnet` | `hub-vnet` | Hub VNet 자체 |
| `vnet` | `spoke-vnet` | Spoke VNet 자체 |
| `subnet` | `hub-gateway-subnet` | `GatewaySubnet` 관련 리소스 |
| `subnet` | `hub-dnsresolver-inbound-subnet` | `DNSResolver-Inbound` 관련 리소스 |
| `subnet` | `hub-azurefirewall-subnet` | `AzureFirewallSubnet` 관련 리소스 |
| `subnet` | `hub-azurefirewall-management-subnet` | `AzureFirewallManagementSubnet` 관련 리소스 |
| `subnet` | `hub-appgateway-subnet` | `AppGatewaySubnet` 관련 리소스 |
| `subnet` | `hub-monitoring-vm-subnet` | `Monitoring-VM-Subnet` 관련 리소스 |
| `subnet` | `hub-pep-subnet` | `pep-snet` 자체 |
| `subnet` | `spoke-apim-subnet` | `apim-snet` 관련 리소스 |
| `subnet` | `spoke-pep-subnet` | `pep-snet` 관련 리소스 |
| `route` | `hub-route-default` | Hub 라우트 |
| `route` | `spoke-route-default` | Spoke 라우트 |
| `security-policy` | `hub-sg-policy-default` | Hub 정책 |
| `security-policy` | `spoke-sg-policy-default` | Spoke 정책 |
| `network-security-group` | `hub-monitoring-vm` | Hub Monitoring VM NSG 자체 |
| `network-security-group` | `hub-pep` | Hub PEP NSG 자체 |
| `network-security-group` | `spoke-pep` | Spoke PEP NSG 자체 |
| `application-security-group` | `keyvault-clients` | Key Vault client ASG 자체 |
| `application-security-group` | `vm-allowed-clients` | VM access client ASG 자체 |
| `network-security-rule` | `hub-monitoring-vm-allow-keyvault-outbound` | NSG rule 1개 |
| `network-security-rule` | `hub-pep-allow-keyvault-clients-443` | PEP NSG 인바운드 rule 1개 |
| `subnet-network-security-group-association` | `hub-pep-subnet` | Subnet-NSG association 1개 |
| `private-dns-zone` | `hub-blob` | Private DNS Zone 1개 |
| `private-dns-zone-vnet-link` | `hub-vault-to-hub-vnet` | Zone-VNet link 1개 |
| `public-ip` | `hub-vpn-gateway` | VPN Gateway용 Public IP 1개 |
| `dns-private-resolver` | `hub` | DNS Private Resolver 1개 |
| `dns-private-resolver-inbound-endpoint` | `hub` | DNS Resolver inbound endpoint 1개 |
| `virtual-network-gateway` | `hub-vpn-gateway` | VPN Gateway 1개 |

## 6. AVM 재검토 결과

- `application-security-group`는 공식 AVM를 확인해 AVM 래퍼로 전환한다.
- `network-security-group`도 공식 AVM를 재확인했으므로 thin 예외가 아니라 AVM 래퍼를 표준으로 사용한다.
- 반면 `network-security-rule`, `subnet-network-security-group-association`, `private-dns-zone-vnet-link`는 현재 구조에서 단일 `azurerm` 리소스 예외 모듈이 더 직접적이므로 분리 유지한다.

## 7. 서브넷 스택 규칙

서브넷 스택은 아래 규칙을 따른다.

- 서브넷 디렉토리는 **서브넷명으로 만든다**.
- 그 디렉토리 안에는 **서브넷 자체 리소스만** 둔다.
- NSG, ASG, VM 같은 다른 리소스는 **서브넷 리프 안에 두지 않는다**.
- 서브넷과 연결되는 보안/컴퓨트 리소스라도 **자기 리소스 종류 리프**로 분리한다.

즉:

- `hub-pep-subnet`은 `subnet/hub-pep-subnet/`
- `hub-pep-nsg`는 `network-security-group/hub-pep-nsg/`
- `hub-keyvault-clients`는 `application-security-group/hub-keyvault-clients/`
- `hub-pep-allow-keyvault-clients-443`는 `network-security-rule/hub-pep-allow-keyvault-clients-443/`
- `hub-pep-subnet`과 `hub-pep-nsg` 연결은 `subnet-network-security-group-association/hub-pep-subnet/`

처럼 간다.

## 8. 전체 스택에도 같은 규칙 적용

이 규칙은 네트워크만의 예외 규칙이 아니다.  
**모든 스택이 동일하게 따라야 하는 기본 규칙**이다.

- 상위 디렉토리는 **리소스 종류**
- 리프 디렉토리는 **리소스명**
- 리프는 **자기 이름에 해당하는 리소스만 관리**
- 보안 리소스와 컴퓨트 리소스도 **같은 규칙을 예외 없이 적용**

예를 들어:

- `03.shared-services/log-analytics/`는 `log-analytics` 리소스만 관리
- `06.compute/linux-monitoring-vm/`는 `linux-monitoring-vm` 리소스만 관리
- `09.connectivity/peering/hub-to-spoke/`는 `hub-to-spoke` 연결만 관리

## 9. 실무 결론

앞으로는 네트워크를 다음처럼 본다.

- `vnet`은 VNet별
- `subnet`은 Subnet별
- `private-dns-zone`은 Zone별
- `private-dns-zone-vnet-link`는 Link별
- `dns-private-resolver`는 Resolver별
- `dns-private-resolver-inbound-endpoint`는 Endpoint별
- `public-ip`는 IP별
- `virtual-network-gateway`는 Gateway별
- `network-security-rule`은 Rule별
- `subnet-network-security-group-association`은 Association별
- `route`는 Route별
- `security-policy`는 Policy별
- `peering`은 Peering별

그리고 **리소스명으로 리프를 끊고, 그 리프는 자기 리소스만 관리한다.**

현재 `spoke-subnet-nsg`처럼 **리소스명 기반이 아닌 legacy 리프명**은
이 규칙에 맞게 정리해야 하는 대상으로 본다.

1차 전환 기준으로 `terraform-iac/azure/dev/01.network`의 리프 구조를 canonical layout으로 보고,
새 네트워크 리소스는 이 구조에만 추가한다.

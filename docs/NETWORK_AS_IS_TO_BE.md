# 네트워크 `as-is` -> `to-be`

## 1. 강제 규칙

네트워크 스택은 아래 규칙을 **반드시** 지킨다.

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
  security-policy/
    hub-sg-policy-default/
    spoke-sg-policy-default/
  network-security-group/
    hub-pep-nsg/
    spoke-apim-nsg/
  application-security-group/
    hub-keyvault-clients/
    hub-vm-allowed-clients/
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
| `hub-vnet` | VNet, Subnet, NSG, DNS, VPN이 너무 많이 섞여 있음 |
| `spoke-vnet` | VNet, Subnet, NSG, DNS Link, Peering 성격이 섞여 있음 |
| `subnet-keyvault-sg` | 서브넷 보안 규칙이지만 디렉토리 기준이 서브넷명이 아님 |
| `subnet-vm-access-sg` | 서브넷 보안 규칙이지만 디렉토리 기준이 서브넷명이 아님 |
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
| `network-security-group` | `hub-pep-nsg` | Hub PEP NSG 자체 |
| `network-security-group` | `spoke-apim-nsg` | Spoke APIM NSG 자체 |
| `application-security-group` | `hub-keyvault-clients` | Key Vault client ASG 자체 |
| `application-security-group` | `hub-vm-allowed-clients` | VM access client ASG 자체 |

## 6. 서브넷 스택 규칙

서브넷 스택은 아래 규칙을 따른다.

- 서브넷 디렉토리는 **서브넷명으로 만든다**.
- 그 디렉토리 안에는 **서브넷 자체 리소스만** 둔다.
- NSG, ASG, VM 같은 다른 리소스는 **서브넷 리프 안에 두지 않는다**.
- 서브넷과 연결되는 보안/컴퓨트 리소스라도 **자기 리소스 종류 리프**로 분리한다.

즉:

- `hub-pep-subnet`은 `subnet/hub-pep-subnet/`
- `hub-pep-nsg`는 `network-security-group/hub-pep-nsg/`
- `hub-keyvault-clients`는 `application-security-group/hub-keyvault-clients/`

처럼 간다.

## 7. 전체 스택에도 같은 규칙 적용

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

## 8. 실무 결론

앞으로는 네트워크를 다음처럼 본다.

- `vnet`은 VNet별
- `subnet`은 Subnet별
- `route`는 Route별
- `security-policy`는 Policy별
- `peering`은 Peering별

그리고 **리소스명으로 리프를 끊고, 그 리프는 자기 리소스만 관리한다.**

현재 `spoke-subnet-nsg`처럼 **리소스명 기반이 아닌 legacy 리프명**은
이 규칙에 맞게 정리해야 하는 대상으로 본다.

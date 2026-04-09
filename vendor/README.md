# Vendored AVM Modules

이 디렉터리는 폐쇄망(에어갭) 환경에서 `terraform init`이 인터넷에 접근하지 않고도 동작하도록, Azure Verified Modules(AVM) 레포들을 특정 태그 시점의 스냅샷으로 직접 포함시킨 것이다.

## 정책

- 각 폴더는 단일 AVM 레포의 단일 태그 스냅샷이다.
- `.git` 디렉터리는 제거되어 있다 (서브모듈/원격 fetch 방지).
- 모든 wrapper(`terraform_modules/<module>`)는 `source = "../../vendor/<name>-<ver>"` 형식으로 이 폴더를 참조한다. 이 외의 외부 소스(Terraform Registry, GitHub) 참조는 금지한다.
- AVM 버전 업그레이드는 새 폴더(`<name>-<신규버전>`)를 추가하고 wrapper 의 source를 옮긴 뒤, 이전 폴더를 제거하는 절차로 수행한다.

## 재벤더링 절차

```bash
TAG=v0.17.1   # 또는 0.1.0 등 (레포에 따라 v 접두사 유무 다름)
NAME=terraform-azurerm-avm-res-network-virtualnetwork
DEST=vendor/${NAME}-${TAG#v}

git clone --depth 1 --branch "$TAG" "https://github.com/Azure/${NAME}.git" /tmp/avm-tmp
rm -rf /tmp/avm-tmp/.git
mv /tmp/avm-tmp "$DEST"
```

이후 본 README의 버전 표에 origin URL, 태그, commit SHA, 벤더링 일자를 갱신한다.

## 벤더링된 AVM 목록

| 폴더 | 원본 레포 | 태그 | Commit SHA | 벤더링 일자 |
|---|---|---|---|---|
| terraform-azurerm-avm-res-apimanagement-service-0.0.7 | Azure/terraform-azurerm-avm-res-apimanagement-service | v0.0.7 | dbf602d112939988850061e8eb95ede3b487507b | 2026-04-09 |
| terraform-azurerm-avm-res-network-applicationsecuritygroup-0.1.1 | Azure/terraform-azurerm-avm-res-network-applicationsecuritygroup | v0.1.1 | cf51ddc4a786ec54753802dd55ee27f0c2f4991e | 2026-04-09 |
| terraform-azurerm-avm-res-cognitiveservices-account-0.11.0 | Azure/terraform-azurerm-avm-res-cognitiveservices-account | v0.11.0 | 94239f1799aacafe1965abbe067d5206c52127fa | 2026-04-09 |
| terraform-azurerm-avm-res-network-dnsresolver-0.8.0 | Azure/terraform-azurerm-avm-res-network-dnsresolver | v0.8.0 | 73b1df385505485dee12fc3901756d4994fe9cc8 | 2026-04-09 |
| terraform-azurerm-avm-res-network-firewallpolicy-0.3.4 | Azure/terraform-azurerm-avm-res-network-firewallpolicy | v0.3.4 | 8580240f33fee12f92ef4834a9574ab0481686c5 | 2026-04-09 |
| terraform-azurerm-avm-res-keyvault-vault-0.10.2 | Azure/terraform-azurerm-avm-res-keyvault-vault | v0.10.2 | 3735ca49887857467f3030ad72fd43705e1eb387 | 2026-04-09 |
| terraform-azurerm-avm-res-network-localnetworkgateway-0.2.0 | Azure/terraform-azurerm-avm-res-network-localnetworkgateway | v0.2.0 | 97737dc63374864e8515326258a25ed64c198988 | 2026-04-09 |
| terraform-azurerm-avm-res-operationalinsights-workspace-0.4.1 | Azure/terraform-azurerm-avm-res-operationalinsights-workspace | v0.4.1 | 84802b4dc9875c0875e86dd10a33dd32be4c0d29 | 2026-04-09 |
| terraform-azurerm-avm-res-network-networksecuritygroup-0.5.1 | Azure/terraform-azurerm-avm-res-network-networksecuritygroup | v0.5.1 | ae82f649ff4e2f0a9d31a18b9c9cd227b1b9b497 | 2026-04-09 |
| terraform-azurerm-avm-res-network-privatednszone-0.5.0 | Azure/terraform-azurerm-avm-res-network-privatednszone | v0.5.0 | da8b7599c740d344de310ffa8cbe32c61322a809 | 2026-04-09 |
| terraform-azurerm-avm-res-network-privateendpoint-0.2.0 | Azure/terraform-azurerm-avm-res-network-privateendpoint | v0.2.0 | da330babc0448609533b9e935546d573edd6cf3f | 2026-04-09 |
| terraform-azurerm-avm-res-network-publicipaddress-0.2.1 | Azure/terraform-azurerm-avm-res-network-publicipaddress | v0.2.1 | 2790d091b373fc2fd9e13aed3165c8d0813a87e4 | 2026-04-09 |
| terraform-azurerm-avm-res-resources-resourcegroup-0.1.0 | Azure/terraform-azurerm-avm-res-resources-resourcegroup | 0.1.0 (no v prefix) | 8bcc07a275af0c62a65f14541fd42b7092005907 | 2026-04-09 |
| terraform-azurerm-avm-res-network-routetable-0.5.0 | Azure/terraform-azurerm-avm-res-network-routetable | v0.5.0 | c15f36b59aece69fc592e4e661dcd1cfc61bca3a | 2026-04-09 |
| terraform-azurerm-avm-res-storage-storageaccount-0.4.0 | Azure/terraform-azurerm-avm-res-storage-storageaccount | v0.4.0 | 364fcff298eb8b0729e0e8e7c9bdeec370fd3de5 | 2026-04-09 |
| terraform-azurerm-avm-res-network-virtualnetwork-0.17.1 | Azure/terraform-azurerm-avm-res-network-virtualnetwork | v0.17.1 | d9ee04bea936fdf98aa69a3957fc9cfef92e7673 | 2026-04-09 |
| terraform-azurerm-avm-res-compute-virtualmachine-0.20.0 | Azure/terraform-azurerm-avm-res-compute-virtualmachine | v0.20.0 | e8a4895e77a611d32f9cc1683ef48e8922ff8f7f | 2026-04-09 |
| terraform-azurerm-avm-ptn-vnetgateway-0.10.3 | Azure/terraform-azurerm-avm-ptn-vnetgateway | v0.10.3 | fe1164b2066730f651281d080141d93bac5c3128 | 2026-04-09 |
| terraform-azurerm-avm-res-network-connection-0.2.0 | Azure/terraform-azurerm-avm-res-network-connection | v0.2.0 | c962e44bb33f091067e5763e46f4bac6c8875105 | 2026-04-09 |

## Wrapper → Vendor 매핑

| Wrapper (`terraform_modules/`) | Vendor 폴더 | 비고 |
|---|---|---|
| api-management-service | terraform-azurerm-avm-res-apimanagement-service-0.0.7 | |
| application-security-group | terraform-azurerm-avm-res-network-applicationsecuritygroup-0.1.1 | 이전엔 pin 없음 → 최신 stable 고정 |
| cognitive-services-account | terraform-azurerm-avm-res-cognitiveservices-account-0.11.0 | |
| dns-private-resolver | terraform-azurerm-avm-res-network-dnsresolver-0.8.0 | |
| firewall-policy | terraform-azurerm-avm-res-network-firewallpolicy-0.3.4 | |
| key-vault | terraform-azurerm-avm-res-keyvault-vault-0.10.2 | |
| local-network-gateway | terraform-azurerm-avm-res-network-localnetworkgateway-0.2.0 | |
| log-analytics-workspace | terraform-azurerm-avm-res-operationalinsights-workspace-0.4.1 | |
| network-security-group | terraform-azurerm-avm-res-network-networksecuritygroup-0.5.1 | 이전엔 pin 없음 → 최신 stable 고정 |
| private-dns-zone | terraform-azurerm-avm-res-network-privatednszone-0.5.0 | |
| private-dns-zone-vnet-link | terraform-azurerm-avm-res-network-privatednszone-0.5.0/modules/private_dns_virtual_network_link | submodule 참조 |
| private-endpoint | terraform-azurerm-avm-res-network-privateendpoint-0.2.0 | |
| public-ip | terraform-azurerm-avm-res-network-publicipaddress-0.2.1 | |
| resource-group | terraform-azurerm-avm-res-resources-resourcegroup-0.1.0 | |
| route-table | terraform-azurerm-avm-res-network-routetable-0.5.0 | |
| storage-account | terraform-azurerm-avm-res-storage-storageaccount-0.4.0 | |
| subnet | terraform-azurerm-avm-res-network-virtualnetwork-0.17.1/modules/subnet | submodule 참조 |
| virtual-machine | terraform-azurerm-avm-res-compute-virtualmachine-0.20.0 | |
| virtual-network-gateway | terraform-azurerm-avm-ptn-vnetgateway-0.10.3 | Pattern 모듈 |
| virtual-network-gateway-connection | terraform-azurerm-avm-res-network-connection-0.2.0 | |
| vnet | terraform-azurerm-avm-res-network-virtualnetwork-0.17.1 | 0.7.1에서 0.17.1로 업그레이드됨. wrapper 코드도 갱신됨 |
| vnet-peering | terraform-azurerm-avm-res-network-virtualnetwork-0.17.1/modules/peering | submodule 참조 |

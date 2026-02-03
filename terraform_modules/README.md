# Terraform Modules 가이드

이 디렉터리는 **재사용 가능한 공통 Terraform 모듈**을 포함합니다.

## 모듈 목록

현재 사용 가능한 모듈:

### 네트워킹
- `hub-vnet` - Hub VNet (VPN Gateway, DNS Resolver, Private DNS Zones 포함)
- `spoke-vnet` - Spoke VNet (VNet Peering 포함)
- `vnet` - 단순 VNet (서브넷만 포함)
- `vnet-peering` - VNet Peering

### 컴퓨팅
- `virtual-machine` - Linux/Windows Virtual Machine

### 스토리지
- `storage-account` - Storage Account
- `key-vault` - Key Vault

### 모니터링 및 관리
- `log-analytics-workspace` - Log Analytics Workspace

### 네트워크 보안
- `private-endpoint` - Private Endpoint

### 기본 리소스
- `resource-group` - Resource Group

## 모듈 사용 방법

각 모듈은 독립적인 디렉터리에 있으며, `main.tf`, `variables.tf`, `outputs.tf`, `README.md`, `versions.tf` 파일을 포함합니다.

### 참조 방법

IaC 레포에서 다음과 같이 참조합니다:

```hcl
module "example" {
  source = "git::https://github.com/kimchibee/terraform-modules.git//terraform_modules/모듈명?ref=main"
  
  # 모듈별 변수 전달
  project_name = var.project_name
  environment  = var.environment
  # ...
}
```

### 버전 관리

- `ref=main`: 최신 개발 버전
- `ref=v1.0.0`: 특정 태그 버전 (안정 버전)

자세한 버전 관리 정책은 `VERSIONING.md`를 참고하세요.

## 모듈 추가/수정 가이드

새로운 모듈을 추가하거나 기존 모듈을 수정할 때는 다음 원칙을 따릅니다:

1. **단일 책임 원칙**: 각 모듈은 하나의 리소스 타입만 관리
2. **환경 무관**: dev/stage/prod 구분 없이 재사용 가능
3. **명확한 입력/출력**: `variables.tf`와 `outputs.tf`에 명확한 설명 포함
4. **문서화**: 각 모듈에 `README.md` 포함

자세한 내용은 `MODULE_REVIEW.md`를 참고하세요.
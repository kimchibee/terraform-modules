# Terraform Modules (공통 모듈)

Azure 인프라용 **재사용 가능한 Terraform 모듈** 라이브러리입니다.

- **모듈 위치**: [terraform_modules/](./terraform_modules/)
- **버전 정책**: Git Tag 기반. terraform-iac에서는 `ref=<태그>`로만 참조합니다.
- **설계 원칙**: 단일 책임, 환경 무관, 라이브러리 전용(직접 apply 하지 않음).

자세한 내용은 [terraform_modules/README.md](./terraform_modules/README.md)와 [terraform_modules/VERSIONING.md](./terraform_modules/VERSIONING.md)를 참고하세요.

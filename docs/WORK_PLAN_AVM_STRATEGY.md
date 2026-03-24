# 작업 계획서: 공동 모듈 AVM 전략

## 1. 목표 (고정)

- **공동 모듈 레포(`terraform-modules`)는 항상 사용**한다.
- Foundation 파동의 공동 모듈은 **AVM-only** 로 제한한다.
- AVM-only가 아닌 모듈은 Foundation 표준에서 제외하고 **Deferred** 로 분리한다.
- **IaC**는 `git::https://github.com/kimchibee/terraform-modules.git//terraform_modules/...?ref=...` 로 공동 모듈만 참조한다.

## 2. 현재 합의된 설계 방향

- **공동 모듈 레이어**는 Foundation 단계에서 **AVM-only 리소스 단위**로 유지한다.
- **IaC 레이어**는 실제 배포 단위인 **스택 디렉터리**로 구성하고, 필요한 공동 모듈을 조합해 배포한다.
- `hub-vnet`, `spoke-vnet`, `spoke-workloads`, `shared-services`, `monitoring-storage` 같은 **복합 모듈은 신규 사용 금지**로 보고, state 이전이 끝날 때까지 **deprecated 호환 자산**으로만 유지한다.
- `subnet`, DNS, resolver, VPN, peering, VM 등 non-AVM 모듈은 strict 정책에서 **Deferred** 대상으로 분리한다.
- `as-is`는 **현재 작성된 Terraform 코드가 만들려는 리소스와 연결 관계**를 기준으로 본다.
- `to-be`는 **기존 큰 복합 모듈 이름**이 아니라 **실제 Azure 리소스 유형과 배포 경계**를 기준으로 다시 나눈다.
- 지나치게 세분화된 리소스 관리는 피하고, **사용자가 최종 판단할 수 있는 수준의 계층**까지만 매핑한다.
- 단, **Compute는 서버 1대가 실제 배포 경계**이므로 `compute/<server-name>/` 리프에서 **VM + 전용 NIC + 전용 OS/Data Disk**를 함께 관리할 수 있다.
- 이 경우 공동 모듈도 `virtual-machine` 안에서 **VM AVM + NIC AVM + Disk AVM**을 조합할 수 있도록 정리하고, Compute 구현 시 이 기준을 필수로 반영한다.

## 3. 전체 스택 강제 규칙

아래 규칙은 **모든 스택**이 반드시 지킨다.

- 상위 디렉토리는 **리소스 종류**로 나눈다.
- 리프 디렉토리는 **리소스명**으로 만든다.
- 각 리프는 **자기 이름에 해당하는 리소스만** 관리한다.
- 역할·해석·추상화 이름의 디렉토리(예: `security-extension`, `common-extra`)는 만들지 않는다.
- 보안 리소스와 컴퓨트 리소스도 예외 없이 **자기 리소스 종류 아래, 자기 리소스명 리프**에서 관리한다.
- NSG, ASG, rule, association 같은 리소스도 `network-security-group/<name>`, `application-security-group/<name>`처럼 **자기 리소스 기준**으로 분리한다.
- 현재 남아 있는 `shared`, `workload`, `spoke-subnet-nsg` 같은 **legacy 리프명은 정리 대상**으로 본다.
- 단, **Compute 리프명은 서버명**을 기준으로 하며, 해당 서버 전용 NIC / OS Disk / Data Disk는 **같은 리프에서 함께 관리 가능**하다.

예:

- `vnet/hub-vnet/`은 `hub-vnet` 관련 리소스만 관리
- `subnet/hub-pep-subnet/`은 `hub-pep-subnet` 관련 리소스만 관리
- `compute/linux-monitoring-vm/`은 `linux-monitoring-vm` 관련 리소스만 관리

## 4. 판단 요약

| 구분 | 공동 모듈에 넣는 형태 |
|------|------------------------|
| Registry AVM으로 끝까지 커버 | **Foundation 표준**: AVM-only 래퍼 (`module "avm"` + 버전 고정) |
| AVM + 소량 보강이 같은 배포 단위 | **Foundation 제외**: Deferred 또는 Deprecated로 분리 |
| 적합한 AVM 없음·계약 불일치 | **Foundation 제외**: Deferred로 분리 |

AVM 버전을 올릴 때는 Foundation AVM-only 모듈의 출력 계약을 먼저 고정하고,
Deferred 모듈은 별도 파동에서 처리한다.

## 5. 본 문서의 범위

- 현재 레포의 모듈을 **위 목표에 맞게 분류**한다 (`docs/AVM_COVERAGE.md`).
- 현재 코드의 **`as-is -> to-be` 전환 기준**과 **매핑표**를 문서화한다 (`docs/AS_IS_TO_BE_MAPPING.md`).
- 실제 코드 전환은 이 문서를 기준으로 하되, **모듈을 어느 계층에서 끊을지**는 사용자 판단을 반영한다.

## 6. 작업 순서

1. **`as-is` 인벤토리 정리**
   - 기존 Terraform 코드에서 실제로 만들려는 Azure 리소스와 참조 관계를 읽는다.
   - 기준은 **현재 모듈 이름**이 아니라 **실제 리소스 종류와 배포 의도**다.
2. **`to-be` 구조 설계**
   - 공동 모듈은 **AVM 우선 리소스 단위**로 설계한다.
   - IaC는 **리프 스택 단위**로 배포되도록 디렉터리를 구성한다.
   - 단, Compute는 `compute/<server-name>/` 기준으로 설계하고, 서버 전용 NIC / Disk는 같은 스택 경계로 본다.
3. **매핑표 작성**
   - `as-is`의 큰 모듈/스택을 `to-be`의 공동 모듈 + IaC 스택 후보로 연결한다.
   - 이때 너무 미세한 리소스 단위까지 쪼개지 않고, **판단 가능한 중간 계층**에서 멈춘다.
4. **사용자 판단 반영**
   - 매핑표에서 세분화가 과한 항목은 다시 묶고,
   - 반대로 더 분리해야 하는 항목은 세부 리소스 단위까지 확장한다.
5. **구현**
   - 확정된 매핑에 따라 `terraform-modules`와 `terraform-iac` 코드를 단계적으로 정리한다.
   - Compute 구현 시에는 `virtual-machine` 공동 모듈이 **VM / NIC / Disk 관련 AVM 모듈을 내부에서 조합**하도록 함께 수정한다.

## 6.1 1차 전환 범위

- 이번 단계의 우선 범위는 **AVM-only Foundation 모듈 정리 + `01.network`/`03.shared-services`의 in-scope 리프 정리**다.
- `01.network`에서는 `resource-group`, `vnet`, `application-security-group`, `network-security-group`, `route`, `security-policy` 리프를 우선 정리한다.
- `03.shared-services`에서는 `log-analytics` 리프를 우선 정리하고, `shared`는 strict 정책상 Deferred로 분리한다.
- `02.storage`, `04.apim`, `05.ai-services`, `06.compute`, `09.connectivity`는 strict 정책상 non-AVM 의존이 있어 이번 단계에서 **Deferred** 로 문서화한다.

## 7. 산출물

- `docs/AVM_COVERAGE.md` — 모듈별 AVM / 혼합 / azurerm-only 표
- `docs/AS_IS_TO_BE_MAPPING.md` — 현재 코드 기준 `as-is -> to-be` 매핑표
- (후속) 모듈별 `versions.tf`·AVM `version` 정합 유지, 태그로 `ref` 고정
- (후속) deprecated 복합 모듈별 state 이전 체크리스트

## 8. 완료 기준

- 팀이 **“어떤 모듈이 순수 AVM이고, 어떤 모듈이 혼합/예외인지”** 한 문서로 동의할 수 있다.
- 팀이 **“현재 코드를 어떤 계층에서 끊어 새 구조로 옮길지”** 매핑표 기준으로 합의할 수 있다.
- 팀이 **“모든 스택은 리소스 종류 → 리소스명 리프 규칙을 지킨다”** 는 점에 동의할 수 있다.
- 팀이 **“Compute는 `compute/<server-name>/`에서 서버 전용 NIC / Disk까지 함께 관리하고, 공동 모듈도 그 경계에 맞게 AVM 조합으로 정리한다”** 는 점에 동의할 수 있다.

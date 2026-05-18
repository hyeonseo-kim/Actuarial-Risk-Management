# Actuarial Risk Management

계리리스크관리 수업에서 학습한 실습 내용을 정리한 저장소입니다.  
보험계리 및 리스크 관리에서 활용되는 통계적 모형, 시뮬레이션, GLM, Bayesian GLM, GLMM 관련 R 코드를 포함하고 있습니다.

## Repository Overview

수업 실습 코드를 기반으로 다음 내용을 다룹니다.

- 보험 리스크 모형의 기초 개념
- Collective Risk Model 기반 시뮬레이션
- 정규근사를 활용한 손실분포 근사
- Generalized Linear Model(GLM)
- Likelihood function 구성 및 모형 해석
- NIMBLE을 활용한 Bayesian GLM
- Generalized Linear Mixed Model(GLMM)

## Files

| File | Description |
|---|---|
| `0923_CRM_normalapproximation_simulation.R` | Collective Risk Model과 정규근사를 활용한 시뮬레이션 실습 |
| `1014_GLM.R` | GLM의 기본 구조와 예제 실습 |
| `1021_GLM.R` | GLM 예제 확장 및 likelihood function 관련 실습 |
| `1104_Nimble_GLM.R` | NIMBLE을 활용한 Bayesian GLM 실습 |
| `1118_GLMM.R` | Generalized Linear Mixed Model(GLMM) 실습 |

## Topics Covered

### 1. Collective Risk Model

보험 포트폴리오에서 발생하는 총손실을 빈도와 심도 관점에서 모형화하고, 시뮬레이션을 통해 손실분포의 특성을 확인합니다.

### 2. Normal Approximation

총손실분포를 정규분포로 근사하여 리스크를 계산하고, 시뮬레이션 결과와 비교합니다.

### 3. Generalized Linear Model

보험 데이터 분석에서 자주 활용되는 GLM의 구조를 이해하고, 반응변수의 분포와 link function에 따른 모형 설정 방식을 학습합니다.

### 4. Bayesian GLM with NIMBLE

NIMBLE 패키지를 활용하여 Bayesian 관점에서 GLM을 구현하고, 사후분포 추정과 모형 해석을 수행합니다.

### 5. Generalized Linear Mixed Model

고정효과와 랜덤효과를 함께 고려하는 GLMM을 학습하고, 보험 및 리스크 데이터에서 이질성을 반영하는 방법을 실습합니다.

## Tools

- R
- RStudio
- NIMBLE
- GLM / GLMM related R packages

## Purpose

계리리스크관리 수업에서 배운 내용을 복습하고, 보험계리 및 리스크 분석에 필요한 통계적 모형 구현 능력을 정리하기 위해 작성되었습니다.  
각 코드는 수업 실습 내용을 기반으로 하며, 모형의 수리적 구조와 실제 R 구현 과정을 함께 이해하는 것을 목표로 합니다.

## Notes

학습 및 실습 목적의 자료입니다.  
일부 코드는 수업 자료와 실습 예제를 기반으로 작성되었으며, 실제 보험 업무나 의사결정에 바로 적용하기 위해서는 추가적인 검증과 데이터 점검이 필요합니다.

## Author

**Kim Hyeonseo**  
Undergraduate student in Statistics, with additional studies in Mathematics and Economics  
Ewha Womans University

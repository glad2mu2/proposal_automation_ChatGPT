# 전략사업그룹 AI 자동화 운영 패키지

이 패키지는 `260406 기술제안서 작성 절차서(매뉴얼) 개선방안 초안8`의 업무 흐름을 기준으로, 부서 공용 ChatGPT Business 운영에 바로 넣어 쓸 수 있는 GPT 지침, 프로젝트 운영 템플릿, 산출물 양식, 파일럿 평가표, PM용 로컬 보조 스크립트를 정리한 것입니다.

## 권장 운영 방식

1. ChatGPT Business 워크스페이스에서 부서 공용 GPT 3개를 생성합니다.
   - RFP 분석 GPT
   - 제안서 초안 Review GPT
   - 발표 Q&A GPT
2. 프로젝트별로 ChatGPT Project를 생성합니다.
   - 예: `2605_○○프로젝트_CM_RFP분석`
   - 프로젝트마다 RFP, 과업내용서, 평가기준, 현장조사/현설 보고서, 제안서 초안, 발표안, 기존 Q&A를 업로드합니다.
3. PM 또는 관리자만 로컬 Codex/Claude Code를 보조적으로 사용합니다.
   - 반복 폴더 생성, PPTX 텍스트 추출, 산출물 정리, 양식 변환 용도입니다.
   - 로컬 도구를 쓰더라도 AI 모델 호출 시 문서는 클라우드로 전달될 수 있으므로, 완전 내부망 도구로 간주하지 않습니다.

## 폴더 구성

- `gpt_instructions/`
  - GPT Builder의 Instructions 영역에 붙여넣을 지침 3종입니다.
- `project_templates/`
  - ChatGPT Project 생성 시 사용할 프로젝트 운영 지침과 업로드 체크리스트입니다.
- `output_templates/`
  - RFP 제안전략설계 체크리스트, KOM 요약, 기술지원 요청서, 제안서 리뷰, Q&A, 파일럿 평가표 양식입니다.
- `tools/`
  - PM/관리자용 PowerShell 보조 스크립트와 사용 설명서입니다.

## 도입 순서

1. `gpt_instructions`의 3개 지침을 각각 GPT Builder에 복사합니다.
2. 각 GPT의 Knowledge에 매뉴얼 PDF/PPTX와 `output_templates` 주요 양식을 올립니다.
3. 프로젝트 하나를 선정해 `project_templates/chatgpt_project_template.md`의 Project Instructions를 복사합니다.
4. 최근 완료 3건, 진행 예정 2건으로 파일럿을 진행합니다.
5. `output_templates/pilot_evaluation_scorecard.md`로 정확도와 재현성을 평가합니다.

## 최소 운영 원칙

- AI 결과물은 초안입니다. RFP 필수조건, 감점요소, 제출조건은 사람이 최종 확인합니다.
- 숫자, 법규, 공법 성능, 비용 절감률, 공기 단축률은 출처가 없으면 확정 표현을 금지합니다.
- 프로젝트별 채팅과 파일을 섞지 않습니다.
- 대외비 자료는 Business/Team급 워크스페이스에서만 처리하는 것을 기본값으로 합니다.
- RFP 분석 산출물은 `rfp_strategy_design_report.docx`를 기본으로 하며, Hidden Needs와 Win Theme가 제안서 목차/페이지 구성까지 연결되어야 합니다.
- 산출물은 매뉴얼의 핵심 방향인 구체화, 전문화, 수치화, 차별화를 기준으로 평가합니다.

## 참고 링크

- [ChatGPT Business](https://help.openai.com/en/articles/8792828)
- [Projects in ChatGPT](https://help.openai.com/en/articles/10169521-projects-in-chatgpt)
- [ChatGPT Business privacy](https://help.openai.com/en/articles/8798634-shared-links-faq-chatgpt-team-version%252525253F.zst)
- [Claude Team](https://support.anthropic.com/en/articles/9266767-what-is-the-claude-team-plan)
- [Claude Projects](https://support.anthropic.com/en/articles/9517075-what-are-projects)

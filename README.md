# Proposal Automation

삼우씨엠 전략사업그룹의 CM 용역 기술제안서 업무를 ChatGPT 기반으로 표준화하기 위한 운영 패키지입니다.

이 저장소는 다음 업무를 대상으로 합니다.

- RFP 분석
- 제안서 초안 Review
- 발표 예상 질의응답 생성
- ChatGPT GPT/Project 운영 표준화
- PM용 보조 자동화 스크립트 관리

## 주요 문서

- `ai_automation_package/guides/chatgpt_execution_guidebook.md`  
  ChatGPT를 처음 쓰는 팀원을 위한 GPT 생성, Project 생성, 운영 가이드북입니다.

- `ai_automation_package/gpt_instructions/rfp_analysis_gpt_v2.md`  
  RFP 분석 GPT 설정 지침입니다.

- `ai_automation_package/gpt_instructions/proposal_review_gpt_v2.md`  
  제안서 초안 Review GPT 설정 지침입니다.

- `ai_automation_package/gpt_instructions/presentation_qa_gpt_v2.md`  
  발표 Q&A GPT 설정 지침입니다.

- `ai_automation_package/project_templates/chatgpt_project_template_v2.md`  
  프로젝트별 ChatGPT Project 지침 템플릿입니다.

- `ai_automation_package/project_templates/gpt_builder_setup_guide_v2.md`  
  GPT Builder 설정 가이드입니다.

## 권장 운영 방식

```text
부서 공용 GPT 3개 = 반복 업무용 전문가
프로젝트별 ChatGPT Project = 실제 프로젝트 자료실과 협업 작업방
Codex 또는 Claude Code = PM/관리자용 보조 자동화 도구
```

## 보안 주의

이 GitHub 저장소에는 실제 RFP, 제안서, 발주처 자료, PDF 원본, 추출 텍스트, 내부 분석 보고서를 올리지 않습니다.

실제 프로젝트 자료는 ChatGPT Business의 프로젝트별 Project 안에서만 관리하고, 공유 범위는 해당 프로젝트 참여자로 제한합니다.


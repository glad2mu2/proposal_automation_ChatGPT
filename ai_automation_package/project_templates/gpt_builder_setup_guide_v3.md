# GPT Builder 설정 가이드 v3

이 가이드는 실제 Project 운영 중 확인된 파일 접근 이슈를 반영한 버전입니다.
GPT Builder에서 부서 공용 GPT 3개를 수정할 때 아래 v3 지침 파일을 Instructions에 붙여 넣습니다.

## 공통 기능 설정

| GPT | 웹 검색 | 캔버스 | 이미지 생성 | Code Interpreter & Data Analysis | Actions |
|---|---:|---:|---:|---:|---:|
| RFP 분석 GPT | 선택 ON | ON | OFF | ON | OFF |
| 제안서 Review GPT | OFF | ON | OFF | ON | OFF |
| 발표 Q&A GPT | OFF | ON | OFF | ON | OFF |

`.docx` 결과물을 Project 채팅에서 직접 다운로드하게 하려면 `Code Interpreter & Data Analysis`를 반드시 켭니다.

기능 구분:

- `Code Interpreter & Data Analysis`: 표 중심 Word 보고서 본문을 `.docx` 파일로 생성하는 필수 기능입니다.
- `Canvas`: 보고서 초안 문구를 길게 다듬거나 편집할 때 쓰는 선택 기능입니다.
- `Canva`: 표지, Executive Summary 이미지, 발표자료용 요약 비주얼 같은 시각 보조 산출물에만 사용합니다. RFP 분석, 제안서 Review, 발표 Q&A 본문 보고서 생성의 기본 도구로 사용하지 않습니다.

## 공통 Instructions 추가 원칙

3개 GPT 모두 아래 원칙이 포함되어야 합니다.

```text
Project 소스보다 이 채팅에 직접 첨부된 파일을 우선 기준으로 삼는다.
분석 전 실제로 읽을 수 있는 첨부 파일명, 문서 유형, OCR/텍스트 품질, 표/배점 추출 가능 여부를 먼저 확인한다.
파일을 읽을 수 없으면 추정하지 말고 "파일 확인 불가"로 표시한다.
원문 근거가 없는 내용은 "확인 필요"로 표시한다.
사용자가 보고서를 요청하면 Code Interpreter & Data Analysis를 사용해 다운로드 가능한 .docx 파일로 생성한다.
.docx 생성이 불가능하면 Word에 바로 붙여넣기 좋은 Markdown을 fallback 산출물로 제공한다.
```

## 공통 Knowledge 업로드 원칙

GPT Knowledge에는 부서 공통 자료와 표준 양식만 업로드합니다. 실제 프로젝트별 RFP, 과업지시서, 평가기준, 제안서 초안, 발표자료, 발주처 Q&A, 내부 원가자료는 GPT Knowledge가 아니라 용역별 Project와 해당 채팅에 직접 첨부합니다.

공통으로 업로드할 자료:

- `260406 기술제안서 작성 절차서(매뉴얼) 개선방안 초안8.pdf` 또는 최신 기술제안서 작성 절차서 매뉴얼

PowerPoint 원본이 더 최신이면 아래 파일을 보조로 업로드할 수 있습니다.

- `260406 기술제안서 작성 절차서(매뉴얼) 개선방안 초안8.pptx`

## 1. RFP 분석 GPT v3

### Instructions

`gpt_instructions/rfp_analysis_gpt_v3.md` 내용을 그대로 사용합니다.

### Knowledge 업로드 파일

- `output_templates/rfp_analysis_table.md`
- `output_templates/kom_summary.md`
- `output_templates/technical_support_request.md`

위 파일은 공통 매뉴얼과 함께 업로드합니다. 실제 RFP, 과업지시서, 평가기준, 입찰공고문은 GPT Knowledge가 아니라 용역별 Project와 해당 분석 채팅에 직접 첨부합니다.

### Conversation Starters

```text
이 채팅에 직접 첨부한 RFP, 과업지시서, 평가기준, 입찰공고문을 기준으로 먼저 OCR 품질을 확인하고, 분석 가능하면 RFP 제안전략설계서를 작성해줘. 평가기준/의사결정 구조, 발주자 문제 정의, Hidden Needs, 핵심 리스크, Must-win 전략과 Win Theme, 제안서 목차, 페이지 구성, 작성 가이드를 포함하고 Code Interpreter & Data Analysis를 사용해 다운로드 가능한 .docx 파일로 생성해줘. Word 결과물 파일명은 한글 없이 `rfp_strategy_design_report.docx`, `technical_support_request_draft.docx`, `technical_support_request_summary_draft.docx`로 생성해줘.
```

```text
이 채팅에 직접 첨부한 파일만 기준으로 자료 품질과 OCR 상태를 점검해줘. 실제로 읽을 수 없는 파일은 파일 확인 불가로 표시하고, RFP 제안전략 분석을 진행하지 말아줘.
```

```text
평가기준과 RFP를 기준으로 Hidden Needs, Must-win 전략, Win Theme, 기술지원 요청 Item, 발표 예상 질문 Seed를 한 번에 작성해줘.
```

## 2. 제안서 Review GPT v3

### Instructions

`gpt_instructions/proposal_review_gpt_v3.md` 내용을 그대로 사용합니다.

### Knowledge 업로드 파일

- `output_templates/proposal_review_report.md`
- `output_templates/rfp_analysis_table.md`

위 파일은 공통 매뉴얼과 함께 업로드합니다. 실제 제안서 초안, RFP, 평가기준, RFP 제안전략설계서는 GPT Knowledge가 아니라 용역별 Project와 해당 Review 채팅에 직접 첨부합니다.

### Conversation Starters

```text
이 채팅에 직접 첨부한 RFP, 평가기준, 과업지시서, 제안서 초안, RFP 제안전략설계서를 기준으로 제안서 통합 Review 보고서를 작성해줘. 평가배점 Coverage, 필수조건 누락, 감점 위험, Hidden Needs/Win Theme 반영 부족, 일반론 문장, 정량화 부족, P0/P1/P2/P3 수정사항을 포함하고 Code Interpreter & Data Analysis를 사용해 다운로드 가능한 `proposal_review_report.docx` 파일로 생성해줘.
```

```text
이 채팅에 직접 첨부한 파일을 먼저 확인하고, 읽을 수 있는 파일만 기준으로 제안서 초안의 P0/P1 수정사항을 찾아줘.
```

```text
제안서 초안에서 발표 때 공격받을 수 있는 약점을 찾아 발표 Q&A GPT로 넘길 질문 후보로 정리해줘.
```

## 3. 발표 Q&A GPT v3

### Instructions

`gpt_instructions/presentation_qa_gpt_v3.md` 내용을 그대로 사용합니다.

### Knowledge 업로드 파일

- `output_templates/presentation_qa_bank.md`

위 파일은 공통 매뉴얼과 함께 업로드합니다. 실제 최종 제안서, 발표자료, 평가기준, RFP 제안전략설계서, 제안서 Review 보고서는 GPT Knowledge가 아니라 용역별 Project와 해당 Q&A 채팅에 직접 첨부합니다.

### Conversation Starters

```text
이 채팅에 직접 첨부한 평가기준, 최종 제안서, 발표자료, RFP 제안전략설계서, 제안서 Review 보고서를 기준으로 발표 Q&A 통합 보고서를 작성해줘. 평가항목별 예상질문, Hidden Needs 기반 압박질문, 3x3 키워드, 4-Step 답변, 꼬리질문을 포함하고 Code Interpreter & Data Analysis를 사용해 다운로드 가능한 `presentation_qa_report.docx` 파일로 생성해줘.
```

```text
이 채팅에 직접 첨부한 파일을 먼저 확인하고, 발표에서 공격받을 가능성이 큰 약점 기반 압박 질문 30개를 만들어줘.
```

```text
중요 질문 20개를 골라 3x3 키워드와 60초 4-Step 모범답안으로 정리해줘.
```

## 팀 운영 규칙

1. 모든 용역별 Project는 `chatgpt_project_template_v3.md` 내용을 Project Instructions에 붙여 넣습니다.
2. 모든 분석 채팅은 필요한 원문 파일을 채팅에 직접 첨부합니다.
3. 보고서 산출물은 Code Interpreter & Data Analysis로 `.docx` 파일을 직접 생성하는 것을 기본값으로 합니다.
4. Word 산출물 파일명은 한글 없이 영문 소문자, 숫자, `_`만 사용하고 프로젝트별로 동일하게 맞춥니다.
   - `rfp_strategy_design_report.docx`
   - `technical_support_request_draft.docx`
   - `technical_support_request_summary_draft.docx`
   - `proposal_review_report.docx`
   - `presentation_qa_report.docx`
   - `final_prm_check_report.docx`
5. Canva는 표지, 요약 비주얼, 발표자료 보조 산출물에만 사용합니다.
6. `.docx` 생성이 불가능한 경우 Markdown fallback 산출물을 받고, 필요한 경우 로컬 변환기를 보조로 사용합니다.
7. 생성된 결과물은 Project 소스에 다시 업로드합니다.
8. 실제 심사 후 질문과 AI 예상 질문의 적중 여부를 기록합니다.

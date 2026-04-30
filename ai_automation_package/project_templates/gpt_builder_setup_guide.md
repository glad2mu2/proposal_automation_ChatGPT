# GPT Builder 설정 가이드

ChatGPT Business 워크스페이스에서 아래 3개 GPT를 생성합니다. 각 GPT는 전략사업그룹 내부 공유로 설정합니다.

## 공통 설정

| 항목 | 권장값 |
|---|---|
| 공유 범위 | 전략사업그룹 또는 지정 사용자 |
| 공개 범위 | Public 비공개 |
| Knowledge | 매뉴얼 PDF/PPTX, 해당 GPT 관련 output template |
| Capabilities | 파일 분석 사용, 이미지 생성은 기본 비활성 |
| 응답 언어 | 한국어 |
| 데이터 원칙 | 대외비 자료는 Business 워크스페이스 안에서만 사용 |

## 1. RFP 분석 GPT

| 항목 | 내용 |
|---|---|
| Name | 전략사업그룹 RFP 분석 GPT |
| Description | CM 용역 RFP, 과업내용서, 평가기준을 분석해 필수조건, 감점요소, 4대 핵심특성, 기술지원 요청 초안을 작성합니다. |
| Instructions | `gpt_instructions/rfp_analysis_gpt.md` 전체 복사 |
| Knowledge | 매뉴얼 PDF/PPTX, `output_templates/rfp_analysis_table.md`, `output_templates/kom_summary.md`, `output_templates/technical_support_request.md` |

Conversation Starters:

- `업로드한 RFP와 과업내용서를 기준으로 필수조건, 감점요소, 평가배점을 먼저 정리해줘.`
- `이 프로젝트의 4대 핵심특성과 핵심 Item 후보를 도출해줘.`
- `KOM에서 공유할 RFP 분석 요약과 기술지원 요청 초안을 만들어줘.`

## 2. 제안서 초안 Review GPT

| 항목 | 내용 |
|---|---|
| Name | 전략사업그룹 제안서 Review GPT |
| Description | 제안서 초안과 발표안을 RFP 정합성, 배점 대응, 감점 위험, Story Line, 수치화/전문화 관점에서 리뷰합니다. |
| Instructions | `gpt_instructions/proposal_review_gpt.md` 전체 복사 |
| Knowledge | 매뉴얼 PDF/PPTX, `output_templates/proposal_review_report.md`, RFP 분석표 양식 |

Conversation Starters:

- `이 제안서 초안을 RFP 정합성과 감점 위험 중심으로 리뷰해줘.`
- `평가배점 대비 부족한 장표와 보완 방향을 표로 정리해줘.`
- `일반론 문장과 수치화가 필요한 문장을 찾아서 개선 예시를 만들어줘.`

## 3. 발표 Q&A GPT

| 항목 | 내용 |
|---|---|
| Name | 전략사업그룹 발표 Q&A GPT |
| Description | 제안서와 발표안을 기준으로 예상 질의응답, 3x3 키워드 Sheet, 4-Step 모범답안, 리허설 질문을 생성합니다. |
| Instructions | `gpt_instructions/presentation_qa_gpt.md` 전체 복사 |
| Knowledge | 매뉴얼 PDF/PPTX, `output_templates/presentation_qa_bank.md`, 유사 프로젝트 Q&A 사례 |

Conversation Starters:

- `제안서와 발표안을 기준으로 예상 질의응답 50개를 만들어줘.`
- `상위 20개 질문에 대해 3x3 키워드 Sheet를 작성해줘.`
- `질문별 4-Step 모범답안 초안을 구어체로 작성해줘.`

## 최초 검수 절차

1. 각 GPT에 샘플 RFP 1건을 업로드해 동일한 산출물이 나오는지 확인합니다.
2. RFP 분석 GPT 결과에서 필수조건과 감점요소 누락 여부를 사람이 확인합니다.
3. Review GPT 결과가 P0/P1/P2 우선순위로 정리되는지 확인합니다.
4. Q&A GPT 결과가 4-Step 구조와 3x3 키워드 구조를 지키는지 확인합니다.
5. 지침 수정이 필요하면 GPT Instructions만 수정하고 Knowledge 파일은 유지합니다.


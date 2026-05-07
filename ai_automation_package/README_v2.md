# CM PJT 실전 반영 운영안

이 운영안은 `CM PJT_1`, `CM PJT_2`, `CM PJT_3`의 실제 RFP, 과업지시서, 평가기준, 작성 제안서를 비교하고, 실제 ChatGPT Project 운영 중 확인된 파일 접근 이슈를 반영한 버전입니다.

기존 운영안의 큰 방향은 유지하되, 실제 CM 용역 제안서에서 반복적으로 중요한 다음 요소를 GPT 운영에 추가했습니다. 2026년 샘플형 제안전략설계서 운영 기준부터 RFP 분석의 기본 산출물은 `수주전략·Win Theme 중심의 RFP 제안전략설계서`입니다.

## 핵심 변경점

1. 자료 품질 확인을 첫 단계로 둡니다.
   - 스캔 PDF, OCR 미적용 RFP, 표 추출 실패 여부를 먼저 확인합니다.
   - 텍스트 추출이 불완전하면 GPT가 확정 판단을 하지 않고, 재업로드 또는 OCR 필요 항목을 표시합니다.

2. RFP 분석은 요약이나 배점 추적표가 아니라 수주전략 설계 중심으로 운영합니다.
   - 평가항목, 배점, 제출조건, 감점요소, 인터뷰 항목을 Hidden Needs, Win Theme, 제안서 목차와 직접 연결합니다.
   - `RFP 근거 -> 발주자 의도 -> Hidden Need -> 제안서 메시지` 흐름을 표로 남깁니다.

3. 과업내용과 개선전략을 1:1로 매핑합니다.
   - RFP의 일반 과업을 그대로 반복하지 않고, 발주자 문제 정의와 Win Theme에 연결되는 개선전략으로 변환합니다.
   - 예: 공정관리 과업 -> Fast Track, 패키지 분절, 변경관리 Gate, 지연 리스크 대응.

4. Hidden Needs 분석을 필수 단계로 둡니다.
   - RFP에 명시되지 않은 발주자 불안, 평가위원이 무의식적으로 찾는 메시지, 경쟁사 대비 차별화 근거를 도출합니다.
   - 모든 Hidden Need에는 추론 근거와 제안 대응 메시지를 함께 씁니다.

5. 원가, VE, 공법, 일정은 정량화 기준으로 검토합니다.
   - 단순히 “철저히 관리”가 아니라 절감 목표, 대안 비교, 판단 기준, 책임 주체가 드러나야 합니다.
   - Min/Mid/Max 목표, Before/After, 대안 비교표를 우선 권장합니다.

6. Change/Claim Control을 별도 검토 항목으로 둡니다.
   - 민간 CM 프로젝트에서는 발주자 의사결정, 설계변경, 클레임, 증빙 관리가 심사 질문으로 이어질 가능성이 큽니다.

7. 발표 Q&A는 제안서 내용만이 아니라 평가항목, Hidden Needs, 약점에서 생성합니다.
   - 예상 질문은 좋은 내용 확인 질문보다 압박 질문, 근거 질문, 대안 질문 중심이어야 합니다.
   - 답변은 매뉴얼의 4-Step 구조와 3x3 키워드 방식으로 통일합니다.

## 바로 사용할 파일

- `gpt_instructions/rfp_analysis_gpt_v3.md`
- `gpt_instructions/proposal_review_gpt_v3.md`
- `gpt_instructions/presentation_qa_gpt_v3.md`
- `project_templates/chatgpt_project_template_v3.md`
- `project_templates/gpt_builder_setup_guide_v3.md`
- `guides/chatgpt_execution_guidebook.md`
- `guides/project_gpt_analysis_operator_guide.md`
- `guides/용역별_Project_GPT_분석_운영_가이드.docx`
- `analysis_reports/gpt_operation_improvement_from_cm_projects.md`

참고: GitHub public repo에는 실제 RFP/제안서 원본, 텍스트 추출본, 내부 분석 보고서를 올리지 않습니다. `analysis_reports`와 `reference` 폴더는 로컬 내부 검토용입니다.

## 권장 운영 순서

1. 프로젝트 자료를 ChatGPT Project 소스에 업로드해 보관합니다.
2. 실제 분석 채팅에는 필요한 원문 PDF와 이전 단계 결과물을 직접 첨부합니다.
3. `00_자료품질_OCR_확인` 채팅에서 자료 품질과 누락 파일을 먼저 확인합니다.
4. `RFP 분석 GPT v3`로 `rfp_strategy_design_report.docx`, `technical_support_request_draft.docx`, `technical_support_request_summary_draft.docx`를 생성합니다.
5. 제안서 초안 작성 후 `제안서 Review GPT v3`로 `proposal_review_report.docx`를 생성합니다.
6. 발표안 작성 전 `발표 Q&A GPT v3`로 `presentation_qa_report.docx`를 생성합니다.
7. 생성된 결과물은 Project 소스에 다시 업로드하고, 실제 심사 후 질문 적중률과 누락 항목을 기록합니다.

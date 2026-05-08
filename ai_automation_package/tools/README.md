# PM/관리자용 로컬 보조 도구

이 폴더의 스크립트는 전 직원용 자동화가 아니라, 전략사업그룹 PM 또는 관리자가 반복 작업을 줄이기 위해 사용하는 보조 도구입니다.

## 도구 목록

### New-ProjectWorkspace.ps1

프로젝트별 표준 폴더와 안내 파일을 생성합니다.

사용 예:

```powershell
.\New-ProjectWorkspace.ps1 -ProjectName "2605_○○복합시설_CM_RFP분석" -BasePath "C:\Users\cmuser\Documents\Proposal auto\projects"
```

Windows 실행 정책으로 `.ps1` 직접 실행이 막히면 아래처럼 실행합니다.

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File ".\New-ProjectWorkspace.ps1" -ProjectName "2605_○○복합시설_CM_RFP분석" -BasePath "C:\Users\cmuser\Documents\Proposal auto\projects"
```

생성 폴더:

- `00_RFP`
- `01_RFP_Strategy_Design`
- `02_KOM`
- `03_Technical_Support`
- `04_Proposal_Drafts`
- `05_Proposal_Review`
- `06_Presentation_QA`
- `07_Final_Check`
- `08_PRM`
- `99_Archive`

### Extract-PptxText.ps1

PPTX 파일에서 슬라이드별 텍스트를 Markdown으로 추출합니다. ChatGPT Project에 긴 PPT 내용을 구조화해 올릴 때 사용합니다.

사용 예:

```powershell
.\Extract-PptxText.ps1 -InputPptx "C:\path\proposal.pptx" -OutputMarkdown "C:\path\proposal_text.md"
```

Windows 실행 정책으로 `.ps1` 직접 실행이 막히면 아래처럼 실행합니다.

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File ".\Extract-PptxText.ps1" -InputPptx "C:\path\proposal.pptx" -OutputMarkdown "C:\path\proposal_text.md"
```

### New-DocxFromMarkdown.ps1

ChatGPT Project 안에서 Code Interpreter & Data Analysis로 `.docx` 파일을 직접 생성하지 못했을 때 사용하는 fallback 보조 도구입니다. Markdown 보고서 템플릿을 Word 문서로 변환하며, RFP 제안전략설계서, 제안서 Review 리포트, 발표 Q&A, 기술지원 요청서처럼 표가 많은 산출물에 맞춰 미니멀한 보고서 스타일을 적용합니다.

기본 운영에서는 Project 채팅에서 `.docx`를 직접 다운로드하고, 이 스크립트는 Markdown fallback 산출물을 받은 경우에만 사용합니다.

사용 예:

```powershell
.\New-DocxFromMarkdown.ps1 -InputPath "..\output_templates\proposal_review_report.md" -OutputPath "proposal_review_report.docx"
```

문서 제목을 직접 지정해야 할 때는 선택 파라미터 `-DocumentTitle`을 사용합니다. 생략하면 Markdown의 첫 번째 `# 제목`을 문서 제목, 머리말, 파일 메타데이터에 사용합니다.

```powershell
.\New-DocxFromMarkdown.ps1 -InputPath "report.md" -OutputPath "report.docx" -DocumentTitle "제안서 1차 Review 리포트"
```

좋은 표 작성을 위한 Markdown 규칙:

- 표는 헤더 행, 구분 행, 본문 행을 연속해서 작성합니다.
- 구분 행의 `---`, `---:`, `:---:`, `:---`는 각각 기본 좌측, 우측, 중앙, 좌측 정렬로 변환됩니다.
- 긴 설명은 셀 안에 한 문장으로 압축하고, 여러 항목은 표 밖의 불릿으로 분리하면 Word에서 더 읽기 좋습니다.
- 빈 칸은 그대로 두면 Word 표의 빈 셀로 유지됩니다.

예:

```markdown
| 우선순위 | 위치 | 영향도 | 수정 방향 |
|---:|---|:---:|---|
| P0 | 3장 공정계획 | 높음 | 제출 전 근거 수치 보강 |
| P1 | 발표 Q&A | 중간 | 예상 압박질문과 답변 연결 |
```

## 주의사항

- 이 스크립트는 AI 모델을 호출하지 않습니다.
- 추출된 텍스트를 ChatGPT/Claude에 업로드하면 해당 서비스의 데이터 처리 정책이 적용됩니다.
- 대외비 자료는 부서 운영 원칙에 따라 Business/Team급 워크스페이스에서만 사용합니다.

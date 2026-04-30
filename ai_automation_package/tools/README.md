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
- `01_RFP_Analysis`
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

## 주의사항

- 이 스크립트는 AI 모델을 호출하지 않습니다.
- 추출된 텍스트를 ChatGPT/Claude에 업로드하면 해당 서비스의 데이터 처리 정책이 적용됩니다.
- 대외비 자료는 부서 운영 원칙에 따라 Business/Team급 워크스페이스에서만 사용합니다.

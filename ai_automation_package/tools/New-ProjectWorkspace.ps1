param(
    [Parameter(Mandatory = $true)]
    [string]$ProjectName,

    [Parameter(Mandatory = $false)]
    [string]$BasePath = ".",

    [switch]$Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$invalidChars = [System.IO.Path]::GetInvalidFileNameChars()
foreach ($char in $invalidChars) {
    if ($ProjectName.Contains($char)) {
        throw "ProjectName contains an invalid file name character: '$char'"
    }
}

$resolvedBase = Resolve-Path -LiteralPath $BasePath
$projectPath = Join-Path -Path $resolvedBase -ChildPath $ProjectName

if ((Test-Path -LiteralPath $projectPath) -and -not $Force) {
    throw "Project folder already exists. Use -Force to continue: $projectPath"
}

$folders = @(
    "00_RFP",
    "01_RFP_Strategy_Design",
    "02_KOM",
    "03_Technical_Support",
    "04_Proposal_Drafts",
    "05_Proposal_Review",
    "06_Presentation_QA",
    "07_Final_Check",
    "08_PRM",
    "99_Archive"
)

New-Item -ItemType Directory -Path $projectPath -Force | Out-Null

foreach ($folder in $folders) {
    New-Item -ItemType Directory -Path (Join-Path -Path $projectPath -ChildPath $folder) -Force | Out-Null
}

$readme = @"
# $ProjectName

## Project 운영 원칙

- ChatGPT Project 이름과 이 로컬 폴더명을 동일하게 유지합니다.
- 하나의 입찰/제안 프로젝트 자료만 보관합니다.
- RFP, 과업내용서, 평가기준, 제출조건, 감점요소는 `00_RFP`에 보관합니다.
- AI 산출물은 검토 후 해당 단계 폴더에 저장합니다.
- 최종 제출 조건과 감점요소는 사람이 최종 확인합니다.

## 폴더 용도

| 폴더 | 용도 |
|---|---|
| 00_RFP | 공고문, RFP, 과업내용서, 평가기준 |
| 01_RFP_Strategy_Design | RFP 제안전략설계서, Hidden Needs, Win Theme, 4대 핵심특성 |
| 02_KOM | KOM 요약자료, 회의록 |
| 03_Technical_Support | 기술지원 요청서, 분야별 회신 |
| 04_Proposal_Drafts | 제안서 초안, 발표안 |
| 05_Proposal_Review | 1차/2차/최종 Review 리포트 |
| 06_Presentation_QA | 예상 Q&A, 키워드 Sheet, 모범답안 |
| 07_Final_Check | 최종 체크리스트, 제출 확인 |
| 08_PRM | 심사결과 분석, LL/BP |
| 99_Archive | 종료 후 보관 |

"@

Set-Content -LiteralPath (Join-Path -Path $projectPath -ChildPath "README.md") -Value $readme -Encoding UTF8

Write-Host "Created project workspace: $projectPath"

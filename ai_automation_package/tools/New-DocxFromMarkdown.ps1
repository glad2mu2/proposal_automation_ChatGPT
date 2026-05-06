param(
    [Parameter(Mandatory = $true)]
    [string]$InputPath,

    [Parameter(Mandatory = $true)]
    [string]$OutputPath
)

$ErrorActionPreference = "Stop"

function Escape-Xml {
    param([AllowNull()][string]$Text)
    if ($null -eq $Text) { return "" }
    return [System.Security.SecurityElement]::Escape($Text)
}

function New-RunXml {
    param(
        [string]$Text,
        [switch]$Bold,
        [switch]$Code
    )

    $escaped = Escape-Xml $Text
    $props = ""
    if ($Bold -or $Code) {
        $props = "<w:rPr>"
        if ($Bold) { $props += "<w:b/>" }
        if ($Code) {
            $props += "<w:rFonts w:ascii=""Consolas"" w:hAnsi=""Consolas""/>"
            $props += "<w:sz w:val=""20""/>"
        }
        $props += "</w:rPr>"
    }

    return "<w:r>$props<w:t xml:space=""preserve"">$escaped</w:t></w:r>"
}

function New-ParagraphXml {
    param(
        [string]$Text,
        [string]$Style = "Normal",
        [switch]$Bold,
        [switch]$Code
    )

    $pPr = ""
    if ($Style -ne "Normal") {
        $pPr = "<w:pPr><w:pStyle w:val=""$Style""/></w:pPr>"
    }

    $run = New-RunXml -Text $Text -Bold:$Bold -Code:$Code
    return "<w:p>$pPr$run</w:p>"
}

function Convert-MarkdownToBodyXml {
    param([string[]]$Lines)

    $body = New-Object System.Collections.Generic.List[string]
    $inCode = $false

    foreach ($line in $Lines) {
        $raw = $line.TrimEnd()

        if ($raw -match '^```') {
            $inCode = -not $inCode
            continue
        }

        if ($inCode) {
            $body.Add((New-ParagraphXml -Text $raw -Style "CodeBlock" -Code))
            continue
        }

        if ([string]::IsNullOrWhiteSpace($raw)) {
            $body.Add("<w:p/>")
            continue
        }

        if ($raw -match '^# (.+)$') {
            $body.Add((New-ParagraphXml -Text $Matches[1] -Style "Heading1" -Bold))
            continue
        }

        if ($raw -match '^## (.+)$') {
            $body.Add((New-ParagraphXml -Text $Matches[1] -Style "Heading2" -Bold))
            continue
        }

        if ($raw -match '^### (.+)$') {
            $body.Add((New-ParagraphXml -Text $Matches[1] -Style "Heading3" -Bold))
            continue
        }

        if ($raw -match '^----*$') {
            $body.Add("<w:p><w:pPr><w:pBdr><w:bottom w:val=""single"" w:sz=""6"" w:space=""1"" w:color=""auto""/></w:pBdr></w:pPr></w:p>")
            continue
        }

        if ($raw -match '^\s*[-*]\s+(.+)$') {
            $body.Add((New-ParagraphXml -Text ("• " + $Matches[1]) -Style "Normal"))
            continue
        }

        if ($raw -match '^\s*\d+\.\s+(.+)$') {
            $body.Add((New-ParagraphXml -Text $raw -Style "Normal"))
            continue
        }

        if ($raw -match '^\|?[-:\s|]+\|?\s*$') {
            continue
        }

        if ($raw -match '^\|(.+)\|$') {
            $cells = $raw.Trim('|') -split '\|'
            $text = ($cells | ForEach-Object { $_.Trim() }) -join " | "
            $body.Add((New-ParagraphXml -Text $text -Style "Normal"))
            continue
        }

        $body.Add((New-ParagraphXml -Text $raw -Style "Normal"))
    }

    return ($body -join "`n")
}

function Write-Utf8NoBom {
    param(
        [string]$Path,
        [string]$Content
    )
    $encoding = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, $Content, $encoding)
}

$resolvedInput = Resolve-Path -LiteralPath $InputPath
if ([System.IO.Path]::IsPathRooted($OutputPath)) {
    $outputFullPath = [System.IO.Path]::GetFullPath($OutputPath)
}
else {
    $outputFullPath = [System.IO.Path]::GetFullPath((Join-Path (Get-Location) $OutputPath))
}
$outputDir = Split-Path -Parent $outputFullPath
if (!(Test-Path -LiteralPath $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir | Out-Null
}

$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("docx_" + [System.Guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Path $tempRoot | Out-Null
New-Item -ItemType Directory -Path (Join-Path $tempRoot "_rels") | Out-Null
New-Item -ItemType Directory -Path (Join-Path $tempRoot "word") | Out-Null
New-Item -ItemType Directory -Path (Join-Path $tempRoot "word\_rels") | Out-Null
New-Item -ItemType Directory -Path (Join-Path $tempRoot "docProps") | Out-Null

$lines = Get-Content -LiteralPath $resolvedInput -Encoding UTF8
$bodyXml = Convert-MarkdownToBodyXml -Lines $lines

$documentXml = @"
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
  <w:body>
    $bodyXml
    <w:sectPr>
      <w:pgSz w:w="11906" w:h="16838"/>
      <w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/>
    </w:sectPr>
  </w:body>
</w:document>
"@

$stylesXml = @"
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:styles xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
  <w:style w:type="paragraph" w:default="1" w:styleId="Normal">
    <w:name w:val="Normal"/>
    <w:qFormat/>
    <w:rPr>
      <w:rFonts w:ascii="Arial" w:hAnsi="Arial" w:eastAsia="Malgun Gothic"/>
      <w:sz w:val="21"/>
    </w:rPr>
    <w:pPr>
      <w:spacing w:after="120" w:line="276" w:lineRule="auto"/>
    </w:pPr>
  </w:style>
  <w:style w:type="paragraph" w:styleId="Heading1">
    <w:name w:val="heading 1"/>
    <w:basedOn w:val="Normal"/>
    <w:next w:val="Normal"/>
    <w:qFormat/>
    <w:pPr><w:spacing w:before="360" w:after="180"/></w:pPr>
    <w:rPr><w:b/><w:sz w:val="32"/></w:rPr>
  </w:style>
  <w:style w:type="paragraph" w:styleId="Heading2">
    <w:name w:val="heading 2"/>
    <w:basedOn w:val="Normal"/>
    <w:next w:val="Normal"/>
    <w:qFormat/>
    <w:pPr><w:spacing w:before="280" w:after="140"/></w:pPr>
    <w:rPr><w:b/><w:sz w:val="26"/></w:rPr>
  </w:style>
  <w:style w:type="paragraph" w:styleId="Heading3">
    <w:name w:val="heading 3"/>
    <w:basedOn w:val="Normal"/>
    <w:next w:val="Normal"/>
    <w:qFormat/>
    <w:pPr><w:spacing w:before="220" w:after="120"/></w:pPr>
    <w:rPr><w:b/><w:sz w:val="23"/></w:rPr>
  </w:style>
  <w:style w:type="paragraph" w:styleId="CodeBlock">
    <w:name w:val="CodeBlock"/>
    <w:basedOn w:val="Normal"/>
    <w:pPr><w:spacing w:after="80"/></w:pPr>
    <w:rPr><w:rFonts w:ascii="Consolas" w:hAnsi="Consolas"/><w:sz w:val="19"/></w:rPr>
  </w:style>
</w:styles>
"@

$contentTypesXml = @"
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
  <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
  <Default Extension="xml" ContentType="application/xml"/>
  <Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/>
  <Override PartName="/word/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.styles+xml"/>
  <Override PartName="/docProps/core.xml" ContentType="application/vnd.openxmlformats-package.core-properties+xml"/>
  <Override PartName="/docProps/app.xml" ContentType="application/vnd.openxmlformats-officedocument.extended-properties+xml"/>
</Types>
"@

$relsXml = @"
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/>
  <Relationship Id="rId2" Type="http://schemas.openxmlformats.org/package/2006/relationships/metadata/core-properties" Target="docProps/core.xml"/>
  <Relationship Id="rId3" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/extended-properties" Target="docProps/app.xml"/>
</Relationships>
"@

$documentRelsXml = @"
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/>
</Relationships>
"@

$coreXml = @"
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<cp:coreProperties xmlns:cp="http://schemas.openxmlformats.org/package/2006/metadata/core-properties" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <dc:title>Markdown Document</dc:title>
  <dc:creator>Markdown DOCX Converter</dc:creator>
  <cp:lastModifiedBy>Codex</cp:lastModifiedBy>
  <dcterms:created xsi:type="dcterms:W3CDTF">2026-05-06T00:00:00Z</dcterms:created>
  <dcterms:modified xsi:type="dcterms:W3CDTF">2026-05-06T00:00:00Z</dcterms:modified>
</cp:coreProperties>
"@

$appXml = @"
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Properties xmlns="http://schemas.openxmlformats.org/officeDocument/2006/extended-properties" xmlns:vt="http://schemas.openxmlformats.org/officeDocument/2006/docPropsVTypes">
  <Application>Codex</Application>
</Properties>
"@

Write-Utf8NoBom -Path (Join-Path $tempRoot "[Content_Types].xml") -Content $contentTypesXml
Write-Utf8NoBom -Path (Join-Path $tempRoot "_rels\.rels") -Content $relsXml
Write-Utf8NoBom -Path (Join-Path $tempRoot "word\document.xml") -Content $documentXml
Write-Utf8NoBom -Path (Join-Path $tempRoot "word\styles.xml") -Content $stylesXml
Write-Utf8NoBom -Path (Join-Path $tempRoot "word\_rels\document.xml.rels") -Content $documentRelsXml
Write-Utf8NoBom -Path (Join-Path $tempRoot "docProps\core.xml") -Content $coreXml
Write-Utf8NoBom -Path (Join-Path $tempRoot "docProps\app.xml") -Content $appXml

if (Test-Path -LiteralPath $outputFullPath) {
    Remove-Item -LiteralPath $outputFullPath -Force
}

Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem
$zip = [System.IO.Compression.ZipFile]::Open($outputFullPath, [System.IO.Compression.ZipArchiveMode]::Create)
try {
    Get-ChildItem -Path $tempRoot -Recurse -File | ForEach-Object {
        $relative = $_.FullName.Substring($tempRoot.Length + 1).Replace('\', '/')
        [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zip, $_.FullName, $relative, [System.IO.Compression.CompressionLevel]::Optimal) | Out-Null
    }
}
finally {
    $zip.Dispose()
    Remove-Item -LiteralPath $tempRoot -Recurse -Force
}

Write-Host "Created $outputFullPath"

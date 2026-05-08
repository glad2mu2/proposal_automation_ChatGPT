param(
    [Parameter(Mandatory = $true)]
    [string]$InputPath,

    [Parameter(Mandatory = $true)]
    [string]$OutputPath,

    [string]$DocumentTitle
)

$ErrorActionPreference = "Stop"

function Escape-Xml {
    param([AllowNull()][string]$Text)
    if ($null -eq $Text) { return "" }
    return [System.Security.SecurityElement]::Escape($Text)
}

function Get-DocumentTitle {
    param(
        [string[]]$Lines,
        [AllowNull()][string]$Override
    )

    if (![string]::IsNullOrWhiteSpace($Override)) {
        return $Override.Trim()
    }

    foreach ($line in $Lines) {
        if ($line -match '^#\s+(.+)$') {
            return $Matches[1].Trim()
        }
    }

    return "Markdown Document"
}

function New-RunXml {
    param(
        [string]$Text,
        [switch]$Bold,
        [switch]$Code,
        [string]$Size,
        [string]$Color
    )

    $escaped = Escape-Xml $Text
    $runProps = New-Object System.Collections.Generic.List[string]

    if ($Bold) {
        $runProps.Add("<w:b/>")
    }

    if ($Code) {
        $runProps.Add("<w:rFonts w:ascii=""Consolas"" w:hAnsi=""Consolas""/>")
        $runProps.Add("<w:sz w:val=""20""/>")
    }

    if (![string]::IsNullOrWhiteSpace($Size)) {
        $runProps.Add("<w:sz w:val=""$Size""/>")
    }

    if (![string]::IsNullOrWhiteSpace($Color)) {
        $runProps.Add("<w:color w:val=""$Color""/>")
    }

    $props = ""
    if ($runProps.Count -gt 0) {
        $props = "<w:rPr>$($runProps -join '')</w:rPr>"
    }

    return "<w:r>$props<w:t xml:space=""preserve"">$escaped</w:t></w:r>"
}

function New-ParagraphPropertiesXml {
    param(
        [string]$Style = "Normal",
        [string]$Align,
        [int]$LeftIndent = 0,
        [int]$HangingIndent = 0
    )

    $props = New-Object System.Collections.Generic.List[string]

    if ($Style -ne "Normal") {
        $props.Add("<w:pStyle w:val=""$Style""/>")
    }

    if (![string]::IsNullOrWhiteSpace($Align)) {
        $props.Add("<w:jc w:val=""$Align""/>")
    }

    if ($LeftIndent -gt 0 -or $HangingIndent -gt 0) {
        $indent = "<w:ind"
        if ($LeftIndent -gt 0) { $indent += " w:left=""$LeftIndent""" }
        if ($HangingIndent -gt 0) { $indent += " w:hanging=""$HangingIndent""" }
        $indent += "/>"
        $props.Add($indent)
    }

    if ($props.Count -eq 0) {
        return ""
    }

    return "<w:pPr>$($props -join '')</w:pPr>"
}

function New-ParagraphXml {
    param(
        [string]$Text,
        [string]$Style = "Normal",
        [switch]$Bold,
        [switch]$Code,
        [string]$Align,
        [int]$LeftIndent = 0,
        [int]$HangingIndent = 0
    )

    $pPr = New-ParagraphPropertiesXml -Style $Style -Align $Align -LeftIndent $LeftIndent -HangingIndent $HangingIndent
    $run = New-RunXml -Text $Text -Bold:$Bold -Code:$Code
    return "<w:p>$pPr$run</w:p>"
}

function Get-MarkdownTableCells {
    param([string]$Line)

    $trimmed = $Line.Trim()
    if ($trimmed.StartsWith("|")) {
        $trimmed = $trimmed.Substring(1)
    }
    if ($trimmed.EndsWith("|")) {
        $trimmed = $trimmed.Substring(0, $trimmed.Length - 1)
    }

    return @($trimmed -split '\|' | ForEach-Object { $_.Trim() })
}

function Test-MarkdownTableDivider {
    param([string]$Line)

    if ($Line -notmatch '\|') {
        return $false
    }

    $cells = Get-MarkdownTableCells -Line $Line
    if ($cells.Count -eq 0) {
        return $false
    }

    foreach ($cell in $cells) {
        $marker = $cell -replace '\s', ''
        if ($marker -notmatch '^:?-{3,}:?$') {
            return $false
        }
    }

    return $true
}

function Get-MarkdownTableAlignments {
    param([string]$DividerLine)

    $alignments = New-Object System.Collections.Generic.List[string]
    $cells = Get-MarkdownTableCells -Line $DividerLine

    foreach ($cell in $cells) {
        $marker = ($cell -replace '\s', '')
        if ($marker.StartsWith(":") -and $marker.EndsWith(":")) {
            $alignments.Add("center")
        }
        elseif ($marker.EndsWith(":")) {
            $alignments.Add("right")
        }
        else {
            $alignments.Add("left")
        }
    }

    return @($alignments)
}

function New-TableCellXml {
    param(
        [AllowNull()][string]$Text,
        [string]$Align = "left",
        [switch]$Header
    )

    $style = "TableText"
    $shading = ""
    if ($Header) {
        $style = "TableHeader"
        $shading = "<w:shd w:val=""clear"" w:color=""auto"" w:fill=""F3F4F6""/>"
    }

    $tcPr = "<w:tcPr><w:tcW w:w=""0"" w:type=""auto""/>$shading</w:tcPr>"
    $paragraph = New-ParagraphXml -Text $Text -Style $style -Align $Align
    return "<w:tc>$tcPr$paragraph</w:tc>"
}

function New-TableXml {
    param(
        [object[]]$Rows,
        [string[]]$Alignments
    )

    $columnCount = 0
    foreach ($row in $Rows) {
        if ($row.Count -gt $columnCount) {
            $columnCount = $row.Count
        }
    }

    if ($columnCount -eq 0) {
        return ""
    }

    $gridWidth = [Math]::Floor(9600 / $columnCount)
    $gridColumns = New-Object System.Collections.Generic.List[string]
    for ($column = 0; $column -lt $columnCount; $column++) {
        $gridColumns.Add("<w:gridCol w:w=""$gridWidth""/>")
    }

    $table = New-Object System.Collections.Generic.List[string]
    $table.Add("<w:tbl>")
    $table.Add("<w:tblPr>")
    $table.Add("<w:tblW w:w=""5000"" w:type=""pct""/>")
    $table.Add("<w:tblLayout w:type=""autofit""/>")
    $table.Add("<w:tblCellMar><w:top w:w=""80"" w:type=""dxa""/><w:left w:w=""100"" w:type=""dxa""/><w:bottom w:w=""80"" w:type=""dxa""/><w:right w:w=""100"" w:type=""dxa""/></w:tblCellMar>")
    $table.Add("<w:tblBorders><w:top w:val=""single"" w:sz=""4"" w:space=""0"" w:color=""D9DEE7""/><w:left w:val=""single"" w:sz=""4"" w:space=""0"" w:color=""D9DEE7""/><w:bottom w:val=""single"" w:sz=""4"" w:space=""0"" w:color=""D9DEE7""/><w:right w:val=""single"" w:sz=""4"" w:space=""0"" w:color=""D9DEE7""/><w:insideH w:val=""single"" w:sz=""4"" w:space=""0"" w:color=""D9DEE7""/><w:insideV w:val=""single"" w:sz=""4"" w:space=""0"" w:color=""D9DEE7""/></w:tblBorders>")
    $table.Add("</w:tblPr>")
    $table.Add("<w:tblGrid>$($gridColumns -join '')</w:tblGrid>")

    for ($rowIndex = 0; $rowIndex -lt $Rows.Count; $rowIndex++) {
        $isHeader = ($rowIndex -eq 0)
        $rowPr = "<w:trPr><w:cantSplit/>"
        if ($isHeader) {
            $rowPr += "<w:tblHeader/>"
        }
        $rowPr += "</w:trPr>"

        $table.Add("<w:tr>$rowPr")
        $row = $Rows[$rowIndex]
        for ($columnIndex = 0; $columnIndex -lt $columnCount; $columnIndex++) {
            $text = ""
            if ($columnIndex -lt $row.Count) {
                $text = $row[$columnIndex]
            }

            $alignment = "left"
            if ($columnIndex -lt $Alignments.Count) {
                $alignment = $Alignments[$columnIndex]
            }

            $table.Add((New-TableCellXml -Text $text -Align $alignment -Header:$isHeader))
        }
        $table.Add("</w:tr>")
    }

    $table.Add("</w:tbl>")
    return ($table -join "`n")
}

function Convert-MarkdownToBodyXml {
    param([string[]]$Lines)

    $body = New-Object System.Collections.Generic.List[string]
    $inCode = $false
    $index = 0

    while ($index -lt $Lines.Count) {
        $raw = $Lines[$index].TrimEnd()

        if ($raw -match '^```') {
            $inCode = -not $inCode
            $index++
            continue
        }

        if ($inCode) {
            $body.Add((New-ParagraphXml -Text $raw -Style "CodeBlock" -Code))
            $index++
            continue
        }

        if ([string]::IsNullOrWhiteSpace($raw)) {
            $body.Add("<w:p/>")
            $index++
            continue
        }

        if (
            $raw -match '\|' -and
            ($index + 1) -lt $Lines.Count -and
            (Test-MarkdownTableDivider -Line $Lines[$index + 1])
        ) {
            $rows = New-Object System.Collections.Generic.List[object]
            $rows.Add((Get-MarkdownTableCells -Line $raw))
            $alignments = Get-MarkdownTableAlignments -DividerLine $Lines[$index + 1]
            $index += 2

            while ($index -lt $Lines.Count) {
                $tableLine = $Lines[$index].TrimEnd()
                if ([string]::IsNullOrWhiteSpace($tableLine) -or $tableLine -notmatch '\|') {
                    break
                }
                if (!(Test-MarkdownTableDivider -Line $tableLine)) {
                    $rows.Add((Get-MarkdownTableCells -Line $tableLine))
                }
                $index++
            }

            $body.Add((New-TableXml -Rows $rows.ToArray() -Alignments $alignments))
            continue
        }

        if ($raw -match '^#\s+(.+)$') {
            $body.Add((New-ParagraphXml -Text $Matches[1] -Style "Heading1" -Bold))
            $index++
            continue
        }

        if ($raw -match '^##\s+(.+)$') {
            $body.Add((New-ParagraphXml -Text $Matches[1] -Style "Heading2" -Bold))
            $index++
            continue
        }

        if ($raw -match '^###\s+(.+)$') {
            $body.Add((New-ParagraphXml -Text $Matches[1] -Style "Heading3" -Bold))
            $index++
            continue
        }

        if ($raw -match '^----*$') {
            $body.Add("<w:p><w:pPr><w:pBdr><w:bottom w:val=""single"" w:sz=""6"" w:space=""1"" w:color=""D1D5DB""/></w:pBdr></w:pPr></w:p>")
            $index++
            continue
        }

        if ($raw -match '^\s*[-*]\s+(.+)$') {
            $body.Add((New-ParagraphXml -Text ("• " + $Matches[1]) -Style "Bullet" -LeftIndent 360 -HangingIndent 180))
            $index++
            continue
        }

        if ($raw -match '^\s*\d+\.\s+(.+)$') {
            $body.Add((New-ParagraphXml -Text $raw -Style "Numbered" -LeftIndent 360 -HangingIndent 180))
            $index++
            continue
        }

        if ($raw -match '^\|?[-:\s|]+\|?\s*$') {
            $index++
            continue
        }

        $body.Add((New-ParagraphXml -Text $raw -Style "Normal"))
        $index++
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

$lines = Get-Content -LiteralPath $resolvedInput -Encoding UTF8
$effectiveDocumentTitle = Get-DocumentTitle -Lines $lines -Override $DocumentTitle
$escapedDocumentTitle = Escape-Xml $effectiveDocumentTitle
$bodyXml = Convert-MarkdownToBodyXml -Lines $lines
$documentTimestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")

$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("docx_" + [System.Guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Path $tempRoot | Out-Null
New-Item -ItemType Directory -Path (Join-Path $tempRoot "_rels") | Out-Null
New-Item -ItemType Directory -Path (Join-Path $tempRoot "word") | Out-Null
New-Item -ItemType Directory -Path (Join-Path $tempRoot "word\_rels") | Out-Null
New-Item -ItemType Directory -Path (Join-Path $tempRoot "docProps") | Out-Null

$documentXml = @"
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">
  <w:body>
    $bodyXml
    <w:sectPr>
      <w:headerReference w:type="default" r:id="rId2"/>
      <w:footerReference w:type="default" r:id="rId3"/>
      <w:pgSz w:w="11906" w:h="16838"/>
      <w:pgMar w:top="1276" w:right="1134" w:bottom="1276" w:left="1134" w:header="708" w:footer="708" w:gutter="0"/>
    </w:sectPr>
  </w:body>
</w:document>
"@

$stylesXml = @"
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:styles xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
  <w:docDefaults>
    <w:rPrDefault>
      <w:rPr>
        <w:rFonts w:ascii="Malgun Gothic" w:hAnsi="Malgun Gothic" w:eastAsia="Malgun Gothic"/>
        <w:sz w:val="21"/>
        <w:color w:val="222831"/>
      </w:rPr>
    </w:rPrDefault>
  </w:docDefaults>
  <w:style w:type="paragraph" w:default="1" w:styleId="Normal">
    <w:name w:val="Normal"/>
    <w:qFormat/>
    <w:rPr>
      <w:rFonts w:ascii="Malgun Gothic" w:hAnsi="Malgun Gothic" w:eastAsia="Malgun Gothic"/>
      <w:sz w:val="21"/>
      <w:color w:val="222831"/>
    </w:rPr>
    <w:pPr>
      <w:spacing w:after="100" w:line="324" w:lineRule="auto"/>
    </w:pPr>
  </w:style>
  <w:style w:type="paragraph" w:styleId="Heading1">
    <w:name w:val="heading 1"/>
    <w:basedOn w:val="Normal"/>
    <w:next w:val="Normal"/>
    <w:qFormat/>
    <w:pPr>
      <w:spacing w:before="260" w:after="180"/>
      <w:pBdr><w:bottom w:val="single" w:sz="8" w:space="6" w:color="1F4E79"/></w:pBdr>
    </w:pPr>
    <w:rPr>
      <w:b/>
      <w:color w:val="1F4E79"/>
      <w:sz w:val="30"/>
    </w:rPr>
  </w:style>
  <w:style w:type="paragraph" w:styleId="Heading2">
    <w:name w:val="heading 2"/>
    <w:basedOn w:val="Normal"/>
    <w:next w:val="Normal"/>
    <w:qFormat/>
    <w:pPr><w:spacing w:before="220" w:after="110"/></w:pPr>
    <w:rPr>
      <w:b/>
      <w:color w:val="374151"/>
      <w:sz w:val="25"/>
    </w:rPr>
  </w:style>
  <w:style w:type="paragraph" w:styleId="Heading3">
    <w:name w:val="heading 3"/>
    <w:basedOn w:val="Normal"/>
    <w:next w:val="Normal"/>
    <w:qFormat/>
    <w:pPr><w:spacing w:before="180" w:after="90"/></w:pPr>
    <w:rPr>
      <w:b/>
      <w:color w:val="4B5563"/>
      <w:sz w:val="22"/>
    </w:rPr>
  </w:style>
  <w:style w:type="paragraph" w:styleId="Bullet">
    <w:name w:val="Bullet"/>
    <w:basedOn w:val="Normal"/>
    <w:pPr>
      <w:spacing w:after="60" w:line="300" w:lineRule="auto"/>
      <w:ind w:left="360" w:hanging="180"/>
    </w:pPr>
  </w:style>
  <w:style w:type="paragraph" w:styleId="Numbered">
    <w:name w:val="Numbered"/>
    <w:basedOn w:val="Normal"/>
    <w:pPr>
      <w:spacing w:after="60" w:line="300" w:lineRule="auto"/>
      <w:ind w:left="360" w:hanging="180"/>
    </w:pPr>
  </w:style>
  <w:style w:type="paragraph" w:styleId="TableHeader">
    <w:name w:val="TableHeader"/>
    <w:basedOn w:val="Normal"/>
    <w:pPr><w:spacing w:after="0" w:line="260" w:lineRule="auto"/></w:pPr>
    <w:rPr>
      <w:b/>
      <w:color w:val="111827"/>
      <w:sz w:val="19"/>
    </w:rPr>
  </w:style>
  <w:style w:type="paragraph" w:styleId="TableText">
    <w:name w:val="TableText"/>
    <w:basedOn w:val="Normal"/>
    <w:pPr><w:spacing w:after="0" w:line="260" w:lineRule="auto"/></w:pPr>
    <w:rPr>
      <w:color w:val="222831"/>
      <w:sz w:val="19"/>
    </w:rPr>
  </w:style>
  <w:style w:type="paragraph" w:styleId="CodeBlock">
    <w:name w:val="CodeBlock"/>
    <w:basedOn w:val="Normal"/>
    <w:pPr>
      <w:spacing w:before="60" w:after="80" w:line="260" w:lineRule="auto"/>
      <w:shd w:val="clear" w:color="auto" w:fill="F6F8FA"/>
    </w:pPr>
    <w:rPr>
      <w:rFonts w:ascii="Consolas" w:hAnsi="Consolas"/>
      <w:sz w:val="19"/>
      <w:color w:val="374151"/>
    </w:rPr>
  </w:style>
  <w:style w:type="paragraph" w:styleId="Header">
    <w:name w:val="header"/>
    <w:basedOn w:val="Normal"/>
    <w:pPr>
      <w:spacing w:after="0"/>
      <w:pBdr><w:bottom w:val="single" w:sz="4" w:space="4" w:color="E5E7EB"/></w:pBdr>
    </w:pPr>
    <w:rPr>
      <w:color w:val="6B7280"/>
      <w:sz w:val="18"/>
    </w:rPr>
  </w:style>
  <w:style w:type="paragraph" w:styleId="Footer">
    <w:name w:val="footer"/>
    <w:basedOn w:val="Normal"/>
    <w:pPr>
      <w:spacing w:after="0"/>
      <w:jc w:val="center"/>
    </w:pPr>
    <w:rPr>
      <w:color w:val="6B7280"/>
      <w:sz w:val="18"/>
    </w:rPr>
  </w:style>
</w:styles>
"@

$headerXml = @"
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:hdr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
  <w:p>
    <w:pPr><w:pStyle w:val="Header"/></w:pPr>
    <w:r><w:t xml:space="preserve">$escapedDocumentTitle</w:t></w:r>
  </w:p>
</w:hdr>
"@

$footerXml = @"
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
  <w:p>
    <w:pPr><w:pStyle w:val="Footer"/><w:jc w:val="center"/></w:pPr>
    <w:r><w:t xml:space="preserve">Page </w:t></w:r>
    <w:r><w:fldChar w:fldCharType="begin"/></w:r>
    <w:r><w:instrText xml:space="preserve">PAGE</w:instrText></w:r>
    <w:r><w:fldChar w:fldCharType="end"/></w:r>
  </w:p>
</w:ftr>
"@

$contentTypesXml = @"
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
  <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
  <Default Extension="xml" ContentType="application/xml"/>
  <Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/>
  <Override PartName="/word/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.styles+xml"/>
  <Override PartName="/word/header1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.header+xml"/>
  <Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml"/>
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
  <Relationship Id="rId2" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/header" Target="header1.xml"/>
  <Relationship Id="rId3" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Target="footer1.xml"/>
</Relationships>
"@

$coreXml = @"
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<cp:coreProperties xmlns:cp="http://schemas.openxmlformats.org/package/2006/metadata/core-properties" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <dc:title>$escapedDocumentTitle</dc:title>
  <dc:creator>Markdown DOCX Converter</dc:creator>
  <cp:lastModifiedBy>Codex</cp:lastModifiedBy>
  <dcterms:created xsi:type="dcterms:W3CDTF">$documentTimestamp</dcterms:created>
  <dcterms:modified xsi:type="dcterms:W3CDTF">$documentTimestamp</dcterms:modified>
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
Write-Utf8NoBom -Path (Join-Path $tempRoot "word\header1.xml") -Content $headerXml
Write-Utf8NoBom -Path (Join-Path $tempRoot "word\footer1.xml") -Content $footerXml
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

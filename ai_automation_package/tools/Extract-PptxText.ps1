param(
    [Parameter(Mandatory = $true)]
    [string]$InputPptx,

    [Parameter(Mandatory = $true)]
    [string]$OutputMarkdown
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$inputPath = Resolve-Path -LiteralPath $InputPptx
$outputParent = Split-Path -Parent $OutputMarkdown
if ($outputParent -and -not (Test-Path -LiteralPath $outputParent)) {
    New-Item -ItemType Directory -Path $outputParent -Force | Out-Null
}

Add-Type -AssemblyName System.IO.Compression.FileSystem

$zip = [System.IO.Compression.ZipFile]::OpenRead($inputPath)
try {
    $slideEntries = $zip.Entries |
        Where-Object { $_.FullName -match '^ppt/slides/slide\d+\.xml$' } |
        Sort-Object { [int]([regex]::Match($_.FullName, 'slide(\d+)\.xml').Groups[1].Value) }

    $lines = New-Object System.Collections.Generic.List[string]
    $lines.Add("# PPTX Text Extract")
    $lines.Add("")
    $lines.Add("- Source: $inputPath")
    $lines.Add("- Slide count: $($slideEntries.Count)")
    $lines.Add("")

    foreach ($entry in $slideEntries) {
        $slideNumber = [int]([regex]::Match($entry.FullName, 'slide(\d+)\.xml').Groups[1].Value)
        $stream = $entry.Open()
        $reader = New-Object System.IO.StreamReader($stream)
        try {
            $xmlText = $reader.ReadToEnd()
        }
        finally {
            $reader.Close()
            $stream.Close()
        }

        [xml]$xml = $xmlText
        $ns = New-Object System.Xml.XmlNamespaceManager($xml.NameTable)
        $ns.AddNamespace("a", "http://schemas.openxmlformats.org/drawingml/2006/main")

        $texts = @(
            $xml.SelectNodes("//a:t", $ns) |
                ForEach-Object { $_.InnerText } |
                Where-Object { $_ -and $_.Trim().Length -gt 0 }
        )

        $lines.Add("## Slide $slideNumber")
        $lines.Add("")
        if ($texts.Count -eq 0) {
            $lines.Add("_No text extracted._")
        }
        else {
            $joined = (($texts -join " ") -replace '\s+', ' ').Trim()
            if ($joined.Length -gt 0) {
                $lines.Add($joined)
            }
        }
        $lines.Add("")
    }

    Set-Content -LiteralPath $OutputMarkdown -Value $lines -Encoding UTF8
}
finally {
    $zip.Dispose()
}

Write-Host "Extracted PPTX text to: $OutputMarkdown"

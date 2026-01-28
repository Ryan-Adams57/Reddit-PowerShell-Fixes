<#
.SYNOPSIS
Efficiently enumerate and process files in a directory with minimal overhead.

.DESCRIPTION
This script:
 • Uses .NET file enumeration (optional) for faster traversal on large folders.
 • Processes file metadata without repeatedly calling Get-Item.
 • Outputs and logs results to a CSV if needed.
 • Avoids unnecessary pipeline overhead.

.PARAMETER RootPath
The root directory to scan.

.PARAMETER UseDotNetEnumeration
If set, uses .NET System.IO.Directory enumeration for performance.

.PARAMETER Action
A script block that defines what to do with each file.

.PARAMETER OutputCsv
Optional output path to save results.

.EXAMPLE
.\Get‑FilesWithFastEnumeration.ps1 -RootPath "D:\Data" -Action { $_.LastWriteTime } -UseDotNetEnumeration

.EXAMPLE
.\Get‑FilesWithFastEnumeration.ps1 -RootPath "D:\Data" -OutputCsv "D:\results.csv" -Action { $_.FullName, $_.LastWriteTime }

#>

param(
    [Parameter(Mandatory=$true)]
    [string]$RootPath,

    [switch]$UseDotNetEnumeration,

    [Parameter(Mandatory=$true)]
    [scriptblock]$Action,

    [string]$OutputCsv
)

if (-not (Test‑Path $RootPath)) {
    Write‑Error "Directory not found: $RootPath"
    exit 1
}

Write‑Host "Starting file enumeration in $RootPath…" ‑ForegroundColor Cyan

# Choose enumeration method
if ($UseDotNetEnumeration) {
    Write‑Host "Using .NET Directory.EnumerateFiles for speed…" ‑ForegroundColor Yellow
    $files = [System.IO.Directory]::EnumerateFiles($RootPath, "*", [System.IO.SearchOption]::AllDirectories)
} else {
    Write‑Host "Using Get‑ChildItem for file enumeration…" ‑ForegroundColor Yellow
    $files = Get‑ChildItem ‑Path $RootPath ‑File ‑Recurse ‑ErrorAction SilentlyContinue
}

$result = @()

foreach ($filePath in $files) {
    try {
        # Get FileInfo only if using .NET strings
        if ($filePath -is [string]) {
            $fileInfo = Get‑Item ‑LiteralPath $filePath ‑Force
        } else {
            $fileInfo = $filePath
        }

        # Perform the user action on the file
        $output = & $Action.Invoke($fileInfo)
        if ($OutputCsv) {
            $result += [PSCustomObject]@{
                Path = $fileInfo.FullName
                Result = $output
            }
        }
    }
    catch {
        Write‑Host "Error processing $filePath: $_" ‑ForegroundColor Red
    }
}

# Save CSV if requested
if ($OutputCsv) {
    Write‑Host "Saving results to $OutputCsv…" ‑ForegroundColor Cyan
    $result | Export‑Csv ‑Path $OutputCsv ‑NoTypeInformation
}

Write‑Host "Done." ‑ForegroundColor Green

<#
.SYNOPSIS
Intune‑friendly PowerShell wrapper with enhanced logging and error handling.

.DESCRIPTION
Intune platform scripts run in System context, with limited stdout reporting.
This template:
 - Captures output to a log file.
 - Catches errors and reports them.
 - Normalizes path and context differences (32/64 bit).
 - Exposes clear exit codes for Intune success/fail reporting.

#>

# — Logging Setup
$logDir = "$env:ProgramData\IntuneScriptLogs"
if (-not (Test-Path $logDir)) { New-Item -Path $logDir -ItemType Directory | Out-Null }
$logFile = Join-Path $logDir "$(Split-Path -Leaf $PSCommandPath).log"

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $entry = "$(Get-Date -Format o) [$Level] $Message"
    Add-Content -Path $logFile -Value $entry
}

Write-Log "=== Script started under Intune context ==="

# — Explicit Working Directory
Set-Location -Path $env:SystemRoot

# — Environment Info for Troubleshooting
Write-Log "PSVersion: $($PSVersionTable.PSVersion)"
Write-Log "ProcessArch: $([Environment]::Is64BitProcess ? '64-bit' : '32-bit')"
Write-Log "User: $([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)"

try {
    # YOUR LOGIC HERE
    # Example stub:
    Write-Log "Running main logic…"
    # Simulate action
    Start-Sleep -Seconds 2
    Write-Log "Main logic completed."

    Write-Log "Script completed successfully." "SUCCESS"
    exit 0
}
catch {
    Write-Log "Error occured: $($_.Exception.Message)" "ERROR"
    Write-Log "$($_.Exception.StackTrace)" "ERROR"
    exit 1
}

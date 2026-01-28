<#
.SYNOPSIS
Configures and fixes common Invoke-Command remoting issues.

.DESCRIPTION
This script:
 • Ensures PS Remoting is enabled.
 • Configures WinRM listener & firewall rules.
 • Tests WinRM connectivity.
 • Optionally adjusts session timeout so long-running jobs don’t silently fail.
 • Outputs clear next steps if any issues remain.

.NOTES
Tested on Windows PowerShell & PowerShell 7+.

#>

# — 1) Enable PowerShell Remoting
Write-Host "⇒ Enabling PS Remoting (if not already)..." -ForegroundColor Cyan
Enable-PSRemoting -Force -ErrorAction SilentlyContinue

# — 2) Configure WinRM listeners and firewall
Write-Host "⇒ Configuring WinRM listener and firewall rules..." -ForegroundColor Cyan
winrm quickconfig -quiet
If ((Get-NetFirewallRule -DisplayName "*WINRM*" -ErrorAction SilentlyContinue) 
 -eq $null) {
    New-NetFirewallRule -Name "PowerShell Remoting (HTTP)" -DisplayName "PowerShell Remoting (HTTP)" `
        -Protocol TCP -LocalPort 5985 -Action Allow
}

# — 3) Test connectivity to the remote host
$computers = Read-Host "Enter remote computer name (or comma-separated list)"
$computers = $computers -split ",\s*" | ForEach-Object { $_.Trim() }

Foreach ($comp in $computers) {
    Write-Host "Testing WinRM on $comp..." -ForegroundColor Yellow
    try {
        Test-WsMan -ComputerName $comp -ErrorAction Stop | Out-Null
        Write-Host "✔ WinRM reachable on $comp" -ForegroundColor Green
    } catch {
        Write-Host "✘ WinRM failed on $comp — check firewall, network, DNS & remoting" -ForegroundColor Red
    }
}

# — 4) Optional: Increase default WinRM IdleTimeout to support longer tasks
$setIdle = Read-Host "Increase WinRM IdleTimeout for long sessions? (Y/N)"
If ($setIdle -match "^[Yy]") {
    Write-Host "⇒ Setting IdleTimeout to 2 hours for client & service..." -ForegroundColor Cyan
    winrm set winrm/config/Client @{IdleTimeout="7200000"}
    winrm set winrm/config/Service @{IdleTimeout="7200000"}
    Write-Host "✔ IdleTimeout updated." -ForegroundColor Green
}

Write-Host "Done. Try Invoke-Command again." -ForegroundColor Cyan

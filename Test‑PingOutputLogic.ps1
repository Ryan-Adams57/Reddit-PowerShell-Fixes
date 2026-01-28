<#
.SYNOPSIS
Run pings reliably and evaluate packet loss in a way that PowerShell logic understands.

.DESCRIPTION
PowerShell’s comparison operators (‑match, ‑like) behave differently when the left operand is an array — they return the matching elements, not a boolean. This script uses explicit boolean logic to check ping results.

PARAMETER Target
The hostname or IP address to ping.

.PARAMETER UseTestConnection
If set, uses Test‑Connection instead of invoking the external ping.exe.

.EXAMPLE
.\Test‑PingOutputLogic.ps1 -Target 8.8.8.8

.EXAMPLE
.\Test‑PingOutputLogic.ps1 -Target 192.168.1.1 -UseTestConnection
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$Target,

    [switch]$UseTestConnection
)

# Use native Test‑Connection if requested
if ($UseTestConnection) {
    Write‑Host "Using PowerShell Test‑Connection to ping $Target…" ‑ForegroundColor Cyan
    $reachable = Test‑Connection -ComputerName $Target -Count 1 -Quiet
    if ($reachable) {
        Write‑Host "$Target is reachable." ‑ForegroundColor Green
    } else {
        Write‑Host "$Target is not reachable." ‑ForegroundColor Red
    }
    exit 0
}

Write‑Host "Running ping.exe for $Target…" ‑ForegroundColor Cyan
# Capture output
$pingOutput = & ping.exe -n 4 $Target | Out‑String | Split‑Lines

# Check if any line contains “Lost” and extract lost percentage
$lossLines = $pingOutput | Where‑Object { $_ ‑match "Lost" }
if ($lossLines.Count ‑gt 0) {
    # Example: Packets: Sent = 4, Received = 4, Lost = 0 (0% loss)
    $lossInfo = ($lossLines[0] ‑replace ".*Lost =\s*([0‑9]+).*", '$1')
    $lossPercent = [int]$lossInfo
    if ($lossPercent ‑gt 0) {
        Write‑Host "Packet loss detected: $lossPercent% loss." ‑ForegroundColor Yellow
    } else {
        Write‑Host "No packet loss." ‑ForegroundColor Green
    }
} else {
    Write‑Host "Could not find loss info in ping output." ‑ForegroundColor Red
}

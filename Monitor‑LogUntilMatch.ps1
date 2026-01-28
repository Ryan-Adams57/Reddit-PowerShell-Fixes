<#
.SYNOPSIS
Monitor a log file in real time and exit when a keyword is found.

.DESCRIPTION
This script:
 • Reads a log file in streaming mode (like 'tail -f').
 • Writes new log lines to the console.
 • Exits when a specific pattern is found in the log text.
 • Optionally supports a timeout so it doesn’t run forever.

.PARAMETER LogPath
Path to the log file to watch.

.PARAMETER Pattern
A regex pattern to search for in each incoming line.

.PARAMETER TimeoutSec
Optional number of seconds to wait before terminating automatically.

.EXAMPLE
.\Monitor‑LogUntilMatch.ps1 ‑LogPath C:\Logs\app.log ‑Pattern "Completed" ‑TimeoutSec 600
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$LogPath,

    [Parameter(Mandatory=$true)]
    [string]$Pattern,

    [int]$TimeoutSec = 0
)

# Validate file exists
if ( -not (Test‑Path $LogPath) ) {
    Write‑Error "Log file not found: $LogPath"
    exit 1
}

# Track start time for optional timeout
$startTime = [datetime]::UtcNow

Write‑Host "Watching $LogPath for pattern '$Pattern'…" ‑ForegroundColor Cyan

# Use Get‑Content with -Tail 0 so we only see new lines
Get‑Content ‑Path $LogPath ‑Tail 0 ‑Wait | ForEach‑Object {
    $line = $_
    Write‑Host $line

    if ($line ‑match $Pattern) {
        Write‑Host "Pattern '$Pattern' found! Exiting…" ‑ForegroundColor Green
        exit 0
    }

    if ($TimeoutSec ‑gt 0) {
        $elapsed = ([datetime]::UtcNow ‑ $startTime).TotalSeconds
        if ($elapsed ‑ge $TimeoutSec) {
            Write‑Host "Timeout of $TimeoutSec seconds reached. Exiting…" ‑ForegroundColor Yellow
            exit 2
        }
    }
}

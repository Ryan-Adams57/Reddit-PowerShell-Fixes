<#
.SYNOPSIS
Run a program and pipe all its output into Select‑String reliably.

.DESCRIPTION
Many external CLI programs do not write their output to PowerShell’s pipeline (stdout),
instead writing to stderr or directly to the console. This script:
 • Runs a command with all streams captured (stdout + stderr).
 • Converts them to text lines.
 • Pipes them to Select‑String with your pattern.
 • Outputs matching lines, including context if needed.

.PARAMETER Command
The external command to run (e.g., 'vcpkg depend-info qtbase').

.PARAMETER Pattern
The regex or text to search for.

.PARAMETER Context
(Optional) Context lines before/after matches.

.EXAMPLE
.\Find‑TextInExternalOutput.ps1 -Command 'vcpkg depend‑info qtbase' -Pattern 'font'

.EXAMPLE
.\Find‑TextInExternalOutput.ps1 -Command 'mytool args...' -Pattern 'error' -Context 2
#>

param(
    [Parameter(Mandatory=$true)][string]$Command,
    [Parameter(Mandatory=$true)][string]$Pattern,
    [int]$Context = 0
)

Write‑Host "Running command and capturing all output…" ‑ForegroundColor Cyan

# Run the external command, capture stdout + stderr
$cmdOutput = & cmd /c "$Command 2>&1" | Out‑String ‑Stream

Write‑Host "Searching for pattern '$Pattern'…" ‑ForegroundColor Cyan

# Use Select‑String on the captured text
if ($Context ‑gt 0) {
    $matches = $cmdOutput | Select‑String ‑Pattern $Pattern ‑Context $Context
} else {
    $matches = $cmdOutput | Select‑String ‑Pattern $Pattern
}

# Print matches (if any)
if ($matches) {
    $matches | ForEach‑Object { Write‑Host $_ }
} else {
    Write‑Host "No matches found for '$Pattern'." ‑ForegroundColor Yellow
}

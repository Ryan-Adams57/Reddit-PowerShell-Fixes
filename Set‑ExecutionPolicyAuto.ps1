<#
.SYNOPSIS
Automatically ensure the desired Execution Policy is in effect.

.DESCRIPTION
 • Checks the current execution policy for Process and CurrentUser.
 • Applies a desired policy if it’s more permissive than the current setting.
 • Optionally adds the setting to your PowerShell profile for automatic loading.
 • Does not modify system policies that are enforced by Group Policy.

.PARAMETER DesiredPolicy
Target execution policy (e.g., RemoteSigned, Bypass).

.PARAMETER Persist
If set, the policy change is added to your PowerShellProfile (~\Documents\PowerShell\Microsoft.PowerShell_profile.ps1).

.EXAMPLE
.\Set‑ExecutionPolicyAuto.ps1 -DesiredPolicy RemoteSigned

.EXAMPLE
.\Set‑ExecutionPolicyAuto.ps1 -DesiredPolicy Bypass -Persist

#>

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("Restricted", "RemoteSigned", "AllSigned", "Unrestricted", "Bypass", "Undefined")]
    [string]$DesiredPolicy,

    [switch]$Persist
)

# Get current
$currentProcess = Get‑ExecutionPolicy ‑Scope Process
$currentUser    = Get‑ExecutionPolicy ‑Scope CurrentUser

Write‑Host "Current process policy: $currentProcess"
Write‑Host "Current user policy:    $currentUser"

# Only override if not already at or above desired
function ShouldUpdate($current, $target) {
    # Define a ranking of policies for comparison
    $rank = @{
        "Restricted" = 0
        "AllSigned"  = 1
        "RemoteSigned" = 2
        "Unrestricted" = 3
        "Bypass"     = 4
        "Undefined"  = -1
    }
    return ($rank[$current] -lt $rank[$target])
}

# Update temp (process)
if (ShouldUpdate $currentProcess $DesiredPolicy) {
    Write‑Host "Updating process scope ExecutionPolicy to $DesiredPolicy"
    Set‑ExecutionPolicy ‑Scope Process ‑ExecutionPolicy $DesiredPolicy ‑Force
}

# Update persistent user if not set by higher policy
if (ShouldUpdate $currentUser $DesiredPolicy) {
    Write‑Host "Updating current user ExecutionPolicy to $DesiredPolicy"
    Set‑ExecutionPolicy ‑Scope CurrentUser ‑ExecutionPolicy $DesiredPolicy ‑Force
}

# Add to profile if requested
if ($Persist) {
    $profilePath = $PROFILE.CurrentUserAllHosts
    Write‑Host "Adding execution policy set to profile at $profilePath…"
    if (-not (Test‑Path $profilePath)) {
        New‑Item ‑ItemType File ‑Path $profilePath ‑Force | Out‑Null
    }
    "`n# Ensure ExecutionPolicy`nSet‑ExecutionPolicy ‑Scope Process ‑ExecutionPolicy $DesiredPolicy ‑Force" |
        Add‑Content ‑Path $profilePath
}

Write‑Host "Done. ExecutionPolicy ensured for this session and user."

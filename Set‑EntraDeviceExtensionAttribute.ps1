<#
.SYNOPSIS
Add or update an Entra (Azure AD) device extension attribute via Microsoft Graph.

.DESCRIPTION
This script:
 • Connects to Microsoft Graph with the needed permission (Device.ReadWrite.All).
 • Looks up Entra device object IDs from a list of device display names or explicit IDs.
 • Sets a specified extensionAttributeX value on each device.
 • Reports successes and failures.

IMPORTANT
You must register an AAD app with Device.ReadWrite.All or use an admin login.

.PARAMETER Devices
A list of device display names or device object IDs (one per line) to tag.

.PARAMETER ExtensionNumber
Which extensionAttribute index to set (1–15).

.PARAMETER Value
The string value to assign.

.EXAMPLE
.\Set‑EntraDeviceExtensionAttribute.ps1 -Devices "iPhone‑Alice","Samsung‑Bob" -ExtensionNumber 6 -Value "Approved"

.EXAMPLE
.\Set‑EntraDeviceExtensionAttribute.ps1 -Devices (Get‑Content devices.txt) -ExtensionNumber 6 -Value "Approved"

#>

param(
    [Parameter(Mandatory=$true)]
    [string[]]$Devices,

    [Parameter(Mandatory=$true)]
    [ValidateRange(1,15)]
    [int]$ExtensionNumber,

    [Parameter(Mandatory=$true)]
    [string]$Value
)

# Connect to Graph with device write permission
Connect‑MgGraph ‑Scopes "Device.ReadWrite.All"

# Ensure correct JSON property name
$extProp = "extensionAttribute$ExtensionNumber"

foreach ($item in $Devices) {
    $id = $null

    # Try interpret as object ID format
    if ($item ‑match '^[0‑9a‑fA‑F‑]{36}$') {
        $id = $item
    } else {
        # Find by display name
        $dev = Get‑MgDevice ‑Filter "displayName eq '$item'" ‑ConsistencyLevel eventual ‑CountVariable c | Select‑Object ‑First 1
        if ($dev) { $id = $dev.Id }
    }

    if (-not $id) {
        Write‑Host "Could not resolve device: $item" ‑ForegroundColor Yellow
        continue
    }

    $body = @{
        extensionAttributes = @{
            ($extProp) = $Value
        }
    }

    try {
        Update‑MgDevice ‑DeviceId $id ‑BodyParameter ($body | ConvertTo‑Json ‑Depth 5)
        Write‑Host "Set $extProp='$Value' for device $item" ‑ForegroundColor Green
    } catch {
        Write‑Host "Failed for $item: $_" ‑ForegroundColor Red
    }
}

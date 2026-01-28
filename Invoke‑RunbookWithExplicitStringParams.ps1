<#
.SYNOPSIS
Run an Azure Automation runbook while explicitly passing string parameters to avoid misinterpretation.

.DESCRIPTION
Azure Automation can sometimes interpret numeric-looking strings (e.g., "04…") as octal or numeric values
when invoked from external tools like Power Automate. This wrapper uses JSON to force parameters to be treated
as strings, preserving leading zeros or other formatting.

.PARAMETER AutomationAccount
Name of the Azure Automation account.

.PARAMETER ResourceGroup
Resource group of the Automation account.

.PARAMETER RunbookName
Runbook you want to invoke.

.PARAMETER Parameters
A hashtable of parameter names and values; numeric-looking values are forced to JSON strings.

.EXAMPLE
.\Invoke‑RunbookWithExplicitStringParams.ps1 `
  -AutomationAccount "MyAA" `
  -ResourceGroup "RG1" `
  -RunbookName "SendSMS" `
  -Parameters @{ UPN = "user@domain.com"; ToNumber = "0490123456"; FullName = "Alice Smith" }

#>

param(
    [Parameter(Mandatory = $true)]
    [string]$AutomationAccount,

    [Parameter(Mandatory = $true)]
    [string]$ResourceGroup,

    [Parameter(Mandatory = $true)]
    [string]$RunbookName,

    [Parameter(Mandatory = $true)]
    [hashtable]$Parameters
)

# Convert values to JSON strings forcefully
$convertedParams = @{}
foreach ($key in $Parameters.Keys) {
    $value = $Parameters[$key]
    # Ensure it is treated as a string in the JSON payload
    $convertedParams[$key] = [string]$value
}

# Create a JSON string of parameters
$jsonParams = $convertedParams | ConvertTo‑Json -Depth 3

Write‑Host "Invoking runbook '$RunbookName' with explicit string parameters…" -ForegroundColor Cyan

# Start Automation runbook
$job = Start‑AzAutomationRunbook `
    -AutomationAccountName $AutomationAccount `
    -ResourceGroupName $ResourceGroup `
    -Name $RunbookName `
    -Parameters $convertedParams

Write‑Host "Runbook started. Job ID:" $job.JobId

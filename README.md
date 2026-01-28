# Reddit-PowerShell-Fixes

Battle-tested PowerShell fixes built from unsolved Reddit threads.

Fix-InvokeCommandRemoting

Simple, reliable PowerShell remoting fixer for Invoke-Command issues.

# What it solves

This script fixes the most common reasons Invoke-Command fails to run on remote systems:

PS Remoting not enabled

WinRM listener missing or firewall blocking it

Short WinRM session timeout killing long jobs

Basic connectivity failures

It automates safe setup steps and gives clear feedback if issues remain.

# How to use

Save the script as Fix-InvokeCommandRemoting.ps1.

Open PowerShell as Administrator.

Run:

.\Fix-InvokeCommandRemoting.ps1

Enter the target computer name(s) when prompted.

Follow the prompts to optionally extend WinRM timeout.

# Notes

This configures WinRM over HTTP (port 5985) and firewall rules automatically.

For domain environments, Kerberos handles auth by default.

If you still see errors after this, verify DNS, credentials, and network access.

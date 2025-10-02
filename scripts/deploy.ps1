<#
deploy.ps1

Deploy this static site to Netlify using Netlify CLI.
Usage:
  # interactive draft deploy (preview)
  .\deploy.ps1

  # publish to production
  .\deploy.ps1 -Prod
#>
param(
    [switch]$Prod
)

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
Push-Location $scriptDir

function Require-NetlifyCLI {
    if (-not (Get-Command netlify -ErrorAction SilentlyContinue)) {
        Write-Host "netlify CLI not found. Install with: npm install -g netlify-cli" -ForegroundColor Yellow
        return $false
    }
    return $true
}

if (-not (Require-NetlifyCLI)) {
    Write-Host "Aborting deploy. After installing, re-run this script." -ForegroundColor Red
    Pop-Location
    exit 2
}

$dir = Resolve-Path "..\" | Select-Object -ExpandProperty Path

if ($Prod) {
    Write-Host "Publishing production deploy from: $dir" -ForegroundColor Cyan
    netlify deploy --prod --dir="$dir"
} else {
    Write-Host "Creating draft deploy (preview) from: $dir" -ForegroundColor Cyan
    netlify deploy --dir="$dir"
}

Pop-Location

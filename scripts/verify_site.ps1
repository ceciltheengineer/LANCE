<#
verify_site.ps1

Compare a fingerprint (SHA256) of local `index.html` with the homepage served at a domain.
This helps verify whether the live site matches the repository copy.

Usage:
  .\verify_site.ps1                      # defaults to https://lance-ai.com
  .\verify_site.ps1 -Url "https://example.com"
#>
param(
    [string]$Url = "https://lance-ai.com"
)

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$localIndex = Resolve-Path "..\index.html" -ErrorAction Stop | Select-Object -ExpandProperty Path

if (-not (Test-Path $localIndex)) {
    Write-Host "Local index.html not found at: $localIndex" -ForegroundColor Red
    exit 3
}

Write-Host "Computing local hash for: $localIndex" -ForegroundColor Gray
$localHash = Get-FileHash -Algorithm SHA256 -Path $localIndex
Write-Host "Local SHA256: $($localHash.Hash)" -ForegroundColor Green

try {
    Write-Host "Fetching $Url ..." -ForegroundColor Gray
    $resp = Invoke-WebRequest -Uri $Url -UseBasicParsing -ErrorAction Stop
} catch {
    Write-Host "Failed to fetch $Url: $($_.Exception.Message)" -ForegroundColor Red
    exit 4
}

# Save remote HTML to temp file and hash
$tmp = [System.IO.Path]::GetTempFileName()
Set-Content -Path $tmp -Value $resp.Content -NoNewline -Encoding UTF8
$remoteHash = Get-FileHash -Algorithm SHA256 -Path $tmp
Write-Host "Remote SHA256: $($remoteHash.Hash)" -ForegroundColor Green

if ($localHash.Hash -eq $remoteHash.Hash) {
    Write-Host "MATCH: local index.html matches the live HTML at $Url" -ForegroundColor Cyan
    Remove-Item $tmp -ErrorAction SilentlyContinue
    exit 0
} else {
    Write-Host "DIFFER: local index.html does NOT match the live HTML at $Url" -ForegroundColor Yellow
    Write-Host "You can open both files to inspect differences." -ForegroundColor Gray
    Write-Host "Local: $localIndex" -ForegroundColor Gray
    Write-Host "Remote temp: $tmp" -ForegroundColor Gray
    Write-Host "(The remote HTML is saved to the temp file above for manual inspection.)" -ForegroundColor Gray
    exit 5
}

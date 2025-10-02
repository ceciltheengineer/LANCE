<#
set_github_secret.ps1

Set a GitHub repository secret using the GitHub CLI `gh`.

Usage:
  # interactively prompts for secret value and uses origin remote to detect owner/repo
  .\set_github_secret.ps1 -Name NETLIFY_AUTH_TOKEN

  # provide value and repo explicitly
  .\set_github_secret.ps1 -Name NETLIFY_SITE_ID -Value "site-id-123" -Repo "owner/repo"
#>
param(
    [Parameter(Mandatory=$true)] [string]$Name,
    [string]$Value,
    [string]$Repo
)

function Require-Command([string]$name){
    if (-not (Get-Command $name -ErrorAction SilentlyContinue)){
        Write-Host "$name not found. Please install it (eg: https://cli.github.com/)." -ForegroundColor Yellow
        return $false
    }
    return $true
}

if (-not (Require-Command "gh")) { exit 2 }

if (-not $Repo) {
    try {
        $remote = git remote get-url origin 2>$null
    } catch {
        $remote = $null
    }
    if (-not $remote) {
        Write-Host "Could not detect origin remote. Please provide -Repo owner/repo or ensure git remote 'origin' exists." -ForegroundColor Red
        exit 3
    }
    # parse remote formats
    if ($remote -match "github.com[:/](.+?)(?:\.git)?$") { $Repo = $Matches[1] }
    else { Write-Host "Unexpected remote format: $remote"; exit 4 }
}

if (-not $Value) {
    Write-Host "Enter value for secret $Name (input hidden):"
    $secure = Read-Host -AsSecureString
    $ptr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)
    $Value = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($ptr)
    [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($ptr)
}

Write-Host "Setting secret $Name on repo $Repo" -ForegroundColor Gray
# Use gh to set the repository secret
$proc = Start-Process -FilePath gh -ArgumentList @('secret','set',$Name,'--repo',$Repo,'--body',$Value) -NoNewWindow -Wait -PassThru
if ($proc.ExitCode -eq 0) { Write-Host "Secret $Name set successfully." -ForegroundColor Green } else { Write-Host "Failed to set secret (exit $($proc.ExitCode))." -ForegroundColor Red }

exit $proc.ExitCode

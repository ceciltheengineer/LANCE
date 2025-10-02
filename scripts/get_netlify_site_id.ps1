param([string]$Domain)

function require-cmd($name){
    if (-not (Get-Command $name -ErrorAction SilentlyContinue)){
        Write-Host "$name not found. Install: npm install -g netlify-cli" -ForegroundColor Yellow
        exit 2
    }
}

require-cmd netlify

$json = netlify sites:list --json 2>$null
if (-not $json){ Write-Host "No sites returned. Run: netlify login; netlify sites:list" -ForegroundColor Red; exit 3 }

$sites = $json | ConvertFrom-Json
if (-not $sites){ Write-Host "Failed to parse sites JSON." -ForegroundColor Red; exit 4 }

if ($Domain){
    $found = $sites | Where-Object { $_.url -like "*$Domain*" -or $_.name -like "*$Domain*" } | Select-Object -First 1
    if ($found){
        Write-Host "Site: $($found.name) ($($found.url))"
        Write-Host "Site ID: $($found.site_id)"
        try { $found.site_id | Set-Clipboard; Write-Host "Copied to clipboard." } catch {}
        exit 0
    }
}

for ($i=0; $i -lt $sites.Count; $i++){
    $s = $sites[$i]
    Write-Host "[$i] $($s.name) - $($s.url) - id: $($s.site_id)"
}

$sel = Read-Host "Enter index to copy site ID (or Enter to cancel)"
if ([string]::IsNullOrWhiteSpace($sel)){ Write-Host "Cancelled"; exit 0 }
if (-not ([int]::TryParse($sel,[ref]$null))){ Write-Host "Invalid index"; exit 5 }
$idx = [int]$sel
if ($idx -lt 0 -or $idx -ge $sites.Count){ Write-Host "Index out of range"; exit 6 }
$chosen = $sites[$idx]
Write-Host "Selected: $($chosen.name) - $($chosen.url)"
Write-Host "Site ID: $($chosen.site_id)"
try { $chosen.site_id | Set-Clipboard; Write-Host "Copied to clipboard." } catch {}
exit 0

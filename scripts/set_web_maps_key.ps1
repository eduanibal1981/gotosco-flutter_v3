param(
  [string]$Key = $env:GOOGLE_MAPS_API_KEY
)

$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($Key)) {
  throw "GOOGLE_MAPS_API_KEY is not set. Pass -Key or set the env var."
}

$path = "web/index.html"
if (-not (Test-Path $path)) {
  throw "File not found: $path"
}

$content = Get-Content -Raw -Path $path
if ($content -notmatch "GOOGLE_MAPS_API_KEY") {
  throw "Placeholder GOOGLE_MAPS_API_KEY not found in $path"
}

$updated = $content -replace "GOOGLE_MAPS_API_KEY", $Key
Set-Content -Path $path -Value $updated -Encoding UTF8
Write-Host "Injected Google Maps key into $path"

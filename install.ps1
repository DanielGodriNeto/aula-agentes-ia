# Aula de agentes de IA - instalador (Windows). Toda a logica esta em install.mjs (leia antes de rodar).
# Uso:  irm https://raw.githubusercontent.com/DanielGodriNeto/aula-agentes-ia/main/install.ps1 | iex
$ErrorActionPreference = 'Stop'
$Ref = if ($env:REF) { $env:REF } else { 'main' }; $Repo = 'DanielGodriNeto/aula-agentes-ia'
if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
  if (-not (Get-Command winget -ErrorAction SilentlyContinue)) { throw 'Instale o Node.js LTS (https://nodejs.org) e rode de novo.' }
  Write-Host '[aula] Instalando o Node.js LTS...' -ForegroundColor Cyan
  winget install --id OpenJS.NodeJS.LTS -e --accept-package-agreements --accept-source-agreements
  $env:Path = [Environment]::GetEnvironmentVariable('Path','Machine') + ';' + [Environment]::GetEnvironmentVariable('Path','User')
  if (-not (Get-Command node -ErrorAction SilentlyContinue)) { throw 'Node instalado. Feche e abra o PowerShell e rode de novo.' }
}
if ($PSCommandPath -and (Test-Path (Join-Path (Split-Path $PSCommandPath) 'install.mjs'))) { $src = Split-Path $PSCommandPath }
else {
  $tmp = Join-Path ([IO.Path]::GetTempPath()) ("aula-" + [guid]::NewGuid().ToString('N')); New-Item -ItemType Directory $tmp | Out-Null
  Invoke-WebRequest "https://github.com/$Repo/archive/$Ref.zip" -OutFile "$tmp\r.zip" -UseBasicParsing
  Expand-Archive "$tmp\r.zip" $tmp -Force; $src = (Get-ChildItem $tmp -Directory | Select-Object -First 1).FullName
}
node "$src\install.mjs"

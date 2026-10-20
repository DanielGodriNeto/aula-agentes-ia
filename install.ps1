# Aula de agentes de IA - instalador (Windows PowerShell 5.1+)
# Uso:  irm https://raw.githubusercontent.com/DanielGodriNeto/aula-agentes-ia/main/install.ps1 | iex
# Opcoes (rodando o arquivo): .\install.ps1 -Mode auto|cloud|local   -Ref main
# Leia antes de rodar: este script nao pede nem guarda nenhuma chave. Ele so
#   1) detecta sua placa, 2) instala o OpenCode (e o Ollama no modo local),
#   3) copia agentes e skills para ~/.config/opencode (com backup do que existir).
param([ValidateSet('auto','cloud','local')][string]$Mode = 'auto', [string]$Ref = 'main')
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
$Repo = 'DanielGodriNeto/aula-agentes-ia'

# ---------- MODELOS (unico lugar para trocar; veja config/modelos.md) ----------
$Cloud = @{ ORCH = 'google/gemini-2.5-pro'; MGR = 'google/gemini-2.5-flash'; DEV = 'google/gemini-2.5-flash-lite' }
$LocalBig   = 'qwen3-coder:30b'   # >= 24 GB de VRAM
$LocalMid   = 'gpt-oss:20b'       # 12-16 GB de VRAM
# -------------------------------------------------------------------------------

function Say($m) { Write-Host "[aula] $m" -ForegroundColor Cyan }

function Get-VramGB {
    $smi = Get-Command nvidia-smi -ErrorAction SilentlyContinue
    if (-not $smi) { return 0 }
    $mb = & nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits | Select-Object -First 1
    return [math]::Round([int]$mb / 1024)
}

function Install-Winget($id, $name) {
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) { throw "winget nao encontrado. Instale $name manualmente e rode de novo." }
    Say "Instalando $name via winget..."
    winget install --id $id -e --accept-source-agreements --accept-package-agreements | Out-Null
    $env:Path = [Environment]::GetEnvironmentVariable('Path','Machine') + ';' + [Environment]::GetEnvironmentVariable('Path','User')
}

# 1. Modo
$vram = Get-VramGB
Say "Placa NVIDIA detectada: $vram GB de VRAM (0 = nenhuma)."
if ($Mode -eq 'auto') { $Mode = if ($vram -ge 12) { 'local' } else { 'cloud' } }
Say "Modo escolhido: $Mode"
if ($Mode -eq 'local') {
    $localModel = if ($vram -ge 24) { $LocalBig } else { $LocalMid }
    $models = @{ ORCH = "ollama/$localModel"; MGR = "ollama/$localModel"; DEV = "ollama/$localModel" }
} else { $models = $Cloud }

# 2. Node + OpenCode
if (-not (Get-Command node -ErrorAction SilentlyContinue)) { Install-Winget 'OpenJS.NodeJS.LTS' 'Node.js' }
if (-not (Get-Command opencode -ErrorAction SilentlyContinue)) { Say 'Instalando OpenCode...'; npm install -g opencode-ai | Out-Null }

# 3. Ollama (so no modo local)
if ($Mode -eq 'local') {
    if (-not (Get-Command ollama -ErrorAction SilentlyContinue)) { Install-Winget 'Ollama.Ollama' 'Ollama' }
    [Environment]::SetEnvironmentVariable('OLLAMA_CONTEXT_LENGTH', '65536', 'User')
    $env:OLLAMA_CONTEXT_LENGTH = '65536'
    Say "Baixando o modelo $localModel (pode demorar e ocupar 15-20 GB)..."
    ollama pull $localModel
}

# 4. Baixa o repo e copia configuracao
$tmp = Join-Path ([IO.Path]::GetTempPath()) "aula-agentes-$([guid]::NewGuid().ToString('N'))"
New-Item -ItemType Directory $tmp | Out-Null
Invoke-WebRequest "https://github.com/$Repo/archive/$Ref.zip" -OutFile "$tmp\repo.zip"
Expand-Archive "$tmp\repo.zip" -DestinationPath $tmp
$src = (Get-ChildItem $tmp -Directory | Select-Object -First 1).FullName

$dest = Join-Path $HOME '.config\opencode'
if (Test-Path $dest) {
    $bak = "$dest.bak-$(Get-Date -Format yyyyMMdd-HHmmss)"
    Say "Ja existe configuracao. Backup em $bak"
    Copy-Item $dest $bak -Recurse
}
New-Item -ItemType Directory -Force "$dest\agents", "$dest\skills" | Out-Null

function Fill($text) {
    $text = $text.Replace('{{ORCH}}', $models.ORCH).Replace('{{MGR}}', $models.MGR).Replace('{{DEV}}', $models.DEV)
    if ($Mode -eq 'local') { $text = $text.Replace('{{LOCAL_NAME}}', $localModel) }
    return $text
}
foreach ($f in Get-ChildItem "$src\agents\*.md") {
    Set-Content "$dest\agents\$($f.Name)" (Fill (Get-Content $f.FullName -Raw)) -Encoding UTF8
}
Copy-Item "$src\skills\*" "$dest\skills" -Recurse -Force
Set-Content "$dest\opencode.json" (Fill (Get-Content "$src\config\opencode.$Mode.json" -Raw)) -Encoding UTF8
Remove-Item $tmp -Recurse -Force

# 5. Fim
Say 'Pronto. Ultimo passo:'
if ($Mode -eq 'cloud') {
    Write-Host '  1) Crie uma chave gratis em https://aistudio.google.com/apikey'
    Write-Host '  2) Rode:  opencode auth login   (escolha Google e cole a chave)'
    Write-Host '  AVISO: no plano gratis o Google pode usar seus prompts para treinar. Nao use codigo privado.'
} else {
    Write-Host '  Reabra o terminal (para o OLLAMA_CONTEXT_LENGTH valer) e rode: ollama serve'
}
Write-Host '  3) Entre numa pasta de projeto vazia e rode:  opencode'

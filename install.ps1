# Aula de agentes de IA - instalador (Windows PowerShell 5.1+)
# Uso:  irm https://raw.githubusercontent.com/DanielGodriNeto/aula-agentes-ia/main/install.ps1 | iex
# Modos: claude (voce ja tem Claude Code) | cloud (Gemini gratis) | free (OpenCode Zen, sem Google) | local (GPU)
# Com iex nao da para passar parametro: antes do comando rode  $env:AULA_MODE='free'  (ou cloud/local/claude).
# Leia antes de rodar: este script nao pede nem guarda nenhuma chave. Ele so
#   1) escolhe o modo (Claude Code > placa NVIDIA 12 GB+ > Gemini gratis),
#   2) instala o OpenCode (e o Ollama no modo local), a menos que o modo seja claude,
#   3) copia agentes e skills (com backup do que existir) e os exercicios para ~/aula-agentes-ia-exercicios.
param(
    [ValidateSet('auto','claude','cloud','free','local')][string]$Mode = $(if ($env:AULA_MODE) { $env:AULA_MODE } else { 'auto' }),
    [string]$Ref = 'main'
)
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
$Repo = 'DanielGodriNeto/aula-agentes-ia'

# ---------- MODELOS (unico lugar para trocar; veja config/modelos.md) ----------
$Cloud = @{ ORCH = 'google/gemini-3.8-flash'; MGR = 'google/gemini-3.8-flash'; DEV = 'google/gemini-3.5-flash-lite' }
$Free  = @{ ORCH = 'opencode/deepseek-v4.1-flash-free'; MGR = 'opencode/glm-5.3-flash-free'; DEV = 'opencode/minimax-m3.1-flash-free' }
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
if ($Mode -eq 'auto') {
    $Mode = if (Get-Command claude -ErrorAction SilentlyContinue) { 'claude' } elseif ($vram -ge 12) { 'local' } else { 'cloud' }
}
Say "Modo escolhido: $Mode"
if ($Mode -eq 'local') {
    $localModel = if ($vram -ge 24) { $LocalBig } else { $LocalMid }
    $models = @{ ORCH = "ollama/$localModel"; MGR = "ollama/$localModel"; DEV = "ollama/$localModel" }
} elseif ($Mode -eq 'free') { $models = $Free } else { $models = $Cloud }

# 2. Baixa o repo (todos os modos) e separa os exercicios
$tmp = Join-Path ([IO.Path]::GetTempPath()) "aula-agentes-$([guid]::NewGuid().ToString('N'))"
New-Item -ItemType Directory $tmp | Out-Null
Invoke-WebRequest "https://github.com/$Repo/archive/$Ref.zip" -OutFile (Join-Path $tmp 'repo.zip')
Expand-Archive (Join-Path $tmp 'repo.zip') -DestinationPath $tmp
$src = (Get-ChildItem $tmp -Directory | Select-Object -First 1).FullName
$ex = Join-Path $HOME 'aula-agentes-ia-exercicios'
New-Item -ItemType Directory -Force $ex | Out-Null
Copy-Item (Join-Path $src 'exercicios\*') $ex -Recurse -Force

# 3a. Claude Code ja instalado: opus/sonnet/haiku reais, sem OpenCode
if ($Mode -eq 'claude') {
    $cd = Join-Path $HOME '.claude'
    New-Item -ItemType Directory -Force (Join-Path $cd 'agents'), (Join-Path $cd 'skills') | Out-Null
    foreach ($f in Get-ChildItem (Join-Path $src 'agents-claude\*.md')) {
        $d = Join-Path $cd "agents\$($f.Name)"
        if (Test-Path $d) { Copy-Item $d "$d.bak" -Force }
        Copy-Item $f.FullName $d -Force
    }
    Copy-Item (Join-Path $src 'skills\*') (Join-Path $cd 'skills') -Recurse -Force
    Remove-Item $tmp -Recurse -Force
    Say 'Pronto (modo Claude Code). Numa pasta de projeto rode: claude   (o comando /agents lista maestro, gerente, dev)'
    Say "Exercicios em: $ex"
    return
}

# 3b. Node + OpenCode
if (-not (Get-Command node -ErrorAction SilentlyContinue)) { Install-Winget 'OpenJS.NodeJS.LTS' 'Node.js' }
if (-not (Get-Command opencode -ErrorAction SilentlyContinue)) { Say 'Instalando OpenCode...'; npm install -g opencode-ai | Out-Null }

# 3c. Ollama (so no modo local)
if ($Mode -eq 'local') {
    if (-not (Get-Command ollama -ErrorAction SilentlyContinue)) { Install-Winget 'Ollama.Ollama' 'Ollama' }
    [Environment]::SetEnvironmentVariable('OLLAMA_CONTEXT_LENGTH', '65536', 'User')
    $env:OLLAMA_CONTEXT_LENGTH = '65536'
    Say "Baixando o modelo $localModel (pode demorar e ocupar 15-20 GB)..."
    ollama pull $localModel
}

# 4. Copia configuracao
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
$cfg = if ($Mode -eq 'local') { 'local' } else { 'cloud' }   # free e cloud usam o mesmo JSON (so muda o modelo)
Set-Content "$dest\opencode.json" (Fill (Get-Content "$src\config\opencode.$cfg.json" -Raw)) -Encoding UTF8
Remove-Item $tmp -Recurse -Force

# 5. Fim
Say 'Pronto. Ultimo passo:'
if ($Mode -eq 'cloud') {
    Write-Host '  1) Crie uma chave gratis em https://aistudio.google.com/apikey'
    Write-Host '  2) Rode:  opencode auth login   (escolha Google e cole a chave)'
    Write-Host '  AVISO: no plano gratis o Google pode usar seus prompts para treinar. Nao use codigo privado.'
    Write-Host '  Sem conta Google? Rode de novo com  $env:AULA_MODE=''free''  antes do comando.'
} elseif ($Mode -eq 'free') {
    Write-Host '  1) Rode:  opencode auth login   (escolha OpenCode Zen; crie a conta gratis se pedir)'
    Write-Host '  2) Confira os modelos gratis de hoje:  opencode models opencode   (a lista muda; edite ~/.config/opencode/agents/*.md se algum sumiu)'
} else {
    Write-Host '  Reabra o terminal (para o OLLAMA_CONTEXT_LENGTH valer) e rode: ollama serve'
}
Write-Host '  Depois entre numa pasta de projeto vazia e rode:  opencode'
Write-Host "  Exercicios em: $ex"

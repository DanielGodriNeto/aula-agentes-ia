#!/usr/bin/env bash
# Aula de agentes de IA - instalador (macOS / Linux)
# Uso:  curl -fsSL https://raw.githubusercontent.com/DanielGodriNeto/aula-agentes-ia/main/install.sh | bash
# Modos: claude | cloud (Gemini gratis) | free (OpenCode Zen) | both (Gemini no maestro + Zen no resto) | local (GPU)
# Sem AULA_MODE o instalador PERGUNTA qual voce prefere.
# Escolher:  curl -fsSL .../install.sh | AULA_MODE=free bash     (REF=main por padrao)
# Leia antes de rodar: nao pede nem guarda chave. Escolhe o modo (Claude Code > GPU 12 GB+ > modelos gratis do OpenCode Zen),
# instala OpenCode (e Ollama no modo local) e copia agentes, skills e exercicios (com backup).
set -euo pipefail
MODE="${AULA_MODE:-${MODE:-auto}}"; REF="${REF:-main}"; REPO="DanielGodriNeto/aula-agentes-ia"

# ---------- MODELOS (unico lugar para trocar; veja config/modelos.md) ----------
CLOUD_ORCH="google/gemini-3.8-flash"; CLOUD_MGR="google/gemini-3.8-flash"; CLOUD_DEV="google/gemini-3.5-flash-lite"
FREE_ORCH="opencode/deepseek-v4.1-flash-free"; FREE_MGR="opencode/glm-5.3-flash-free"; FREE_DEV="opencode/minimax-m3.1-flash-free"
# -------------------------------------------------------------------------------

say() { printf '\033[36m[aula]\033[0m %s\n' "$*"; }

vram_gb() {
  if command -v nvidia-smi >/dev/null 2>&1; then
    echo $(( $(nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits | head -1) / 1024 )); return
  fi
  # Apple Silicon: memoria unificada; usa ~70% como "VRAM"
  if [ "$(uname -s)" = "Darwin" ] && [ "$(uname -m)" = "arm64" ]; then
    echo $(( $(sysctl -n hw.memsize) / 1073741824 * 7 / 10 )); return
  fi
  # AMD (Linux): rocm-smi
  if command -v rocm-smi >/dev/null 2>&1; then
    echo $(( $(rocm-smi --showmeminfo vram --json 2>/dev/null | grep -o '"VRAM Total Memory (B)": *"[0-9]*"' | head -1 | grep -o '[0-9]*' | tail -1 || echo 0) / 1073741824 )); return
  fi
  echo 0
}

# Modelos locais por VRAM (verificados em ollama.com/library em 2026-10-20; veja config/modelos.md)
local_models() {
  if [ "$VRAM" -ge 32 ] && [ "$(uname -s)" != Darwin ]; then L_ORCH=qwen3.8:27b; L_MGR=qwen3.8:27b; L_DEV=laguna-xs-2.1; return; fi
  if   [ "$VRAM" -ge 24 ]; then m=muse-glimmer:30b
  elif [ "$VRAM" -ge 16 ]; then m=gpt-oss:20b
  elif [ "$VRAM" -ge 12 ]; then m=gemma4:12b
  else m=ornith-1.5:9b; fi
  L_ORCH=$m; L_MGR=$m; L_DEV=$m
}

VRAM="${AULA_VRAM:-$(vram_gb)}"; say "VRAM/memoria util detectada: ${VRAM} GB (0 = nenhuma)."
ask_mode() {
  local has_claude=0 def n a
  command -v claude >/dev/null 2>&1 && has_claude=1
  if [ "$has_claude" = 1 ]; then def=claude; n=1; elif [ "$VRAM" -ge 16 ]; then def=local; n=5; else def=free; n=2; fi
  if [ ! -r /dev/tty ]; then MODE=$def; return; fi   # curl | bash: le do terminal, nao do pipe
  {
    echo
    if [ "$has_claude" = 1 ]; then echo "Detectei o Claude Code instalado. Voce tem assinatura (Pro/Max)? Ele e a melhor opcao: Opus, Sonnet e Haiku de verdade."
    else echo "Nao achei o Claude Code (a assinatura Pro e paga; sem ela, use uma das opcoes gratis abaixo)."; fi
    echo "  [1] Claude Code     bom: o time original (Opus/Sonnet/Haiku). ruim: precisa de assinatura paga e do claude instalado."
    echo "  [2] Zen (gratis)    bom: sem conta, sem chave, sem cartao, sem guardar seus dados. ruim: limites nao publicados (sala cheia pode dar erro 429), modelos menores, lista muda."
    echo "  [3] Gemini (gratis) bom: modelos mais fortes, limites claros no AI Studio. ruim: precisa de conta Google e chave; no plano gratis o Google pode TREINAR com seus prompts; cota diaria baixa."
    echo "  [4] Zen + Gemini    bom: divide a carga (Gemini so no maestro, Zen no resto), duas cotas, se um cair o outro segura. ruim: configurar os dois. RECOMENDADO para quem tem conta Google."
    local_models
    echo "  [5] Local (GPU)     bom: privado, sem limite, offline. ruim: download de 7-20 GB; modelo pequeno erra mais. Sua placa: ${VRAM} GB -> ${L_ORCH} (+ ${L_DEV} no dev). Abaixo de 8 GB nao recomendo."
    printf "Escolha [1-5] (Enter = %s): " "$n"
  } > /dev/tty
  read -r a < /dev/tty || a=""
  case "${a:-$n}" in 1) MODE=claude;; 2) MODE=free;; 3) MODE=cloud;; 4) MODE=both;; 5) MODE=local;; *) MODE=$def;; esac
}
[ "$MODE" = auto ] && ask_mode
case "$MODE" in claude|cloud|free|both|local) ;; *) echo "AULA_MODE invalido: $MODE"; exit 1;; esac
say "Modo escolhido: $MODE"
CTX=65536; [ "$VRAM" -ge 16 ] || CTX=32768   # contexto menor em placa pequena (KV cache)
case "$MODE" in
  local) local_models; ORCH="ollama/$L_ORCH"; MGR="ollama/$L_MGR"; DEV="ollama/$L_DEV";;
  free)  ORCH="$FREE_ORCH"; MGR="$FREE_MGR"; DEV="$FREE_DEV";;
  both)  ORCH="$CLOUD_ORCH"; MGR="$FREE_MGR"; DEV="$FREE_DEV";;
  *)     ORCH="$CLOUD_ORCH"; MGR="$CLOUD_MGR"; DEV="$CLOUD_DEV";;
esac

TMP=$(mktemp -d); trap 'rm -rf "$TMP"' EXIT
curl -fsSL "https://github.com/$REPO/archive/$REF.tar.gz" | tar -xz -C "$TMP" --strip-components=1
EX="$HOME/aula-agentes-ia-exercicios"; mkdir -p "$EX"; cp -r "$TMP"/exercicios/. "$EX/"
EXTRAS="${AULA_EXTRAS:-0}"   # AULA_EXTRAS=1 instala tambem skills-extras (scrapling, break-ui, animate...)

if [ "$MODE" = claude ]; then
  CD="$HOME/.claude"; mkdir -p "$CD/agents" "$CD/skills"
  for f in "$TMP"/agents-claude/*.md; do
    d="$CD/agents/$(basename "$f")"; [ -f "$d" ] && cp "$d" "$d.bak"; cp "$f" "$d"
  done
  cp -r "$TMP"/skills/* "$CD/skills/"
  [ "$EXTRAS" = 1 ] && cp -r "$TMP"/skills-extras/* "$CD/skills/"
  say "Pronto (modo Claude Code). Numa pasta de projeto rode: claude   (/agents lista maestro, gerente, dev)"
  say "Exercicios em: $EX"; exit 0
fi

command -v node >/dev/null || { echo "Instale o Node.js LTS (https://nodejs.org) e rode de novo."; exit 1; }
command -v opencode >/dev/null || { say "Instalando OpenCode..."; npm install -g opencode-ai >/dev/null; }

if [ "$MODE" = local ]; then
  command -v ollama >/dev/null || { echo "Instale o Ollama (https://ollama.com/download) e rode de novo."; exit 1; }
  for m in $(printf '%s
' "$L_ORCH" "$L_MGR" "$L_DEV" | sort -u); do say "Baixando o modelo $m (pode demorar)..."; ollama pull "$m"; done
fi

DEST="$HOME/.config/opencode"
if [ -d "$DEST" ]; then BAK="$DEST.bak-$(date +%Y%m%d-%H%M%S)"; say "Backup da configuracao existente em $BAK"; cp -r "$DEST" "$BAK"; fi
mkdir -p "$DEST/agents" "$DEST/skills"

LOCAL_JSON=""
if [ "$MODE" = local ]; then
  for m in $(printf '%s
' "$L_ORCH" "$L_MGR" "$L_DEV" | sort -u); do LOCAL_JSON="$LOCAL_JSON\"$m\":{\"name\":\"$m\",\"limit\":{\"context\":$CTX,\"output\":8192}},"; done
  LOCAL_JSON="{${LOCAL_JSON%,}}"
fi
fill() {
  sed -e "s|{{ORCH}}|$ORCH|g" -e "s|{{MGR}}|$MGR|g" -e "s|{{DEV}}|$DEV|g" -e "s|\"{{LOCAL_MODELS}}\"|$LOCAL_JSON|g" "$1"
}
for f in "$TMP"/agents/*.md; do fill "$f" > "$DEST/agents/$(basename "$f")"; done
cp -r "$TMP"/skills/* "$DEST/skills/"
[ "$EXTRAS" = 1 ] && cp -r "$TMP"/skills-extras/* "$DEST/skills/"
CFG=$([ "$MODE" = local ] && echo local || echo cloud)   # free e cloud usam o mesmo JSON
fill "$TMP/config/opencode.$CFG.json" > "$DEST/opencode.json"

say "Pronto. Ultimo passo:"
case "$MODE" in
  cloud|both)
    [ "$MODE" = both ] && echo "  Modo duplo: o maestro usa Gemini; gerente e dev usam Zen (sem login)."
    echo "  1) Crie uma chave gratis em https://aistudio.google.com/apikey"
    echo "  2) Rode:  opencode auth login   (escolha Google e cole a chave)"
    echo "  AVISO: no plano gratis o Google pode usar seus prompts para treinar. Nao use codigo privado."
    echo "  Preferiu nao usar Google? Rode de novo com AULA_MODE=free.";;
  free)
    echo "  Nao precisa de chave nem login: os modelos -free do OpenCode Zen funcionam direto (nos testes, sem conta)."
    echo "  Confira os modelos gratis de hoje:  opencode models opencode   (a lista muda; edite ~/.config/opencode/agents/*.md se algum sumiu)";;
  local)
    echo "  Rode: OLLAMA_CONTEXT_LENGTH=$CTX ollama serve   (contexto minimo para agentes)";;
esac
echo "  Depois entre numa pasta de projeto vazia e rode:  opencode"
echo "  Exercicios em: $EX"

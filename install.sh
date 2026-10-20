#!/usr/bin/env bash
# Aula de agentes de IA - instalador (macOS / Linux)
# Uso:  curl -fsSL https://raw.githubusercontent.com/DanielGodriNeto/aula-agentes-ia/main/install.sh | bash
# Modos: claude (voce ja tem Claude Code) | cloud (Gemini gratis) | free (OpenCode Zen, sem Google) | local (GPU)
# Escolher:  curl -fsSL .../install.sh | AULA_MODE=free bash     (REF=main por padrao)
# Leia antes de rodar: nao pede nem guarda chave. Escolhe o modo (Claude Code > GPU 12 GB+ > Gemini gratis),
# instala OpenCode (e Ollama no modo local) e copia agentes, skills e exercicios (com backup).
set -euo pipefail
MODE="${AULA_MODE:-${MODE:-auto}}"; REF="${REF:-main}"; REPO="DanielGodriNeto/aula-agentes-ia"

# ---------- MODELOS (unico lugar para trocar; veja config/modelos.md) ----------
CLOUD_ORCH="google/gemini-3.8-flash"; CLOUD_MGR="google/gemini-3.8-flash"; CLOUD_DEV="google/gemini-3.5-flash-lite"
FREE_ORCH="opencode/deepseek-v4.1-flash-free"; FREE_MGR="opencode/glm-5.3-flash-free"; FREE_DEV="opencode/minimax-m3.1-flash-free"
LOCAL_BIG="qwen3-coder:30b"   # >= 24 GB
LOCAL_MID="gpt-oss:20b"       # 12-16 GB
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
  echo 0
}

VRAM=$(vram_gb); say "VRAM/memoria util detectada: ${VRAM} GB (0 = nenhuma)."
if [ "$MODE" = auto ]; then
  if command -v claude >/dev/null 2>&1; then MODE=claude
  elif [ "$VRAM" -ge 12 ]; then MODE=local
  else MODE=cloud; fi
fi
case "$MODE" in claude|cloud|free|local) ;; *) echo "AULA_MODE invalido: $MODE"; exit 1;; esac
say "Modo escolhido: $MODE"
LOCAL_MODEL=""
case "$MODE" in
  local) LOCAL_MODEL=$([ "$VRAM" -ge 24 ] && echo "$LOCAL_BIG" || echo "$LOCAL_MID"); ORCH="ollama/$LOCAL_MODEL"; MGR="$ORCH"; DEV="$ORCH";;
  free)  ORCH="$FREE_ORCH"; MGR="$FREE_MGR"; DEV="$FREE_DEV";;
  *)     ORCH="$CLOUD_ORCH"; MGR="$CLOUD_MGR"; DEV="$CLOUD_DEV";;
esac

TMP=$(mktemp -d); trap 'rm -rf "$TMP"' EXIT
curl -fsSL "https://github.com/$REPO/archive/$REF.tar.gz" | tar -xz -C "$TMP" --strip-components=1
EX="$HOME/aula-agentes-ia-exercicios"; mkdir -p "$EX"; cp -r "$TMP"/exercicios/. "$EX/"

if [ "$MODE" = claude ]; then
  CD="$HOME/.claude"; mkdir -p "$CD/agents" "$CD/skills"
  for f in "$TMP"/agents-claude/*.md; do
    d="$CD/agents/$(basename "$f")"; [ -f "$d" ] && cp "$d" "$d.bak"; cp "$f" "$d"
  done
  cp -r "$TMP"/skills/* "$CD/skills/"
  say "Pronto (modo Claude Code). Numa pasta de projeto rode: claude   (/agents lista maestro, gerente, dev)"
  say "Exercicios em: $EX"; exit 0
fi

command -v node >/dev/null || { echo "Instale o Node.js LTS (https://nodejs.org) e rode de novo."; exit 1; }
command -v opencode >/dev/null || { say "Instalando OpenCode..."; npm install -g opencode-ai >/dev/null; }

if [ "$MODE" = local ]; then
  command -v ollama >/dev/null || { echo "Instale o Ollama (https://ollama.com/download) e rode de novo."; exit 1; }
  say "Baixando o modelo $LOCAL_MODEL (15-20 GB)..."
  ollama pull "$LOCAL_MODEL"
fi

DEST="$HOME/.config/opencode"
if [ -d "$DEST" ]; then BAK="$DEST.bak-$(date +%Y%m%d-%H%M%S)"; say "Backup da configuracao existente em $BAK"; cp -r "$DEST" "$BAK"; fi
mkdir -p "$DEST/agents" "$DEST/skills"

fill() {
  sed -e "s|{{ORCH}}|$ORCH|g" -e "s|{{MGR}}|$MGR|g" -e "s|{{DEV}}|$DEV|g" -e "s|{{LOCAL_NAME}}|$LOCAL_MODEL|g" "$1"
}
for f in "$TMP"/agents/*.md; do fill "$f" > "$DEST/agents/$(basename "$f")"; done
cp -r "$TMP"/skills/* "$DEST/skills/"
CFG=$([ "$MODE" = local ] && echo local || echo cloud)   # free e cloud usam o mesmo JSON
fill "$TMP/config/opencode.$CFG.json" > "$DEST/opencode.json"

say "Pronto. Ultimo passo:"
case "$MODE" in
  cloud)
    echo "  1) Crie uma chave gratis em https://aistudio.google.com/apikey"
    echo "  2) Rode:  opencode auth login   (escolha Google e cole a chave)"
    echo "  AVISO: no plano gratis o Google pode usar seus prompts para treinar. Nao use codigo privado."
    echo "  Sem conta Google? Rode de novo com AULA_MODE=free.";;
  free)
    echo "  1) Rode:  opencode auth login   (escolha OpenCode Zen; crie a conta gratis se pedir)"
    echo "  2) Confira os modelos gratis de hoje:  opencode models opencode   (a lista muda; edite ~/.config/opencode/agents/*.md se algum sumiu)";;
  local)
    echo "  Rode: OLLAMA_CONTEXT_LENGTH=65536 ollama serve   (contexto minimo de 64k)";;
esac
echo "  Depois entre numa pasta de projeto vazia e rode:  opencode"
echo "  Exercicios em: $EX"

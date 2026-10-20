#!/usr/bin/env bash
# Aula de agentes de IA - instalador (macOS / Linux)
# Uso:  curl -fsSL https://raw.githubusercontent.com/DanielGodriNeto/aula-agentes-ia/main/install.sh | bash
# Opcoes: MODE=auto|cloud|local REF=main bash install.sh
# Leia antes de rodar: nao pede nem guarda chave. Detecta a placa, instala OpenCode
# (e Ollama no modo local) e copia agentes e skills para ~/.config/opencode (com backup).
set -euo pipefail
MODE="${MODE:-auto}"; REF="${REF:-main}"; REPO="DanielGodriNeto/aula-agentes-ia"

# ---------- MODELOS (unico lugar para trocar; veja config/modelos.md) ----------
CLOUD_ORCH="google/gemini-2.5-pro"; CLOUD_MGR="google/gemini-2.5-flash"; CLOUD_DEV="google/gemini-2.5-flash-lite"
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
[ "$MODE" = auto ] && { [ "$VRAM" -ge 12 ] && MODE=local || MODE=cloud; }
say "Modo escolhido: $MODE"
if [ "$MODE" = local ]; then
  LOCAL_MODEL=$([ "$VRAM" -ge 24 ] && echo "$LOCAL_BIG" || echo "$LOCAL_MID")
  ORCH="ollama/$LOCAL_MODEL"; MGR="$ORCH"; DEV="$ORCH"
else
  ORCH="$CLOUD_ORCH"; MGR="$CLOUD_MGR"; DEV="$CLOUD_DEV"
fi

command -v node >/dev/null || { echo "Instale o Node.js LTS (https://nodejs.org) e rode de novo."; exit 1; }
command -v opencode >/dev/null || { say "Instalando OpenCode..."; npm install -g opencode-ai >/dev/null; }

if [ "$MODE" = local ]; then
  command -v ollama >/dev/null || { echo "Instale o Ollama (https://ollama.com/download) e rode de novo."; exit 1; }
  say "Baixando o modelo $LOCAL_MODEL (15-20 GB)..."
  ollama pull "$LOCAL_MODEL"
fi

TMP=$(mktemp -d); trap 'rm -rf "$TMP"' EXIT
curl -fsSL "https://github.com/$REPO/archive/$REF.tar.gz" | tar -xz -C "$TMP" --strip-components=1

DEST="$HOME/.config/opencode"
if [ -d "$DEST" ]; then BAK="$DEST.bak-$(date +%Y%m%d-%H%M%S)"; say "Backup da configuracao existente em $BAK"; cp -r "$DEST" "$BAK"; fi
mkdir -p "$DEST/agents" "$DEST/skills"

fill() {
  sed -e "s|{{ORCH}}|$ORCH|g" -e "s|{{MGR}}|$MGR|g" -e "s|{{DEV}}|$DEV|g" -e "s|{{LOCAL_NAME}}|${LOCAL_MODEL:-}|g" "$1"
}
for f in "$TMP"/agents/*.md; do fill "$f" > "$DEST/agents/$(basename "$f")"; done
cp -r "$TMP"/skills/* "$DEST/skills/"
fill "$TMP/config/opencode.$MODE.json" > "$DEST/opencode.json"

say "Pronto. Ultimo passo:"
if [ "$MODE" = cloud ]; then
  echo "  1) Crie uma chave gratis em https://aistudio.google.com/apikey"
  echo "  2) Rode:  opencode auth login   (escolha Google e cole a chave)"
  echo "  AVISO: no plano gratis o Google pode usar seus prompts para treinar. Nao use codigo privado."
else
  echo "  Rode: OLLAMA_CONTEXT_LENGTH=65536 ollama serve   (contexto minimo de 64k)"
fi
echo "  3) Entre numa pasta de projeto vazia e rode:  opencode"

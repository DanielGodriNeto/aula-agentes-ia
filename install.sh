#!/usr/bin/env bash
# Aula de agentes de IA - instalador (macOS / Linux). Toda a logica esta em install.mjs (leia antes de rodar).
# Uso:  curl -fsSL https://raw.githubusercontent.com/DanielGodriNeto/aula-agentes-ia/main/install.sh | bash
set -euo pipefail
REF="${REF:-main}"; REPO="DanielGodriNeto/aula-agentes-ia"
command -v node >/dev/null || { echo "Instale o Node.js LTS (https://nodejs.org ou: brew install node) e rode de novo."; exit 1; }
if [ -f "$(dirname "$0")/install.mjs" ] && [ "${0##*/}" != bash ]; then SRC="$(cd "$(dirname "$0")" && pwd)"
else
  TMP=$(mktemp -d); trap 'rm -rf "$TMP"' EXIT
  curl -fsSL "https://github.com/$REPO/archive/$REF.tar.gz" | tar -xz -C "$TMP" --strip-components=1; SRC="$TMP"
fi
if ( : </dev/tty ) 2>/dev/null; then node "$SRC/install.mjs" </dev/tty; exit $?; fi   # curl | bash: perguntas lidas do terminal
node "$SRC/install.mjs"

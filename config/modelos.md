# Modelos usados (um lugar so para trocar)

Os IDs ficam nos `install.mjs` (bloco "MODELOS" e função `localModels`). Free tiers mudam toda semana: **teste na vespera da aula**.

| Papel | Claude Code (se voce tem) | Gemini gratis (chave Google) | Gratis sem Google (OpenCode Zen) |
|---|---|---|---|
| maestro | opus | `google/gemini-3.8-flash` | `opencode/deepseek-v4.1-flash-free` |
| gerente | sonnet | `google/gemini-3.8-flash` | `opencode/glm-5.3-flash-free` |
| dev | haiku | `google/gemini-3.5-flash-lite` | `opencode/minimax-m3.1-flash-free` |

Os Gemini 2.5 ficaram restritos a quem ja os usava e o Pro nao tem plano gratis, por isso o 3.x. Os modelos Zen listados nao retem dados; a lista muda: confira com `opencode models opencode`. Local (GPU):
Todos os papeis usam o mesmo modelo.

Local: um modelo por faixa de VRAM (tres modelos diferentes nao cabem juntos; a diferenca entre os papeis vem do prompt e das permissoes). Tags conferidas em ollama.com/library em 2026-10-20; o instalador baixa o modelo e cria uma copia `aula-<modelo>` com o contexto embutido (o padrao do Ollama, 4k, quebra agentes).

| VRAM / memoria | Maestro e gerente | Dev | Observacao |
|---|---|---|---|
| < 8 GB ou sem GPU | nao recomendado | | use Zen/Gemini |
| 8-11 GB | `ornith-1.5:9b` (6,6 GB) | igual | TESTADO aqui (RX 7600 8 GB): cria arquivo e delega, mas ~5 min por tarefa simples |
| 12-15 GB | `gemma4:12b` (8 GB) | igual | nao testado |
| 16-23 GB | `gpt-oss:20b` (14 GB) | igual | nao testado |
| 24-31 GB | `muse-glimmer:30b` (18 GB, Apache-2.0) | igual | nao testado |
| >= 32 GB (nao Mac) | `qwen3.8:27b` (18 GB) | `laguna-xs-2.1` (20 GB, coder) | nao testado; em Mac o laguna pode devolver vazio, o instalador usa muse-glimmer |

Contexto: 64k (>= 16 GB) ou 32k (menos, por causa do KV cache). `AULA_VRAM=16` forca a faixa. Detalhes e fontes: `docs/modelos-locais.md`.

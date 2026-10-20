# Modelos usados (um lugar so para trocar)

Os IDs ficam nos scripts `install.ps1` / `install.sh` (bloco "MODELOS"). Free tiers mudam toda semana: **teste na vespera da aula**.

| Papel | Claude Code (se voce tem) | Gemini gratis (chave Google) | Gratis sem Google (OpenCode Zen) |
|---|---|---|---|
| maestro | opus | `google/gemini-3.8-flash` | `opencode/deepseek-v4.1-flash-free` |
| gerente | sonnet | `google/gemini-3.8-flash` | `opencode/glm-5.3-flash-free` |
| dev | haiku | `google/gemini-3.5-flash-lite` | `opencode/minimax-m3.1-flash-free` |

Os Gemini 2.5 ficaram restritos a quem ja os usava e o Pro nao tem plano gratis, por isso o 3.x. Os modelos Zen listados nao retem dados; a lista muda: confira com `opencode models opencode`. Local (GPU):
Todos os papeis usam o mesmo modelo.

Local usa UM modelo para os tres papeis (tres modelos nao cabem juntos na VRAM). A diferenca entre os papeis vem do prompt e das permissoes.

| VRAM / memoria | Modelo local (nao verificado, testar) |
|---|---|
| >= 24 GB (ou Mac com >= 32 GB) | `qwen3-coder:30b` |
| 12-16 GB | `gpt-oss:20b` |
| < 12 GB ou sem GPU | usar nuvem (modelos pequenos falham em tool calls) |

Contexto minimo: 64k tokens (o instalador define `OLLAMA_CONTEXT_LENGTH=65536`).

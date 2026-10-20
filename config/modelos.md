# Modelos usados (um lugar so para trocar)

Os IDs ficam nos scripts `install.ps1` / `install.sh` (bloco "MODELOS"). Free tiers mudam toda semana: **teste na vespera da aula**.

| Papel | Nuvem (gratis, chave Google) | Local (GPU) |
|---|---|---|
| maestro (orquestrador) | `google/gemini-2.5-pro` | o mesmo modelo local |
| gerente | `google/gemini-2.5-flash` | o mesmo modelo local |
| dev | `google/gemini-2.5-flash-lite` | o mesmo modelo local |

Local usa UM modelo para os tres papeis (tres modelos nao cabem juntos na VRAM). A diferenca entre os papeis vem do prompt e das permissoes.

| VRAM / memoria | Modelo local (nao verificado, testar) |
|---|---|
| >= 24 GB (ou Mac com >= 32 GB) | `qwen3-coder:30b` |
| 12-16 GB | `gpt-oss:20b` |
| < 12 GB ou sem GPU | usar nuvem (modelos pequenos falham em tool calls) |

Contexto minimo: 64k tokens (o instalador define `OLLAMA_CONTEXT_LENGTH=65536`).

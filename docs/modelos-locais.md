# Local models for Ollama + OpenCode class installer (checked 2026-10-20)

Method: fetched ollama.com/library/<model> and /tags pages. Sizes = download of default Q4 tag. "tools" = capability badge on the library page (family level unless noted). Benchmarks are vendor-reported, not independently verified. Quality of all models inside OpenCode: NOT tested by me.

## Global rules (verified)
- Ollama default context is 4k under 24 GiB VRAM, 32k for 24-48 GiB; agents/coding tools need >= 64k. Set `OLLAMA_CONTEXT_LENGTH=64000` (or 32000 on 8-12 GB). https://docs.ollama.com/context-length
- OpenCode + Ollama = custom provider `@ai-sdk/openai-compatible`, baseURL http://localhost:11434/v1, set `limit.context`/`limit.output` per model. If tool calls fail, raise num_ctx (16-32k start). https://opencode.ai/docs/providers/
- OpenCode docs say few models are good at both code and tool calling; no official local-model list. https://opencode.ai/docs/models/
- KV cache adds GB on top of download size; check `ollama ps` shows 100% GPU.

## Table
| VRAM | Pull tag | Size | Tools | Ctx to set | Role |
|---|---|---|---|---|---|
| 8 GB | `ollama pull ornith-1.5:9b` | 6.6 GB | yes (badge) | 16-32k | all roles, weak planner; dev/cheap worker |
| 8 GB alt | `ollama pull lfm2.5:8b` | 5.2 GB (8B-A1B MoE) | yes | 32k | cheap fast worker / tool caller |
| 12 GB | `ollama pull ornith-1.5:9b` (+ `lfm2.5:8b` as worker) | 6.6 / 5.2 GB | yes | 32k | maestro+dev (9b), worker (lfm) |
| 12 GB alt | `gemma4:12b` | ~8.0 GB | family badge yes; per-tag NOT verified | 32k | planning/general |
| 16 GB | `ollama pull gpt-oss:20b` | 14 GB | yes (tools, thinking) | 32-64k | maestro/gerente (reasoning); dev = ornith-1.5:9b |
| 16 GB alt | `lfm2.5:24b` (24B-A2B) | 15 GB | yes | 32k | reasoning agent, tight fit |
| 24 GB | `ollama pull muse-glimmer:30b` | 18 GB | yes | 64k (max 128K) | all roles; Apache 2.0 |
| 24 GB dev alt | `laguna-xs-2.1` (33B-A3B) | 20 GB | yes | 64k | coding agent (dev) |
| 32 GB+ / Mac | `ollama pull qwen3.8:27b` (dense) | 18 GB | yes | 64-128k | maestro/gerente |
| 32 GB+ dev | `laguna-xs-2.1` or `qwen3.6:35b-a3b-coding` (23-24 GB, MoE 3B active) | 20 / 23 GB | yes | 64-128k | dev |
| Mac | add `-mlx`/`-nvfp4` tags (e.g. `muse-glimmer:30b-mlx` 19 GB) | | | | Apple Silicon only |

## Facts per model (source)
- ornith-1.5: tags 9b 6.6 GB, 35b 23 GB (named 35B-A3B, MoE inferred), 256K ctx, tools+thinking+vision. License not stated, no benchmark numbers in text. https://ollama.com/library/ornith-1.5
- lfm2.5: 8b 5.2 GB (125K), 24b 15 GB (128K, ~2B active, always reasons); Liquid says 24B trained in OpenCode; `ollama launch opencode --model lfm2.5:24b` shown. License not stated. https://ollama.com/library/lfm2.5
- gpt-oss:20b 14 GB, 128K, tools+thinking. https://ollama.com/library/gpt-oss (MoE/active-params not on page; from memory ~3.6B active, unverified here)
- muse-glimmer:30b 18 GB, 128K, Apache 2.0, tools, Meta-reported SWE-Bench Pro 51.2, TerminalBench 2.1 51.7 (Qwen3.6-27B 60.7). Active params not stated. https://ollama.com/library/muse-glimmer
- laguna-xs-2.1: 33B/3B active MoE, 20 GB, 256K, SWE-bench Verified 70.9 (vendor), Terminal-Bench 2.0 37.5, license OpenMDW-1.1. WARNING on page: macOS/Metal `ollama run`/`/api/chat` may return empty output; use Linux/CUDA. https://ollama.com/library/laguna-xs-2.1
- qwen3.8:27b dense, 18 GB, 256K, tools+thinking+vision, "stronger autonomous planning"; no numbers readable, license not stated. 4.4M pulls. https://ollama.com/library/qwen3.8
- qwen3.6:35b-a3b-coding 23-24 GB, 256K, tools. https://ollama.com/library/qwen3.6/tags
- nemotron-3.5-lightning 30B-A3B, 19-25 GB, 1M ctx, lists OpenCode launch integration; license not stated, benchmarks only images. https://ollama.com/library/nemotron-3.5-lightning
- gemma4: e4b 6.6-9.5, 12b 8.0, 26b-a4b 18 GB, 31b 20 GB; family has tools badge. https://ollama.com/library/gemma4/tags
- bonsai-2 (ternary): 27b only 8.3 GB, 9b 3.2 GB; tools badge; quality unknown, skip for class. https://ollama.com/library/bonsai-2/tags
- Not suitable (too big): qwen3.8-flash-next 120 GB, nemotron-3.5-bolt 25 GB at iq2 (74B-A9B, 2-bit), ornith-1.5:122b 77 GB.
- granite4.2 (3b 2.2, 8b 5.3, 30b 18 GB, dense, 128K): page lists function-calling but no tools badge in search; unverified for OpenCode.

## Unverified / risks
- No model was actually run in OpenCode by me; tool-call reliability at Q4 on 8-12 GB is the main risk (small models loop/mis-call tools).
- Library is fast-moving (several models updated within days); re-check tags before each class.
- Licenses missing for ornith, qwen3.8, lfm2.5, nemotron-3.5-lightning on library pages (check HF cards before redistributing; class only pulls, so low risk).
- Fit estimates (download + KV at 32-64k) are my approximations, not measured.
- gpt-oss active params and 16GB fit with 64k ctx: unverified.

## Role suggestion for the three agents
- maestro: biggest reasoning model that fits (gpt-oss:20b / muse-glimmer / qwen3.8:27b), thinking on.
- gerente: same model as maestro (avoids reload swaps) or a cheaper one.
- dev: coder-tuned MoE (laguna-xs-2.1, qwen3.6:*-coding) on 24 GB+; ornith-1.5:9b on small cards.
- Single-model setup is the safest for class: Ollama swaps models in VRAM and each swap costs seconds.

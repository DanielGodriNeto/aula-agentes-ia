# Multi-agent coding setup for class - research 2026-10-20
V = verified on official page; U = unverified / third-party only.

## 1. Harnesses
- OpenCode (MIT, V github.com/sst/opencode): custom subagents as md in .opencode/agents/ or ~/.config/opencode/agents/, mode:subagent, per-agent `model: provider/model` (V https://opencode.ai/docs/agents/). Skills read from .opencode/skills, .claude/skills, .agents/skills (V https://opencode.ai/docs/skills/). Windows: `npm install -g opencode-ai` | `scoop install opencode` | `choco install opencode` (V https://opencode.ai/docs/). Docs recommend WSL on Windows. BEST FIT.
  - Caveat: the first fetch of the README showed a wrong npm name (@opencode/cli); the docs page says opencode-ai. Use the docs.
- Qwen Code (Apache-2.0, V LICENSE): subagent md with `model` field: inherit | fast | model-id | provider:model (V qwenlm.github.io/qwen-code-docs/en/users/features/sub-agents/). Auto-skills. Windows: `irm https://qwen-code-assets.oss-cn-hangzhou.aliyuncs.com/installation/install-qwen-standalone.ps1 | iex` or npm (Node 22+) (V README). Good second option; installer is hosted on Alibaba OSS (security-conscious: prefer npm).
- Crush (FSL-1.1-MIT, NOT plain OSI open source yet): Agent Skills yes, subagents not documented, model switch via ctrl+l. `winget install charmbracelet.crush` (V README).
- Aider (V aider.chat/docs/usage/modes.html): no subagents; only architect + editor two-model split (--model / --editor-model). Not an orchestrator pattern.
- Goose (Apache-2.0 V README): README silent on subagents/per-subagent model/skills; docs page 404. Windows CLI install: not verified (desktop app exists).
- Gemini CLI (Apache-2.0): README says it was REPLACED by Antigravity CLI on 2026-06-18 for unpaid tier and Google One users (V github.com/google-gemini/gemini-cli). Antigravity CLI is not confirmed open source (U, thenewstack). DO NOT use Gemini CLI for free class.
- Kilo/Cline: not checked.

## 2. Free APIs (30-100 students, own key each)
- Gemini API: free tier models (Flash family 3.8/3.6/3.5, Flash-Lite, 2.5 Pro/Flash/Flash-Lite, Gemma 4); Gemini 3.1 Pro / 4 Argon NOT free (V https://ai.google.dev/gemini-api/docs/pricing). Free-tier content IS "used to improve our products"; paid is not (V same page). Limits are per PROJECT not per key; RPD resets midnight Pacific (V rate-limits page). Exact RPM/RPD NOT published on the page, see AI Studio (U: third-party says ~10-15 RPM, low RPD). Region availability for Brazil: not verified.
- OpenRouter `:free` models: 20 req/min; 50 req/day if <10 credits bought, 1000/day if >=10 credits (V https://openrouter.ai/docs/api-reference/limits). 50/day is too low for agent use; free pool changes often (examples seen: MiniMax M3.1 Flash free, Nemotron 3.5 Super VL free; V openrouter.ai/models?max_price=0 at fetch time). Free-model providers may log prompts (U).
- Groq: table shows gpt-oss-120b/20b, qwen3.8-27b at 30 RPM, 1K RPD, 8K TPM, 200K TPD, but labeled "Developer plan" base limits; free-plan numbers not isolated (partial V https://console.groq.com/docs/rate-limits). 8K TPM is too small for agents with large contexts (an agent turn alone can exceed it).
- Cerebras: NO permanent free tier now. Free Trial = $5 credit with verified payment method, expires in 30 days; gpt-oss-120b / qwen-3.8-27b 5 RPM, 1M tokens/day (V https://inference-docs.cerebras.ai/support/rate-limits). Not suitable for a class.
- Mistral: official pages 404'd; free "Experiment" plan limits and training opt-in are U (third-party says phone verification, data may be used for training). Check console Limits page.
- Verdict: free tiers are shared-rate, small TPM and change often. Class with 30-100 live users hitting the same provider from one classroom IP is fine (limits are per key/project), but each student needs their own Google project/account. Have a fallback (local or Ollama cloud).

## 3. Local models (Ollama)
- Ollama lists tools-capable models at ollama.com/search?c=tools. qwen3-coder:30b = 19GB download, tools, 256K ctx (V ollama.com/library/qwen3-coder). Top pulls now: qwen3.8:27b (4.4M pulls, V search page). Cloud models listed: glm-5.3, glm-5.3-flash, minimax-m3, deepseek-v4.1-flash.
- Tier suggestions (U, from blogs morphllm.com/best-ollama-models, localaimaster.com; conflicting; test before class):
  - CPU only / no GPU: do NOT run agents locally; use a free cloud API or Ollama cloud. Tiny models (<=4B) fail multi-step tool calls (U general experience).
  - 6-8GB: qwen3.5:9b (~6.6GB) ; qwen2.5-coder:7b is older.
  - 12-16GB: gpt-oss:20b (~14GB, Apache-2.0) or devstral:24b (14GB, 46.8% SWE-bench Verified per blog).
  - 24GB+ / 32GB Mac: qwen3-coder:30b (MoE, 3.3B active) or qwen3.8:27b / qwen3.6:27b (sources disagree on top pick).
  - No source gave verified per-model tool-call success rates. Not verified.
- MUST set context >= 64k: OpenCode requires 64k (V https://docs.ollama.com/integrations/opencode); Ollama says same for Claude Code (V https://docs.ollama.com/integrations/claude-code). Blog says default is 4k under 24GB VRAM (U).
- Shortcut: `ollama launch opencode` / `ollama launch claude` (V docs.ollama.com).

## 4. Claude Code free / alternative backends
- Free plan does NOT include Claude Code; Pro $20/mo ($17 annual), Max from $100 (V https://claude.com/pricing). No individual student discount on that page; only institution Education plan. Claims of Campus/CodePath programs: U (blogs only).
- Claude Code needs a Claude subscription or Console account (V https://code.claude.com/docs/en/overview).
- ANTHROPIC_BASE_URL works for gateways (V https://code.claude.com/docs/en/llm-gateway-connect) with ANTHROPIC_AUTH_TOKEN. BUT Anthropic "doesn't support routing Claude Code to non-Claude models through any gateway" (V https://code.claude.com/docs/en/llm-gateway). Works in practice with Ollama: ANTHROPIC_AUTH_TOKEN=ollama, ANTHROPIC_API_KEY="", ANTHROPIC_BASE_URL=http://localhost:11434 (V https://docs.ollama.com/integrations/claude-code) and Ollama cloud base https://ollama.com with OLLAMA_API_KEY; cloud has no hosted WebSearch. Known 400s with non-Anthropic upstreams; workaround CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS=1 (V troubleshooting table). Does Ollama cloud have a free tier? not verified.
- Windows install: `irm https://claude.ai/install.ps1 | iex`; also `winget install Anthropic.ClaudeCode`; mac/Linux `curl -fsSL https://claude.ai/install.sh | bash` (V overview). Claude Code itself is proprietary (not open source) (U for license, not checked).
- Per-agent model routing works in Claude Code only with models that gateway exposes; set CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY=1 to list them (V).

## 5. Claude Code mechanics (for slides)
- Subagent = md file with YAML frontmatter in .claude/agents/ (project) or ~/.claude/agents/ (user); only name+description required; fields: tools, disallowedTools, model, skills, permissionMode, maxTurns, memory, effort, isolation (V https://code.claude.com/docs/en/sub-agents).
- Model resolution order: per-invocation param > subagent frontmatter > CLAUDE_CODE_SUBAGENT_MODEL env > main model. `model` accepts opus|sonnet|haiku|fable alias, full ID, or inherit. CLAUDE_CODE_SUBAGENT_MODEL_FORCE=1 forces one model on all (v2.1.257+). Built-in Explore/Plan agents keep their own model unless overridden by a same-named agent (V).
- Skills: dir with SKILL.md; frontmatter (description recommended; name; model; context: fork; agent). Locations: ~/.claude/skills, .claude/skills, plugin. Progressive disclosure: only name+description always in context (1,536 chars cap), full body on invocation, supporting files on reference (V https://code.claude.com/docs/en/skills). `skills:` in a subagent preloads full skill content (<=32).
- Aliases: `opusplan` = opus in plan mode, sonnet for execution (V https://code.claude.com/docs/en/model-config). Opus 5.5 / Sonnet 5.5 / Haiku 5.5 on Anthropic API.
- Tokens (V https://platform.claude.com/docs/en/about-claude/models/overview): Fable 5.1 $10 in/$50 out per MTok; Opus 5.5 $4/$20; Sonnet 5.5 $2/$10; Haiku 5.5 from $0.10/$0.50. All: 1M context, 128K max output. Output costs 5x input. Batch -50%. Haiku 5.5 costs more per token above 100K prompt (model-config).
- Prompt caching (V https://platform.claude.com/docs/en/build-with-claude/prompt-caching): write 5-min 1.25x, 1-h 2x; read 0.1x (0.05x Opus 5.5/Sonnet 5.5, 0.025x Fable 5.1); TTL 5 min refreshed on hit; min 512 tokens for 5.x models.
- Auto-compact for 1M models at ~967K (model-config).

## Recommendation
OpenCode (MIT) with 3 subagent md files (manager = mid model, worker = small), each with own `model:`; students use a free Gemini Flash key (accept training-on-data caveat, tell them no private code) + OpenRouter/Groq fallback; GPU students use ollama (ctx 64k). Show Claude Code as the reference design only (slides), or demo it live from the teacher's account. Risks: free limits/models change weekly (test the day before, have a recorded fallback); Gemini free data used for training. Reversible: yes (md files + config, portable to Qwen Code).

# Aula: agentes de IA na prática

Time de agentes de IA **grátis** (maestro → gerente → dev), instalado com um comando. O instalador faz perguntas de sim/não e caixas de marcar: tem **Claude Code** e/ou **Codex** (assinatura)? Onde rodar: **nuvem grátis** (OpenCode Zen, sem chave, login ou cartão) e/ou **no meu PC** (modelo local escolhido pela sua placa: 8 GB ornith 9B · 12 gemma4 12B · 16 gpt-oss 20B · 24 muse-glimmer 30B · 32+ qwen3.8 27B + laguna). Pode marcar os dois; também pode somar o **Gemini** (chave do Google; o Google pode treinar com seus prompts). Comparativo: [docs/modelos-gratis.md](docs/modelos-gratis.md). Depois da aula, leia [COMO-USAR.md](COMO-USAR.md).

## Instalar

Windows (PowerShell):
```powershell
irm https://raw.githubusercontent.com/DanielGodriNeto/aula-agentes-ia/main/install.ps1 | iex
```
macOS / Linux:
```bash
curl -fsSL https://raw.githubusercontent.com/DanielGodriNeto/aula-agentes-ia/main/install.sh | bash
```
O instalador é um script Node ([install.mjs](install.mjs)); `install.ps1` e `install.sh` só garantem o Node e o executam. Ele instala agentes e skills, o workflow [instrucoes/AGENTS.md](instrucoes/AGENTS.md) (com regras contra injeção de prompt; no Claude/Codex vai num bloco marcado, sem apagar o que existe), cria a pasta de projetos e copia os exercícios.

Pular perguntas por variável de ambiente (PowerShell: `$env:AULA_X='...'` antes do comando; bash: `... | AULA_X=... bash`): `AULA_CLAUDE`, `AULA_CODEX`, `AULA_CLOUD`, `AULA_PC` (0/1), `AULA_GEMINI`, `AULA_GEMINI_KEY`, `AULA_GEMINI_MODEL` (padrão `google/gemini-3.5-flash-lite`), `AULA_DOWNLOAD`, `AULA_GITHUB_DIR` (vazio = não criar), `AULA_EXERCISES`, `AULA_EXTRAS` (lista, `all` ou `none`: scrapling-official, break-ui, animate, diagnosing-bugs, verification-loop), `AULA_WEB`, `AULA_PERM` (`ask`, `balanced`, `free`), `AULA_SHARE`, `AULA_VRAM`, `AULA_YES`. Padrões seguros: pergunta tudo, sem navegar na web, sem compartilhar sessão.

Leia o script antes: não usa `sudo` e faz backup de `~/.config/opencode`. A chave do Gemini, se você a colar, é pedida sem eco, validada com uma chamada e guardada no arquivo privado do OpenCode; nunca é impressa.

> **Privacidade:** no plano grátis o Google pode usar seus prompts para treinar. Não envie senhas, dados pessoais ou código privado.

## O que tem aqui
| Pasta | Conteúdo |
|---|---|
| [PLANEJAMENTO.md](PLANEJAMENTO.md) | Roteiro de 2 h, crítica do plano, riscos, checklist, diário de decisões |
| `agents/` `agents-claude/` | `maestro`, `gerente`, `dev` (OpenCode / Claude Code) |
| `skills/` | próprias: `rotear-tarefa`, `ui-basico`, `feature-assessment`, `repo-howto`, `readme-design`; `handoff`, `humanizer`, `grill-me`, `project-map`; de terceiros: `frontend-design`, `emil-design-eng`, `systematic-debugging` ([licenças](THIRD_PARTY.md)) |
| `exercicios/` | 3 exercícios + PDF de teste de injeção de prompt |
| `instrucoes/` `COMO-USAR.md` | Workflow genérico instalado nos agentes e tutorial pós-aula |
| `config/` | Configuração nuvem/local e [tabela de modelos](config/modelos.md) |
| `slides/index.html` | Apresentação (abra no navegador) |
| `certificado/index.html` | Modelo imprimível: `?nome=Fulano` |
| `docs/pesquisa.md` | Fontes e pontos não verificados |

Equivalência com o Claude Code: maestro = Opus, gerente = Sonnet, dev = Haiku.

Licença MIT.

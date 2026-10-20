# Aula: agentes de IA na prática

Time de agentes de IA **grátis** (maestro → gerente → dev), instalado com um comando. O instalador escolhe sozinho: **Claude Code** se você já tem; senão **modelo local** (GPU NVIDIA/Apple com 12 GB+); senão os **modelos grátis do OpenCode Zen** (sem chave, sem login, sem cartão, sem retenção de dados). `AULA_MODE=cloud` usa Gemini com chave grátis (o Google pode treinar com seus prompts). Comparativo: [docs/modelos-gratis.md](docs/modelos-gratis.md).

## Instalar

Windows (PowerShell):
```powershell
irm https://raw.githubusercontent.com/DanielGodriNeto/aula-agentes-ia/main/install.ps1 | iex
```
macOS / Linux:
```bash
curl -fsSL https://raw.githubusercontent.com/DanielGodriNeto/aula-agentes-ia/main/install.sh | bash
```
Forçar um modo: PowerShell `$env:AULA_MODE='free'` antes do comando; bash `... | AULA_MODE=free bash` (valores: `claude`, `cloud`, `free`, `local`). `AULA_EXTRAS=1` instala também as skills de `skills-extras/` (scrapling, break-ui, animate, diagnosing-bugs, verification-loop). Os exercícios vão para `~/aula-agentes-ia-exercicios`.

Leia o script antes ([install.ps1](install.ps1), [install.sh](install.sh)): não pede chave, não usa `sudo`, faz backup de `~/.config/opencode` (modo Claude Code: só copia agentes/skills para `~/.claude`).

Só no modo `cloud`: crie uma chave em <https://aistudio.google.com/apikey>, rode `opencode auth login` (Google) e depois `opencode` numa pasta vazia.

> **Privacidade:** no plano grátis o Google pode usar seus prompts para treinar. Não envie senhas, dados pessoais ou código privado.

## O que tem aqui
| Pasta | Conteúdo |
|---|---|
| [PLANEJAMENTO.md](PLANEJAMENTO.md) | Roteiro de 2 h, crítica do plano, riscos, checklist, diário de decisões |
| `agents/` `agents-claude/` | `maestro`, `gerente`, `dev` (OpenCode / Claude Code) |
| `skills/` | próprias: `rotear-tarefa`, `ui-basico`, `feature-assessment`, `repo-howto`, `readme-design`; `handoff`, `humanizer`, `grill-me`, `project-map`; de terceiros: `frontend-design`, `emil-design-eng`, `systematic-debugging` ([licenças](THIRD_PARTY.md)) |
| `exercicios/` | 3 exercícios + PDF de teste de injeção de prompt |
| `config/` | Configuração nuvem/local e [tabela de modelos](config/modelos.md) |
| `slides/index.html` | Apresentação (abra no navegador) |
| `certificado/index.html` | Modelo imprimível: `?nome=Fulano` |
| `docs/pesquisa.md` | Fontes e pontos não verificados |

Equivalência com o Claude Code: maestro = Opus, gerente = Sonnet, dev = Haiku.

Licença MIT.

# Aula: agentes de IA na prática

Time de agentes de IA **grátis** (maestro → gerente → dev), instalado com um comando. O instalador **pergunta** qual você prefere, mostrando o bom e o ruim de cada um: **Claude Code** (assinatura), **Zen grátis** (sem chave, login ou cartão, sem retenção de dados), **Gemini grátis** (chave do Google; o Google pode treinar com seus prompts), **Zen + Gemini** (Gemini só no maestro) ou **modelo local** escolhido pela sua placa (8 GB: ornith 9B · 12: gemma4 12B · 16: gpt-oss 20B · 24: muse-glimmer 30B · 32+: qwen3.8 27B + laguna). Comparativo: [docs/modelos-gratis.md](docs/modelos-gratis.md).

## Instalar

Windows (PowerShell):
```powershell
irm https://raw.githubusercontent.com/DanielGodriNeto/aula-agentes-ia/main/install.ps1 | iex
```
macOS / Linux:
```bash
curl -fsSL https://raw.githubusercontent.com/DanielGodriNeto/aula-agentes-ia/main/install.sh | bash
```
Forçar um modo: PowerShell `$env:AULA_MODE='free'` antes do comando; bash `... | AULA_MODE=free bash` e pular a pergunta (valores: `claude`, `cloud`, `free`, `both`, `local`; `AULA_VRAM=16` força a faixa de placa). `AULA_EXTRAS=1` instala também as skills de `skills-extras/` (scrapling, break-ui, animate, diagnosing-bugs, verification-loop). Os exercícios vão para `~/aula-agentes-ia-exercicios`.

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

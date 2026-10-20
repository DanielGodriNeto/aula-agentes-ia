# Aula: agentes de IA na prática

Time de agentes de IA **grátis** (maestro → gerente → dev), instalado com um comando. Detecta sua placa de vídeo e escolhe sozinho entre modelo local (GPU) e nuvem grátis (Gemini).

## Instalar

Windows (PowerShell):
```powershell
irm https://raw.githubusercontent.com/DanielGodriNeto/aula-agentes-ia/main/install.ps1 | iex
```
macOS / Linux:
```bash
curl -fsSL https://raw.githubusercontent.com/DanielGodriNeto/aula-agentes-ia/main/install.sh | bash
```
Leia o script antes ([install.ps1](install.ps1), [install.sh](install.sh)): não pede chave, não usa `sudo`, faz backup de `~/.config/opencode`.

Depois, na nuvem: crie uma chave em <https://aistudio.google.com/apikey>, rode `opencode auth login` (Google) e depois `opencode` numa pasta vazia.

> **Privacidade:** no plano grátis o Google pode usar seus prompts para treinar. Não envie senhas, dados pessoais ou código privado.

## O que tem aqui
| Pasta | Conteúdo |
|---|---|
| [PLANEJAMENTO.md](PLANEJAMENTO.md) | Roteiro de 2 h, crítica do plano, riscos, checklist, diário de decisões |
| `agents/` | `maestro`, `gerente`, `dev` (modelo por papel) |
| `skills/` | `rotear-tarefa`, `ui-basico` |
| `config/` | Configuração nuvem/local e [tabela de modelos](config/modelos.md) |
| `slides/index.html` | Apresentação (abra no navegador) |
| `certificado/index.html` | Modelo imprimível: `?nome=Fulano` |
| `docs/pesquisa.md` | Fontes e pontos não verificados |

Equivalência com o Claude Code: maestro = Opus, gerente = Sonnet, dev = Haiku.

Licença MIT.

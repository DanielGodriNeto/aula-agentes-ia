# Skills de terceiros incluídas (cópias fixadas)

Cada uma pertence ao seu autor; a licença segue dentro da pasta da skill. Antes de incluir, o conteúdo foi lido por busca de padrões suspeitos (comandos de rede, `eval`, `base64`, instruções "ignore as anteriores", leitura de segredos): nada encontrado. Isso **não** garante segurança total: leia o `SKILL.md` antes de instalar qualquer skill de terceiros.

| Skill | Origem | Commit | Licença |
|---|---|---|---|
| `frontend-design` | https://github.com/anthropics/skills (skills/frontend-design) | dbd4588 | Apache-2.0 |
| `emil-design-eng` | https://github.com/emilkowalski/skills (skills/emil-design-eng) | 2d22863 | MIT |
| `systematic-debugging` | https://github.com/obra/superpowers (skills/systematic-debugging; sem os scripts de exemplo) | bb92a77 | MIT |

Não incluída por peso (SKILL.md de ~67 KB, pesado para cota grátis): `hallmark` (https://github.com/Nutlope/hallmark, MIT). Para usar: `git clone` e copie `skills/hallmark` para `~/.config/opencode/skills/`.

Skills próprias (MIT): `rotear-tarefa`, `ui-basico`, `feature-assessment`, `repo-howto`, `readme-design`, `handoff`, `humanizer`, `grill-me`, `project-map` (as quatro últimas vêm do conjunto pessoal do autor; confira a origem antes de redistribuir).

Em `skills-extras/` (instalação opcional com `AULA_EXTRAS=1`): `scrapling-official` (BSD-3-Clause, https://github.com/D4Vinci/Scrapling, precisa de Python + `pip install scrapling` e navegadores; só scraping autorizado, sempre `--ai-targeted`), `break-ui` e `animate` (Emil Kowalski, MIT), `diagnosing-bugs` (Matt Pocock, MIT), `verification-loop`.

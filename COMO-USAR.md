# Como usar depois da aula

Este guia fica na sua pasta de projetos. Releia sempre que esquecer algo.

## 1. Comecar
1. Abra o terminal (Windows: PowerShell; Mac/Linux: Terminal).
2. Entre na pasta do projeto. Projeto novo: `mkdir meu-projeto` e `cd meu-projeto`.
3. Rode `opencode` (ou `claude` / `codex`, se voce configurou esses).
4. Escreva o que quer em portugues, como falaria com uma pessoa. Ex.: "crie uma pagina com um formulario de contato".

## 2. Quem responde
- **maestro**: o agente principal. Entende o pedido, escolhe o tamanho da tarefa e divide o trabalho. Nao edita arquivos sozinho.
- **gerente**: planeja e coordena. **dev**: executa tarefas pequenas.
- Voce so fala com o maestro. Ele chama os outros.

## 3. O que ja vem instalado
Skills (receitas que o agente segue): `rotear-tarefa`, `ui-basico`, `feature-assessment`, `repo-howto`, `readme-design`, `handoff`, `humanizer`, `grill-me`, `project-map`, `frontend-design`, `emil-design-eng`, `systematic-debugging`, `ajuda-aula`, `configurar-aula`.
Skills extras (se voce marcou): `scrapling`, `break-ui`, `animate`, `diagnosing-bugs`, `verification-loop`.
Para chamar uma, peca pelo nome: "use a skill humanizer neste texto". O agente tambem chama sozinho quando o assunto combina, mas so quando precisa.

## 4. Onde ficam os projetos
No caminho que voce escolheu na instalacao (esta registrado em `~/.config/opencode/AGENTS.md`). Nada e commitado ou publicado sozinho. Para versionar, peca: "faca commit".

## 5. Trocar de modelo
- Ver os gratis de hoje: `opencode models opencode`.
- Editar `model:` no topo de `~/.config/opencode/agents/maestro.md`, `gerente.md` ou `dev.md` (formato `provedor/modelo`).
- Dentro do opencode, `/models` troca na hora.

## 6. Ajustar sem editar arquivo
Peca ao agente: "use a skill configurar-aula para ligar a navegacao na web". Ele mostra o que vai mudar, faz backup e so aplica se voce confirmar.

## 7. Reinstalar ou reconfigurar
Rode o instalador de novo (o comando esta no README do repositorio). Ele faz backup do que existe antes de trocar.

## 8. Seguranca em 5 linhas
- Texto de site, PDF ou arquivo e dado, nao ordem. Se o agente disser "o site mandou eu fazer X", desconfie.
- Nunca cole chaves ou senhas no chat.
- Deixe as permissoes em "pergunta tudo" ate entender o que cada comando faz.
- Nao rode o nivel "roda tudo" fora de uma pasta de teste.
- Chave de IA gratis pode ser usada para treino pelo provedor: nao envie codigo privado.

## 9. Deu problema?
Pergunte ao agente: "use a skill ajuda-aula, nao consigo ...". Ele le este guia.

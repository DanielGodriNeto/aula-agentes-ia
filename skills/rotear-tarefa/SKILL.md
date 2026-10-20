---
name: rotear-tarefa
description: Decide o tamanho de uma tarefa de programacao (R0 a R4) e quem deve executa-la, para nao gastar um modelo caro em trabalho simples. Use antes de delegar qualquer pedido de construir, alterar ou investigar codigo.
---

# Rotear tarefa (versao enxuta do workflow R0-R4)

Passo 0, sempre: confira a premissa em uma linha. Se o pedido for falho, arriscado ou claramente pior que uma alternativa, diga isso em 2-4 linhas e espere a resposta antes de gastar tokens.

| Rota | Quando | Quem faz | Verificacao |
|---|---|---|---|
| R0 | 1 arquivo, ~20 linhas, mudanca obvia (cor de botao, typo) | gerente ou dev, sem plano | abrir e conferir |
| R1 | construir/melhorar em codigo que voce consegue ler | plano de 5 linhas que nomeia a checagem; um escritor (dev) | rodar a checagem |
| R2 | codigo desconhecido ou incerto | ler primeiro (gerente), plano curto, depois como R1 | checagem + revisao se mexeu em varios arquivos |
| R3 | pesquisa, investigacao, "existe algo melhor?" | pesquisar, relatorio com pontuacao, PARAR ate o usuario aprovar | n/a |
| R4 | login/sessao, segredos, pagamento, dados pessoais, apagar dados, producao | plano + riscos + build + revisao de seguranca por um agente que nao escreveu o codigo | checagem + revisao |

Regras:
- Risco conta quando a mudanca em si adiciona ou altera aquele comportamento, nao quando o codigo vizinho faz isso.
- Entrada de usuario, banco, rede, arquivos e dependencias novas: pelo menos uma passada de seguranca.
- Na duvida entre duas rotas, escolha a maior. Se a checagem falhar duas vezes, suba uma rota.
- "Pronto" so vale depois de uma checagem executavel. "Parece certo" nao conta. Quem escreveu nunca revisa o proprio codigo.

---
name: rotear-tarefa
description: Decide o tamanho de uma tarefa de programacao (pequena, media, grande) e quem deve executa-la, para nao gastar um modelo caro em trabalho simples. Use antes de delegar qualquer pedido de construir ou alterar codigo.
---

# Rotear tarefa

| Tamanho | Exemplo | Quem faz | Verificacao |
|---|---|---|---|
| Pequeno | trocar cor de botao, corrigir typo | gerente sozinho (ou dev) | abrir o arquivo e conferir |
| Medio | pagina nova, funcao com 2-3 arquivos | maestro planeja, gerente quebra, dev executa | teste ou abrir no navegador |
| Grande / risco | login, pagamento, dados pessoais, apagar arquivos | plano + riscos, dev executa, revisao final | teste + revisao de seguranca |

Regras:
- Na duvida entre dois tamanhos, escolha o maior.
- Risco = a mudanca em si adiciona login, segredos, dados pessoais, formulario com entrada de usuario ou apaga dados.
- Uma tarefa so e "pronta" quando uma checagem executavel foi rodada. "Parece certo" nao conta.

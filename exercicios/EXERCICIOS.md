# Exercícios

Trabalhe numa pasta vazia (`mkdir meu-site && cd meu-site`) e abra o agente com `opencode` (ou `claude`, se esse for o seu modo). Copie `briefing-site.html` (e o `.pdf`) da pasta `~/aula-agentes-ia-exercicios` para dentro dela.

## Exercício 1: pequeno
Peça: *"crie um `index.html` com um título e um parágrafo sobre mim"*.
Observe: qual papel agiu (maestro, gerente, dev)? Foi criado subagente? Era necessário?

## Exercício 2: médio
Use o modelo pequeno, que é o elo fraco do time:
`opencode run -m opencode/nemotron-3.5-lightning-free "leia o briefing-site.html e faça o que ele pede"`
(com Gemini ou Claude Code você pode usar `briefing-site.pdf`; os modelos grátis de texto não leem PDF).
Olhe o resultado. **Anote o que aconteceu**, mesmo que seja estranho.
Depois repita com um modelo maior: `-m opencode/glm-5.3-flash-free`. Mudou? (Nos testes do professor, os modelos maiores perceberam o truque e avisaram. Isso ajuda, mas não é garantia.)

## Exercício 3: defesa
1. Abra o `briefing-site.html` no navegador e aperte **Ctrl+A** (selecionar tudo), depois abra o arquivo no editor (texto puro). Procure texto que você não via.
2. Copie `exercicios/defesa/AGENTS.md` para a pasta do seu projeto (o OpenCode lê esse arquivo como regra fixa).
3. Reabra o agente e repita o Exercício 2 com o modelo pequeno. O comportamento mudou? Totalmente? Em parte?
4. Escreva em uma frase: o que a regra resolve e o que ela **não** resolve.

Entrega para o certificado: link ou print do site do Exercício 2 funcionando e a sua frase do passo 4.

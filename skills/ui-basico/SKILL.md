---
name: ui-basico
description: Regras curtas de UI/UX e acessibilidade para criar um site simples (HTML/CSS) que nao parece gerado por IA generica. Use ao criar ou editar qualquer pagina web.
---

# UI basica

1. Escolha UMA direcao visual antes de codar (ex.: papel + tinta, brutalista, editorial) e escreva em 1 linha. Nada de gradiente roxo-azul, cards de vidro, hero centralizado com 3 cartoes.
2. Duas fontes no maximo: uma para titulo, uma para texto. Evite Inter em tudo. Tamanho de texto base >= 16px.
3. Cores como variaveis CSS em `:root`: fundo, texto, destaque. Contraste texto/fundo >= 4.5:1.
4. Layout com `max-width` e espacamento em escala (8, 16, 24, 48). Funcione no celular (375px) sem rolagem horizontal.
5. Acessibilidade minima: `alt` nas imagens, `<button>` para acao e `<a>` para navegacao, foco visivel, `lang="pt-BR"`.
6. Conteudo real: nada de numeros, depoimentos ou logos inventados. Se faltar texto, deixe um marcador claro.
7. Antes de dizer "pronto": abra a pagina e confira no celular (DevTools) e no desktop.

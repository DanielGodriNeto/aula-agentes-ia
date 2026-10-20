# Planejamento da aula: introducao a sistemas agenticos

Aula aberta, online, ate 2 h. Diario de decisoes no fim (secao 9). Fontes das afirmacoes tecnicas: `docs/pesquisa.md`.

## 1. Objetivo
Ao fim da aula cada participante: (1) explica o que e token, contexto e custo; (2) entende por que um time de modelos (forte planeja, medio gerencia, pequeno executa) gasta menos que um modelo forte fazendo tudo; (3) tem um sistema agentico **gratis** rodando na propria maquina e (4) entregou um site basico feito por ele.

## 2. Critica da ideia original (o que muda e por que)
| # | Problema | Decisao |
|---|---|---|
| 1 | Gemini **nao e open source**; e gratis so no tier de API, e o Gemini CLI gratuito foi encerrado em 2026-06-18 | Harness = **OpenCode (MIT)**. Modelo = Gemini API gratis (nuvem) ou Ollama (local). Na aula dizer "gratis", nao "open source", para o Gemini |
| 2 | Tier gratis do Google **pode usar os prompts para treino** | Aviso no instalador e no slide: so codigo nao privado, sem dados pessoais |
| 3 | 30-100 pessoas em tier gratis: o limite e por projeto/chave. Hierarquia de 3 niveis **multiplica as chamadas** e o modelo "Pro" gratis tem cota baixa | Orquestrador (Pro) so planeja e confere; trabalho pesado em Flash/Flash-Lite. Plano B documentado: modelo local ou Flash em todos os papeis |
| 4 | Local: tres modelos diferentes nao cabem na VRAM | Local usa **um** modelo nos tres papeis; a diferenca vem de prompt e permissoes. Limiar: >= 12 GB de VRAM (NVIDIA) ou Mac com memoria unificada; abaixo disso, nuvem (modelos pequenos erram chamada de ferramenta) |
| 5 | "Kimi coder" nao foi verificado como opcao pratica | Candidatos locais: `qwen3-coder:30b` (24 GB+) e `gpt-oss:20b` (12-16 GB). **Testar em maquina real antes da aula** |
| 6 | Instalar com 1 comando em 100 maquinas desconhecidas vai falhar em parte | Instalacao **na vespera** (email com o link), na aula so um "health check". Plano B: ver secao 6 |
| 7 | `curl \| bash` ensina mau habito | O proprio script e conteudo da aula: abrir o arquivo e ler junto (5 min de seguranca) |
| 8 | Bloco de tokens por 30 min no inicio perde a turma | Maximo 15 min, com demo ao vivo de tokenizador, e a instalacao rodando ao fundo |
| 9 | Brasil: disponibilidade do tier gratis da Gemini API **nao verificada** | Teste com uma conta brasileira antes da aula |
| 10 | Certificado: sem criterio vira brinde | Emitido a quem enviar o site feito (link ou print). Texto honesto: "certificado de participacao", sem carga horaria oficial salvo vinculo institucional |
| 11 | "Opus/Sonnet/Haiku" no ar nao e gratis | Claude Code real = **demo do professor** (conta propria) ou video gravado. Alunos usam o equivalente gratis. Mostrar o mapeamento 1:1 nos slides |
| 12 | Hierarquia de 3 niveis (gerente chamar dev) depende do OpenCode permitir subagente chamar subagente. Pesquisa: docs estaveis nao dizem; docs v2 dizem profundidade padrao = 1 | **A verificar no ensaio** (`opencode --version` + smoke test). Fallback: o maestro chama gerente e dev diretamente (editar `permission.task` do maestro) |
| 13 | Gemini 2.5 esta restrito a quem ja o usava e o Pro nao tem plano gratis; alunos novos podem nao ter acesso | Padrao agora: `gemini-3.8-flash` (maestro/gerente) e `gemini-3.5-flash-lite` (dev). Cotas gratis nao sao publicadas: ver no AI Studio |
| 14 | Aluno sem Claude Code **e** sem conta Google | Modo `free` (agora o padrao): modelos gratis do OpenCode Zen (sem retencao: glm/deepseek/minimax). **Testado 2026-10-20: funcionam sem login e sem chave.** Risco: limites nao publicados, 100 alunos no mesmo IP podem tomar 429 (piloto com 30 alunos). Alternativas: OpenRouter `:free` (50 req/dia), NVIDIA NIM. Descartados: Cerebras (exige cartao), GitHub Models (encerrado 30/07/2026) |
| 15 | Injecao de prompt: tema ausente | Bloco proprio com 3 exercicios e PDF de teste (secao 5b). Os agentes saem **sem** defesa de proposito, para o ataque funcionar |

## 3. Arquitetura
```
usuario -> maestro (modelo forte; so planeja/confere; sem editar)
              |  plano digerido
              v
           gerente (modelo medio; quebra, checa, passada de seguranca)
              |  tarefa minuscula
              v
            dev (modelo pequeno; edita 1 arquivo)
```
Roteamento por tamanho (skill `rotear-tarefa`): pequeno vai direto ao gerente/dev sem plano; medio tem plano; grande/risco tem plano + riscos + revisao. Seguranca e verificacao executavel fazem parte do fluxo, nao sao opcionais.

| Papel | Claude Code | Gemini gratis | Zen gratis | Local |
|---|---|---|---|---|
| maestro | opus | gemini-3.8-flash | deepseek-v4.1-flash-free | um modelo por faixa de VRAM (ornith 9B ... muse-glimmer 30B; ver config/modelos.md) |
| gerente | sonnet | gemini-3.8-flash | glm-5.3-flash-free | idem |
| dev | haiku | gemini-3.5-flash-lite | minimax-m3.1-flash-free | idem |

## 4. Entregaveis (este repositorio)
- `install.mjs` (Node; `install.ps1`/`install.sh` so o executam): perguntas sim/nao e caixas (Claude Code/Codex, nuvem e/ou PC, Gemini, pasta de projetos, exercicios, personalizar), instala OpenCode (+Ollama), agentes, skills, workflow AGENTS.md e COMO-USAR.md, com backup.
- `agents-claude/`: os mesmos tres papeis com `model: opus/sonnet/haiku`, para quem ja tem Claude Code.
- `exercicios/`: PDF de teste (texto oculto), 3 exercicios, `defesa/AGENTS.md`.
- `skills/` + `THIRD_PARTY.md`: 5 proprias e 3 de terceiros com licenca (nao incluida: hallmark, 67 KB).
- `agents/`, `skills/`, `config/`: o time e as regras. Modelos trocaveis em um unico bloco do instalador.
- `slides/index.html`: apresentacao (setas / espaco navegam; `F` tela cheia).
- `certificado/`: modelo imprimivel (nome via `?nome=`), sem nomes no repositorio.

## 5. Roteiro (120 min)
| Min | Bloco | Conteudo | Aluno faz |
|---|---|---|---|
| 0-8 | Abertura | Objetivo, mapa da aula, link do instalador no chat | Roda o instalador (continua ao fundo) |
| 8-23 | Bases de IA | LLM, token (tokenizador ao vivo), contexto, entrada x saida, custo, cache | Conta tokens de uma frase |
| 23-38 | Agentes | Loop agente, ferramentas, skills, subagentes, por que 3 niveis economizam | - |
| 38-48 | Seguranca | Ler o `install.ps1` ao vivo; tier gratis e privacidade; permissoes do agente | Le o script |
| 48-63 | Demo do professor | Claude Code real (Opus > Sonnet > Haiku): tarefa pequena (sem subagente) x media (com plano) | Assiste, compara |
| 63-78 | Primeira execucao | Chave gratis (`opencode auth login`) ou Ollama; health check; "oi" ao maestro | Roda e confere |
| 78-110 | Mao na massa | Tarefa: site basico (skill `ui-basico`). Primeiro pedido pequeno, depois medio | Gera o site |
| 110-120 | Fechamento | Mostra 2-3 sites, erros comuns, proximos passos, certificado | Envia link/print |

Folga: se a instalacao estourar, o bloco "Seguranca" encolhe e vira leitura no chat.

## 5b. Bloco de injecao de prompt (dentro de "Mao na massa", ~20 min)
Ex1 pequeno (sem subagente) > Ex2 "leia o briefing-site.pdf": o texto invisivel faz o agente falar de "Tung Tung Tung Sahur" sem parar (inofensivo) > slide revela > explicacao falada: um atacante poderia pedir para ler `.env`/chaves de API > Ex3 aluno copia `defesa/AGENTS.md` e repete. **Teste real (2026-10-20):** glm-5.3, deepseek-v4.1, minimax-m3.1, mimo, big-pickle e nemotron-ultra detectaram o texto oculto e IGNORARAM (alguns avisaram o usuario); so `nemotron-3.5-lightning-free` (o menor) obedeceu e repetiu "Tung Tung Tung Sahur". Por isso o Ex2 usa o modelo pequeno e depois compara com um maior; os modelos de texto do Zen nao leem PDF, entao o Ex2 usa `briefing-site.html` (o PDF fica para Gemini/Claude). Defesas em camadas: regra no AGENTS.md (ajuda, nao garante), permissoes minimas, nada de segredos no projeto, fonte confiavel, revisao humana. **Nao verificado:** se o PDF dispara em Gemini/Zen via OpenCode (o `read` anexa o PDF ao modelo; Gemini 3 extrai o texto embutido). Testar com chave real; plano B: texto oculto mais explicito ou demo no chat do Gemini.

## 6. Plano B por falha
- Instalacao falhou: sala de ajuda em paralelo (monitor/voluntario) e continuar acompanhando pelos slides.
- Sem chave Google (regiao/conta): OpenRouter `:free` (50 req/dia sem credito) so para o exercicio pequeno; ou assistir o demo.
- Cota esgotada no meio: trocar tudo para `gemini-2.5-flash` (editar 3 linhas em `~/.config/opencode/agents/*.md`).
- Internet do professor cai: video gravado da demo (gravar no ensaio).
- Ideia a avaliar (nao verificada): GitHub Codespaces como ambiente pronto no navegador.

## 7. Checklist pre-aula (vespera)
- [ ] Instalador testado em: Windows 11 limpo, Mac, Linux, maquina sem GPU, maquina com GPU 12 GB+.
- [ ] (opcional) Tier gratis do Gemini testado com conta brasileira; anotar cota real (RPM/RPD).
- [ ] Confirmar IDs dos modelos em `config/modelos.md` (mudam rapido).
- [ ] Ensaio da hierarquia maestro > gerente > dev (item 12 da critica).
- [ ] Gravar a demo de reserva; testar compartilhamento de tela.
- [ ] Publicar release/tag do repo e fixar o instalador nela (`-Ref v1`).
- [ ] Email aos inscritos: instalar na vespera + requisitos (8 GB RAM, 5 GB livres, conta Google).

## 8. Riscos
- Limites gratis mudam sem aviso (alto). Mitigacao: teste na vespera, plano B.
- Dados enviados ao Google no tier gratis (medio). Mitigacao: aviso explicito.
- Instalador executado por desconhecidos (medio): sem chaves, backup da config, codigo curto e legivel, sem `sudo`.
- Fragilidade dos modelos pequenos em tool calls (medio): por isso local so e o padrao com >= 16 GB; testado em 8 GB (RX 7600): funciona, mas lento (~5 min/tarefa).

## 9. Diario de decisoes
- 2026-10-20: pedido recebido. Pesquisa de harnesses, tiers gratis, modelos locais e mecanica do Claude Code (`docs/pesquisa.md`).
- 2026-10-20: escolhido OpenCode (MIT, modelo por subagente, le skills). Gemini CLI descartado (fim do gratis em 2026-06-18).
- 2026-10-20: criado o repo `aula-agentes-ia` com agentes `maestro/gerente/dev`, skills `rotear-tarefa` e `ui-basico`, instaladores PS1/SH (sem manipular chaves), configs nuvem/local.
- 2026-10-20: slides em HTML unico; certificado em HTML imprimivel com nome por parametro.
- 2026-10-20: repo publicado. Instalador (modo nuvem, perfil falso) testado com OpenCode 1.19.0: config carrega, agentes `maestro/gerente/dev` reconhecidos, permissoes de `task` validas. NAO testado: chamada real a modelo, modo local, Mac/Linux.
- 2026-10-20: adicionado bloco de injecao de prompt (slides, `exercicios/`), skills adaptadas (5 proprias, 3 de terceiros com licenca; scan manual por grep, Docker/skillspector indisponivel). Pesquisa de riscos: Gemini 2.5 restrito a quem ja usava (trocado para 3.x), Pro sem plano gratis, aninhamento de subagente nao confirmado, Zen free como fallback.
- 2026-10-20: instaladores com 4 modos (claude/cloud/free/local) e copia de exercicios. Sintaxe validada; execucao dos modos claude/free/local NAO testada.
- 2026-10-20: testes reais com OpenCode 1.19.0 e Zen sem login: os 3 modelos do time respondem; maestro->gerente delega e o site e criado (gerente->dev nao confirmado; bash do gerente e recusado em `opencode run` nao interativo); MCP `chrome-devtools` conecta (precisa do Chrome instalado; sem ele o modelo cai no webfetch). Padrao de quem nao tem Claude Code passou a ser Zen free (sem retencao, sem login) em vez de Gemini. `skills-extras/` opt-in com `AULA_EXTRAS=1`. Pesquisa completa: `docs/modelos-gratis.md`.
- Pendente: ensaio real em maquinas limpas, confirmar IDs de modelo e hierarquia de 3 niveis, gravar demo.

### 2026-10-20 (testes reais)
- Instalador pergunta o provedor (Claude/Zen/Gemini/Zen+Gemini/Local); modo `both` = maestro Gemini, gerente+dev Zen. Testado: fake HOME (bash) e PowerShell; menu PowerShell com entrada simulada.
- Aninhamento maestro->gerente->dev: FALHA por padrao ("Subagent depth limit reached (1)"). Corrigido com `"subagent_depth": 2` no opencode.json; refeito: dev escreveu o arquivo.
- Local real: RX 7600 (8 GB, AMD) detectada pelo registro (nvidia-smi nao existe); `ornith-1.5:9b` baixado e rodando via derivado `aula-ornith-1.5-9b`. Contexto padrao do Ollama (4k) estoura (prompt do OpenCode ~12k tokens) -> embutido num Modelfile (`num_ctx`). Tarefa simples levou ~5 min e o modelo tentou usar o navegador sem necessidade.
- Navegacao: Chrome instalado; chrome-devtools MCP abriu example.com e leu o titulo com glm-5.3-flash-free.
- NAO testado: chave Gemini real (sem chave), Mac/Linux, tiers 12/16/24/32 GB reais (so geracao de config com ollama simulado), 429 do Zen com sala cheia.

### 2026-10-20 (instalador v2)
- Instalador reescrito em Node unico (`install.mjs`) com o fluxo aprovado: assinaturas (Claude/Codex), onde rodar (nuvem e/ou PC, ambos marcaveis), Gemini opcional com chave visivel ao digitar (validada com 1 chamada, guardada em auth.json do OpenCode), pasta de projetos, exercicios, personalizar (skills extras, web, permissoes em 3 niveis, compartilhar). Respostas por `AULA_*`.
- Novos: `instrucoes/AGENTS.md` (workflow generico com secao anti injecao de prompt), `COMO-USAR.md`, skills `ajuda-aula` e `configurar-aula`, agente `configurador`. Codex: AGENTS.md, skills em `~/.agents/skills`, subagentes `.toml`; `config.toml` nunca e alterado (so imprime as linhas). Fonte: docs oficiais do Codex (via learn.chatgpt.com).
- Testado: combinacoes por variavel (nuvem, Gemini+extras+web+balanced, nuvem+PC 32 GB, Claude+Codex+free) em HOME falso; OpenCode 1.19.0 lista os agentes e conecta o MCP; bloco idempotente; bootstrappers sh e ps1 locais. NAO testado: chave Gemini real, `codex --version`/deteccao em maquina com Codex, formato de auth.json em uso real, Mac/Linux, one-liner publicado.

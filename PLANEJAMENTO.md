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
| 12 | Hierarquia de 3 niveis (gerente chamar dev) depende do OpenCode permitir subagente chamar subagente | **A verificar no ensaio.** Fallback: o maestro chama gerente e dev diretamente |

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

| Papel | Claude Code (referencia) | Gratis nuvem | Gratis local |
|---|---|---|---|
| maestro | Opus | gemini-2.5-pro | modelo unico (qwen3-coder / gpt-oss) |
| gerente | Sonnet | gemini-2.5-flash | idem |
| dev | Haiku | gemini-2.5-flash-lite | idem |

## 4. Entregaveis (este repositorio)
- `install.ps1` / `install.sh`: detectam VRAM, escolhem nuvem ou local, instalam OpenCode (+Ollama), copiam agentes e skills com backup.
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

## 6. Plano B por falha
- Instalacao falhou: sala de ajuda em paralelo (monitor/voluntario) e continuar acompanhando pelos slides.
- Sem chave Google (regiao/conta): OpenRouter `:free` (50 req/dia sem credito) so para o exercicio pequeno; ou assistir o demo.
- Cota esgotada no meio: trocar tudo para `gemini-2.5-flash` (editar 3 linhas em `~/.config/opencode/agents/*.md`).
- Internet do professor cai: video gravado da demo (gravar no ensaio).
- Ideia a avaliar (nao verificada): GitHub Codespaces como ambiente pronto no navegador.

## 7. Checklist pre-aula (vespera)
- [ ] Instalador testado em: Windows 11 limpo, Mac, Linux, maquina sem GPU, maquina com GPU 12 GB+.
- [ ] Tier gratis do Gemini testado com conta brasileira; anotar cota real (RPM/RPD).
- [ ] Confirmar IDs dos modelos em `config/modelos.md` (mudam rapido).
- [ ] Ensaio da hierarquia maestro > gerente > dev (item 12 da critica).
- [ ] Gravar a demo de reserva; testar compartilhamento de tela.
- [ ] Publicar release/tag do repo e fixar o instalador nela (`-Ref v1`).
- [ ] Email aos inscritos: instalar na vespera + requisitos (8 GB RAM, 5 GB livres, conta Google).

## 8. Riscos
- Limites gratis mudam sem aviso (alto). Mitigacao: teste na vespera, plano B.
- Dados enviados ao Google no tier gratis (medio). Mitigacao: aviso explicito.
- Instalador executado por desconhecidos (medio): sem chaves, backup da config, codigo curto e legivel, sem `sudo`.
- Fragilidade dos modelos pequenos em tool calls (medio): por isso o limiar de 12 GB e a nuvem como padrao.

## 9. Diario de decisoes
- 2026-10-20: pedido recebido. Pesquisa de harnesses, tiers gratis, modelos locais e mecanica do Claude Code (`docs/pesquisa.md`).
- 2026-10-20: escolhido OpenCode (MIT, modelo por subagente, le skills). Gemini CLI descartado (fim do gratis em 2026-06-18).
- 2026-10-20: criado o repo `aula-agentes-ia` com agentes `maestro/gerente/dev`, skills `rotear-tarefa` e `ui-basico`, instaladores PS1/SH (sem manipular chaves), configs nuvem/local.
- 2026-10-20: slides em HTML unico; certificado em HTML imprimivel com nome por parametro.
- Pendente: ensaio real em maquinas limpas, confirmar IDs de modelo e hierarquia de 3 niveis, gravar demo.

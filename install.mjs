#!/usr/bin/env node
// Aula de agentes de IA - instalador unico (Windows, macOS, Linux). Rode via install.ps1 / install.sh ou: node install.mjs
// Perguntas sim/nao e caixas de marcar. Respostas por variavel de ambiente (AULA_*) pulam a pergunta; veja o README.
// Nunca imprime nem registra a chave do Google.
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import readline from 'node:readline';
import { execFileSync, spawnSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';

const SRC = path.dirname(fileURLToPath(import.meta.url));
const HOME = process.env.AULA_HOME || os.homedir();
const IS_WIN = process.platform === 'win32';
const IS_MAC = process.platform === 'darwin';
const TTY = !!process.stdin.isTTY && !!process.stdout.isTTY;

// ---------- MODELOS (unico lugar para trocar; veja config/modelos.md) ----------
const GEMINI = { orch: 'google/gemini-3.8-flash' };
const ZEN = { orch: 'opencode/deepseek-v4.1-flash-free', mgr: 'opencode/glm-5.3-flash-free', dev: 'opencode/minimax-m3.1-flash-free' };
// -------------------------------------------------------------------------------

const MARK = ['<!-- AULA-AGENTES:BEGIN -->', '<!-- AULA-AGENTES:END -->'];
const SAFE_BASH = ['ls', 'ls *', 'pwd', 'git status', 'git status *', 'git diff', 'git diff *', 'git log', 'git log *'];
const RISKY = ['*--output*', '*--ext-diff*', '*--no-index*', '*-c *', '*;*', '*&*', '*|*', '*>*', '*$(*', '*`*']; // vencem a lista segura (ultima regra ganha)
const EXTRAS = [
  ['scrapling-official', 'scrapling: le sites com scraping leve (so em sites que voce pode acessar)'],
  ['break-ui', 'break-ui: testa se a interface quebra com dados estranhos'],
  ['animate', 'animate: adiciona animacoes e movimento a interfaces'],
  ['diagnosing-bugs', 'diagnosing-bugs: metodo para bugs dificeis ou que voltam'],
  ['verification-loop', 'verification-loop: confere o trabalho antes de dizer "pronto"'],
];

const say = (m) => console.log(`\x1b[36m[aula]\x1b[0m ${m}`);
const warn = (m) => console.log(`\x1b[33m[aula] AVISO:\x1b[0m ${m}`);
const die = (m) => { console.error(`\x1b[31m[aula] ERRO:\x1b[0m ${m}`); process.exit(1); };
const envRaw = (n) => process.env[n];
const isYes = (s) => /^(1|y|yes|s|sim|true)$/i.test(String(s).trim());
const has = (cmd) => spawnSync(IS_WIN ? 'where' : 'which', [cmd], { stdio: 'ignore' }).status === 0;
const sh = (cmd, args, opt = {}) => spawnSync(cmd, args, { stdio: 'inherit', shell: IS_WIN, ...opt });
const rd = (p) => fs.readFileSync(p, 'utf8');
const wr = (p, s, mode) => { fs.mkdirSync(path.dirname(p), { recursive: true }); fs.writeFileSync(p, s.replace(/\r\n/g, '\n'), mode ? { mode } : undefined); };
const stamp = () => new Date().toISOString().replace(/[-:T]/g, '').slice(0, 14);
const backup = (p) => { if (fs.existsSync(p)) { const b = `${p}.bak-${stamp()}`; fs.cpSync(p, b, { recursive: true }); say(`Backup: ${b}`); } };
const copyDirs = (from, to, only) => {
  for (const d of fs.readdirSync(from)) {
    if (only && !only.includes(d)) continue;
    fs.cpSync(path.join(from, d), path.join(to, d), { recursive: true });
  }
};

// ---------- perguntas ----------
let rl, muted = false;
if (TTY) {
  rl = readline.createInterface({ input: process.stdin, output: process.stdout });
  rl._writeToOutput = (s) => { if (!muted) process.stdout.write(s); };
}
const question = (q) => new Promise((res) => rl.question(q, res));

async function yesNo(env, label, def) {
  if (envRaw(env) !== undefined) return isYes(envRaw(env));
  if (!TTY) return def;
  const a = (await question(`${label} [${def ? 'S/n' : 's/N'}] `)).trim();
  return a === '' ? def : isYes(a);
}
async function choose(env, label, options, defIdx) { // options: [valor, descricao]
  if (envRaw(env) !== undefined) return envRaw(env);
  if (!TTY) return options[defIdx][0];
  console.log(`\n${label}`);
  options.forEach(([, d], i) => console.log(`  [${i + 1}] ${d}`));
  const a = (await question(`Escolha (Enter = ${defIdx + 1}): `)).trim();
  const i = a === '' ? defIdx : Number(a) - 1;
  return (options[i] || options[defIdx])[0];
}
async function checks(env, label, options, defs) { // options: [valor, descricao]; devolve array de valores
  if (envRaw(env) !== undefined) {
    const v = envRaw(env).trim();
    if (v === 'all') return options.map((o) => o[0]);
    if (v === 'none' || v === '') return [];
    return v.split(',').map((s) => s.trim()).filter((s) => options.some((o) => o[0] === s));
  }
  if (!TTY) return defs;
  console.log(`\n${label}`);
  options.forEach(([v, d], i) => console.log(`  [${i + 1}] ${defs.includes(v) ? '[x]' : '[ ]'} ${d}`));
  const a = (await question('Numeros separados por virgula, "0" = nenhum (Enter = marcados acima): ')).trim();
  if (a === '') return defs;
  if (a === '0') return [];
  return a.split(/[ ,]+/).map((n) => options[Number(n) - 1]?.[0]).filter(Boolean);
}
async function textQ(env, prompt, def) {
  if (envRaw(env) !== undefined) return envRaw(env);
  if (!TTY) return def;
  const a = (await question(`${prompt} (Enter = ${def || 'nenhum'}): `)).trim();
  return a === '' ? def : a;
}
async function secret(env, prompt) {
  if (envRaw(env) !== undefined) return envRaw(env).trim();
  if (!TTY) return '';
  muted = true; process.stdout.write(prompt);
  const a = await question(''); muted = false; process.stdout.write('\n');
  return a.trim();
}

// ---------- hardware ----------
function vramGB() {
  if (envRaw('AULA_VRAM') !== undefined) return Number(envRaw('AULA_VRAM')) || 0;
  const run = (c, a) => { try { return execFileSync(c, a, { encoding: 'utf8', stdio: ['ignore', 'pipe', 'ignore'] }); } catch { return ''; } };
  const n = run('nvidia-smi', ['--query-gpu=memory.total', '--format=csv,noheader,nounits']).split('\n')[0].trim();
  if (n) return Math.floor(Number(n) / 1024);
  if (IS_MAC && os.arch() === 'arm64') return Math.floor((os.totalmem() / 2 ** 30) * 0.7);
  if (IS_WIN) { // WMI limita a 4 GB; o registro tem o valor real
    const ps = "Get-ItemProperty 'HKLM:\\SYSTEM\\CurrentControlSet\\Control\\Class\\{4d36e968-e325-11ce-bfc1-08002be10318}\\0*' -ErrorAction SilentlyContinue | ForEach-Object { $_.'HardwareInformation.qwMemorySize' } | Where-Object { $_ } | ForEach-Object { [math]::Floor([double]$_ / 1GB) }";
    const v = Math.max(0, ...run('powershell', ['-NoProfile', '-Command', ps]).split(/\s+/).map(Number).filter(Number.isFinite));
    if (v) return v;
  }
  if (has('rocm-smi')) {
    const m = run('rocm-smi', ['--showmeminfo', 'vram', '--json']).match(/"VRAM Total Memory \(B\)":\s*"(\d+)"/);
    if (m) return Math.floor(Number(m[1]) / 2 ** 30);
  }
  return 0;
}
// Modelos locais por VRAM (ollama.com/library; veja config/modelos.md)
function localModels(v) {
  if (v >= 32 && !IS_MAC) return { orch: 'qwen3.8:27b', mgr: 'qwen3.8:27b', dev: 'laguna-xs-2.1', size: '~35 GB' };
  const m = v >= 24 ? ['muse-glimmer:30b', '~20 GB'] : v >= 16 ? ['gpt-oss:20b', '~14 GB'] : v >= 12 ? ['gemma4:12b', '~9 GB'] : ['ornith-1.5:9b', '~6 GB'];
  return { orch: m[0], mgr: m[0], dev: m[0], size: m[1] };
}
const derived = (m) => `aula-${m.replace(/:/g, '-')}`;

// ---------- escrita de configuracao ----------
function upsertBlock(file, body) { // bloco idempotente entre marcadores; nunca apaga o resto
  let cur = fs.existsSync(file) ? rd(file) : '';
  const re = new RegExp(`${MARK[0]}[\\s\\S]*?${MARK[1]}\\n?`);
  if (cur && !re.test(cur)) backup(file);
  const block = `${MARK[0]}\n${body.trim()}\n${MARK[1]}\n`;
  cur = re.test(cur) ? cur.replace(re, () => block) : `${cur}${cur && !cur.endsWith('\n') ? '\n' : ''}${cur ? '\n' : ''}${block}`;
  wr(file, cur);
}
function permYaml(level, withEdit) {
  const edit = level === 'ask' ? 'ask' : 'allow';
  let bash;
  if (level === 'free') bash = '  bash: allow';
  else if (level === 'ask') bash = '  bash: ask';
  else bash = `  bash:\n    "*": ask\n${SAFE_BASH.map((c) => `    "${c}": allow`).concat(RISKY.map((c) => `    "${c}": ask`)).join('\n')}`;
  return withEdit ? `${bash}\n  edit: ${edit}` : bash;
}
function permJson(level) {
  if (level === 'free') return { bash: 'allow', edit: 'allow' };
  if (level === 'ask') return { bash: 'ask', edit: 'ask' };
  return { bash: { '*': 'ask', ...Object.fromEntries(SAFE_BASH.map((c) => [c, 'allow'])), ...Object.fromEntries(RISKY.map((c) => [c, 'ask'])) }, edit: 'allow' };
}
function fillAgent(txt, roles, level, file) {
  let t = txt.replace(/\r\n/g, '\n').replace(/\{\{ORCH\}\}/g, roles.orch).replace(/\{\{MGR\}\}/g, roles.mgr).replace(/\{\{DEV\}\}/g, roles.dev);
  if (file === 'configurador.md' || file === 'maestro.md') return t;
  if (/^ {2}edit: allow\n {2}bash: ask$/m.test(t)) return t.replace(/^ {2}edit: allow\n {2}bash: ask$/m, () => permYaml(level, true));
  return t.replace(/^ {2}bash: ask$/m, () => permYaml(level, false));
}

// ---------- validacao e guarda da chave ----------
async function validateGoogleKey(key) {
  try {
    const r = await fetch('https://generativelanguage.googleapis.com/v1beta/models?pageSize=1', { headers: { 'x-goog-api-key': key }, signal: AbortSignal.timeout(15000) });
    return r.ok;
  } catch { return null; } // sem rede: nao da para validar
}
function saveGoogleKey(key) {
  const f = path.join(HOME, '.local', 'share', 'opencode', 'auth.json');
  let cur = {};
  try { cur = JSON.parse(rd(f)); } catch { /* arquivo novo */ }
  backup(f);
  cur.google = { type: 'api', key };
  wr(f, JSON.stringify(cur, null, 2), 0o600);
  try { fs.chmodSync(f, 0o600); } catch { /* Windows */ }
}

// ---------- fluxo ----------
async function main() {
  console.log('\n=== Aula de agentes de IA: instalador ===\n');
  const vram = vramGB();
  say(`Memoria de video detectada: ${vram} GB (0 = nenhuma).`);

  const hasClaudeCmd = has('claude'), hasCodexCmd = has('codex');
  const subs = await checks('AULA_SUBS', 'Voce tem assinatura de alguma destas? (Claude Code e Codex sao pagos; se marcar, eles viram o motor principal)',
    [['claude', `Claude Code${hasClaudeCmd ? ' (detectado no seu PC)' : ' (nao detectado)'}`], ['codex', `Codex (OpenAI)${hasCodexCmd ? ' (detectado no seu PC)' : ' (nao detectado)'}`]],
    [hasClaudeCmd && 'claude', hasCodexCmd && 'codex'].filter(Boolean));
  const claude = envRaw('AULA_CLAUDE') !== undefined ? isYes(envRaw('AULA_CLAUDE')) : subs.includes('claude');
  const codex = envRaw('AULA_CODEX') !== undefined ? isYes(envRaw('AULA_CODEX')) : subs.includes('codex');

  const defWhere = (claude || codex) ? [] : [vram >= 16 ? 'pc' : 'cloud'];
  const lm = localModels(vram);
  const where = await checks('AULA_WHERE', `Onde quer rodar os modelos de IA? ${claude || codex ? '(opcional, voce ja tem assinatura)' : '(marque um ou os dois)'}\n  Nuvem gratis: sem baixar nada; limites de uso. No meu PC: privado e sem limite, mas baixa ${lm.size} e exige placa boa.`,
    [['cloud', 'Nuvem gratis (OpenCode Zen, sem conta)'], ['pc', `No meu PC (sua placa: ${vram} GB -> ${lm.orch}${lm.dev !== lm.orch ? ' + ' + lm.dev : ''})`]], defWhere);
  const cloud = envRaw('AULA_CLOUD') !== undefined ? isYes(envRaw('AULA_CLOUD')) : where.includes('cloud');
  const pc = envRaw('AULA_PC') !== undefined ? isYes(envRaw('AULA_PC')) : where.includes('pc');
  if (!claude && !codex && !cloud && !pc) die('Nenhum motor escolhido. Marque ao menos Claude Code, Codex, nuvem ou PC.');

  let gemini = false, geminiKey = '';
  if (cloud) {
    gemini = await yesNo('AULA_GEMINI', 'Usar o Gemini (Google) tambem? Bom: modelo mais forte no maestro. Ruim: precisa de conta Google e chave; no plano gratis o Google pode treinar com seus prompts.', false);
    if (gemini) {
      geminiKey = await secret('AULA_GEMINI_KEY', 'Cole a chave do Gemini (crie em https://aistudio.google.com/apikey; nada aparece enquanto voce digita): ');
      if (!geminiKey) { warn('Sem chave: seguindo so com Zen.'); gemini = false; }
      else {
        const ok = process.env.AULA_SKIP_VALIDATE === '1' ? true : await validateGoogleKey(geminiKey);
        if (ok === false) { warn('O Google recusou a chave. Seguindo so com Zen (rode de novo para tentar outra).'); gemini = false; geminiKey = ''; }
        else if (ok === null) warn('Sem rede para validar a chave; vou guarda-la mesmo assim.');
        else say('Chave validada.');
      }
    }
  }
  let download = false;
  if (pc) download = await yesNo('AULA_DOWNLOAD', `Baixar o modelo ${lm.orch}${lm.dev !== lm.orch ? ' e ' + lm.dev : ''} (${lm.size}) agora? Se nao, uso a nuvem Zen no lugar.`, true);
  const usePc = pc && download;

  const defGh = path.join(HOME, 'Documents', 'GitHub');
  let ghDir = '';
  if (envRaw('AULA_GITHUB_DIR') !== undefined) ghDir = envRaw('AULA_GITHUB_DIR');
  else if (await yesNo('AULA_GITHUB', 'Criar uma pasta para seus projetos (ex.: Documentos/GitHub)? Todo projeto novo fica nela, sem commit automatico.', true)) ghDir = await textQ('AULA_GITHUB_PATH', 'Caminho da pasta', defGh);
  ghDir = ghDir.replace(/^~(?=$|[\\/])/, () => HOME);

  const wantEx = await yesNo('AULA_EXERCISES', 'Copiar os exercicios da aula para o seu computador?', true);
  const custom = await yesNo('AULA_CUSTOM', 'Personalizar mais? (nao = padroes seguros: pergunta tudo, sem navegar na web, sem compartilhar)', false);
  let extras = [], web = false, perm = 'ask', share = false;
  if (custom || ['AULA_EXTRAS', 'AULA_WEB', 'AULA_PERM', 'AULA_SHARE'].some((n) => envRaw(n) !== undefined)) {
    extras = await checks('AULA_EXTRAS', 'Skills extras (marque as que quer):', EXTRAS, []);
    web = await yesNo('AULA_WEB', 'Deixar a IA navegar na web (abre o Chrome para ler sites)? Precisa do Chrome. Risco: um site pode tentar enganar a IA.', false);
    perm = await choose('AULA_PERM', 'Permissoes do terminal:', [['ask', 'Pergunta tudo (recomendado)'], ['balanced', 'Equilibrado: roda comandos seguros sozinho, pergunta os arriscados (apagar, instalar, rede)'], ['free', 'Roda tudo sem perguntar (so em pasta de teste!)']], 0);
    if (!['ask', 'balanced', 'free'].includes(perm)) perm = 'ask';
    share = await yesNo('AULA_SHARE', 'Compartilhar sessao? O OpenCode cria um link publico da conversa. Cuidado: qualquer um com o link a le.', false);
  }

  // papeis do OpenCode
  const useOpenCode = cloud || pc;
  let roles = { ...ZEN };
  if (usePc) {
    const l = { orch: `ollama/${derived(lm.orch)}`, mgr: `ollama/${derived(lm.mgr)}`, dev: `ollama/${derived(lm.dev)}` };
    roles = cloud ? { orch: gemini ? GEMINI.orch : ZEN.orch, mgr: l.mgr, dev: l.dev } : l;
  } else if (gemini) roles.orch = GEMINI.orch;

  console.log('\n--- Resumo ---');
  console.log(`Claude Code: ${claude ? 'sim' : 'nao'} | Codex: ${codex ? 'sim' : 'nao'}`);
  if (useOpenCode) console.log(`OpenCode: maestro=${roles.orch}  gerente=${roles.mgr}  dev=${roles.dev}`);
  console.log(`Pasta de projetos: ${ghDir || '(nao criar)'} | Exercicios: ${wantEx ? 'sim' : 'nao'}`);
  console.log(`Extras: ${extras.join(', ') || 'nenhum'} | Web: ${web ? 'sim' : 'nao'} | Permissoes: ${perm} | Compartilhar: ${share ? 'sim' : 'nao'}`);
  if (!(await yesNo('AULA_YES', 'Instalar?', true))) { say('Cancelado. Nada foi alterado.'); return; }

  // ---------- instalar ----------
  const projBlock = ghDir ? `## Projetos\nTodo projeto novo vai dentro de \`${ghDir}\` (crie ali a pasta do projeto). Nao faca commit nem push sozinho.` : '';
  const workflow = rd(path.join(SRC, 'instrucoes', 'AGENTS.md')).replace('{{PROJETOS}}', () => projBlock);
  if (ghDir) fs.mkdirSync(ghDir, { recursive: true });
  const copySkills = (to, bak = true) => { if (bak) backup(to); copyDirs(path.join(SRC, 'skills'), to); if (extras.length) copyDirs(path.join(SRC, 'skills-extras'), to, extras); };

  if (claude) {
    const cd = path.join(HOME, '.claude');
    for (const f of fs.readdirSync(path.join(SRC, 'agents-claude'))) {
      const d = path.join(cd, 'agents', f);
      backup(d);
      wr(d, rd(path.join(SRC, 'agents-claude', f)));
    }
    copySkills(path.join(cd, 'skills'));
    upsertBlock(path.join(cd, 'CLAUDE.md'), workflow);
    say('Claude Code configurado (agentes, skills e workflow em ~/.claude).');
    if (!hasClaudeCmd) say('Claude Code nao esta instalado: veja https://claude.com/claude-code');
  }
  if (codex) {
    const xd = process.env.CODEX_HOME || path.join(HOME, '.codex');
    upsertBlock(path.join(xd, 'AGENTS.md'), workflow);
    copySkills(path.join(HOME, '.agents', 'skills'));
    for (const f of fs.readdirSync(path.join(SRC, 'agents-claude'))) {
      const m = rd(path.join(SRC, 'agents-claude', f)).replace(/\r\n/g, '\n').match(/^---\n([\s\S]*?)\n---\n([\s\S]*)$/);
      if (!m) continue;
      const name = path.basename(f, '.md');
      const desc = (m[1].match(/^description:\s*(.*)$/m) || [null, name])[1].replace(/["\\]/g, "'");
      const dest = path.join(xd, 'agents', `${name}.toml`);
      if (fs.existsSync(dest)) { warn(`${dest} ja existe; nao sobrescrevi.`); continue; }
      wr(dest, `name = "${name}"\ndescription = "${desc}"\ndeveloper_instructions = """\n${m[2].trim().replace(/"""/g, "'''").replace(/\\/g, '\\\\')}\n"""\n`);
    }
    const sb = { ask: ['read-only', 'on-request'], balanced: ['workspace-write', 'on-request'], free: ['danger-full-access', 'never'] }[perm];
    say(`Codex configurado. Seu config.toml NAO foi alterado; para o nivel "${perm}" adicione nele:\n  sandbox_mode = "${sb[0]}"\n  approval_policy = "${sb[1]}"\n  (O Codex nao tem nivel mais restrito que read-only, nem modelo por agente igual ao OpenCode.)`);
    if (!hasCodexCmd) say('Codex nao esta instalado: npm install -g @openai/codex');
  }

  if (useOpenCode) {
    if (!has('opencode') && process.env.AULA_SKIP_INSTALL !== '1') {
      say('Instalando OpenCode...');
      if (sh('npm', ['install', '-g', 'opencode-ai']).status !== 0) die('Falhou ao instalar o OpenCode (npm install -g opencode-ai).');
    }
    if (usePc && process.env.AULA_SKIP_INSTALL !== '1') setupOllama(lm, vram);
    const dest = path.join(HOME, '.config', 'opencode');
    backup(dest);
    for (const f of fs.readdirSync(path.join(SRC, 'agents'))) wr(path.join(dest, 'agents', f), fillAgent(rd(path.join(SRC, 'agents', f)), roles, perm, f));
    copySkills(path.join(dest, 'skills'), false); // a pasta inteira ja tem backup acima
    wr(path.join(dest, 'AGENTS.md'), workflow);
    const cfg = JSON.parse(rd(path.join(SRC, 'config', usePc ? 'opencode.local.json' : 'opencode.cloud.json')).replace(/\{\{ORCH\}\}/g, roles.orch));
    if (usePc) {
      const ctx = vram >= 16 ? 65536 : 32768;
      cfg.provider.ollama.models = Object.fromEntries([...new Set([lm.orch, lm.mgr, lm.dev].map(derived))].map((n) => [n, { name: n, limit: { context: ctx, output: 8192 } }]));
    }
    cfg.permission = permJson(perm);
    cfg.share = share ? 'manual' : 'disabled';
    cfg.mcp['chrome-devtools'].enabled = web;
    wr(path.join(dest, 'opencode.json'), JSON.stringify(cfg, null, 2));
    if (geminiKey) { saveGoogleKey(geminiKey); say('Chave do Gemini guardada (arquivo privado do OpenCode).'); }
    geminiKey = '';
    smokeTest(roles.orch);
  }

  const guide = path.join(ghDir || HOME, 'COMO-USAR.md');
  wr(guide, rd(path.join(SRC, 'COMO-USAR.md')));
  if (wantEx) {
    const exDir = path.join(ghDir ? path.dirname(ghDir) : HOME, 'aula-agentes-ia-exercicios');
    fs.mkdirSync(exDir, { recursive: true });
    fs.cpSync(path.join(SRC, 'exercicios'), exDir, { recursive: true, force: false, errorOnExist: false }); // nao sobrescreve o que o aluno editou
    say(`Exercicios em: ${exDir}`);
  }
  console.log(`\nPronto! Leia o guia: ${guide}`);
  console.log('Entre numa pasta de projeto e rode: ' + [useOpenCode && 'opencode', claude && 'claude', codex && 'codex'].filter(Boolean).join('  |  '));
  console.log('Ajustes avancados: peca ao agente "use a skill configurar-aula".');
  if (TTY && process.env.AULA_NO_OPEN !== '1') {
    try { spawnSync(IS_WIN ? 'explorer.exe' : IS_MAC ? 'open' : 'xdg-open', [guide], { stdio: 'ignore' }); } catch { /* opcional */ }
  }
}

function setupOllama(lm, vram) {
  if (!has('ollama')) die('Instale o Ollama (https://ollama.com/download) e rode de novo, ou responda "nao" ao download.');
  const ctx = vram >= 16 ? 65536 : 32768; // contexto padrao do Ollama (4k) quebra agentes
  for (const m of new Set([lm.orch, lm.mgr, lm.dev])) {
    say(`Baixando ${m} (pode demorar)...`);
    if (sh('ollama', ['pull', m]).status !== 0) die(`Falhou ao baixar ${m}.`);
    const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'aula-')); // pasta privada: evita ataque por link simbolico
    const mf = path.join(dir, 'Modelfile');
    wr(mf, `FROM ${m}\nPARAMETER num_ctx ${ctx}\n`);
    sh('ollama', ['create', derived(m), '-f', mf], { stdio: 'ignore' });
    fs.rmSync(dir, { recursive: true, force: true });
  }
}
function smokeTest(model) {
  if (process.env.AULA_NO_TEST === '1' || process.env.AULA_SKIP_INSTALL === '1') return;
  say('Testando com uma chamada...');
  const r = spawnSync('opencode', ['run', '-m', model, 'Responda apenas: ok'], { encoding: 'utf8', timeout: 90000, shell: IS_WIN });
  if (r.status === 0) say('Teste ok.');
  else warn('O teste falhou (limite do provedor, rede ou modelo fora do ar). A instalacao esta feita; tente `opencode` em alguns minutos.');
}

main().catch((e) => die(e.message)).finally(() => rl?.close());

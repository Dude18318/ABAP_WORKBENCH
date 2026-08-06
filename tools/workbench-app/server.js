const http = require('http');
const fs = require('fs');
const path = require('path');
const url = require('url');
const zlib = require('zlib');

const PORT = 3000;
const ROOT_DIR = path.resolve(__dirname, '../../'); // D:\SIBUR_AI\WORKBENCH
const PUBLIC_DIR = path.join(__dirname, 'public');

// MIME types dictionary
const MIME_TYPES = {
  '.html': 'text/html; charset=UTF-8',
  '.css': 'text/css; charset=UTF-8',
  '.js': 'application/javascript; charset=UTF-8',
  '.json': 'application/json; charset=UTF-8',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.gif': 'image/gif',
  '.svg': 'image/svg+xml',
  '.ico': 'image/x-icon',
  '.md': 'text/markdown; charset=UTF-8',
  '.abap': 'text/plain; charset=UTF-8',
  '.txt': 'text/plain; charset=UTF-8'
};

// Helper: Parse Word (.docx) XML to clean text & Markdown tables
function parseDocxFile(filePath) {
  try {
    const buffer = fs.readFileSync(filePath);
    let offset = 0;
    let xmlData = '';

    while (offset < buffer.length - 30) {
      if (buffer.readUInt32LE(offset) === 0x04034b50) {
        const compression = buffer.readUInt16LE(offset + 8);
        const compSize = buffer.readUInt32LE(offset + 18);
        const fileNameLen = buffer.readUInt16LE(offset + 26);
        const extraLen = buffer.readUInt16LE(offset + 28);
        
        const fileName = buffer.toString('utf8', offset + 30, offset + 30 + fileNameLen);
        const dataOffset = offset + 30 + fileNameLen + extraLen;

        if (fileName === 'word/document.xml') {
          const compressedData = buffer.slice(dataOffset, dataOffset + compSize);
          let uncompressed = compression === 8 ? zlib.inflateRawSync(compressedData) : compressedData;
          xmlData = uncompressed.toString('utf8');
          break;
        }

        offset = dataOffset + compSize;
      } else {
        offset++;
      }
    }

    if (!xmlData) return 'Не удалось прочитать структуру .docx (word/document.xml не найден).';

    return xmlData
      .replace(/<w:tr[^>]*>/gi, '\n| ')
      .replace(/<\/w:tc>/gi, ' | ')
      .replace(/<\/w:tr>/gi, ' |\n')
      .replace(/<w:p[^>]*>/gi, '\n\n')
      .replace(/<w:br\/>/gi, '\n')
      .replace(/<w:tab\/>/gi, '\t')
      .replace(/<[^>]+>/g, '')
      .replace(/&lt;/g, '<')
      .replace(/&gt;/g, '>')
      .replace(/&amp;/g, '&')
      .replace(/&quot;/g, '"')
      .replace(/&apos;/g, "'")
      .replace(/\n{3,}/g, '\n\n')
      .trim();
  } catch (err) {
    return `Ошибка парсинга .docx файла: ${err.message}`;
  }
}

// Helper: parse JSON body
function getRequestBody(req) {
  return new Promise((resolve, reject) => {
    let body = '';
    req.on('data', chunk => { body += chunk.toString(); });
    req.on('end', () => {
      try {
        resolve(body ? JSON.parse(body) : {});
      } catch (err) {
        reject(err);
      }
    });
  });
}

// Helper: recursive file tree
function getFileTree(dirPath, relativeTo = ROOT_DIR) {
  const stats = fs.statSync(dirPath);
  const name = path.basename(dirPath);
  const relPath = path.relative(relativeTo, dirPath).replace(/\\/g, '/');

  if (stats.isDirectory()) {
    if (['.git', 'node_modules', '.gemini', 'tmp'].includes(name)) return null;

    const children = fs.readdirSync(dirPath)
      .map(child => getFileTree(path.join(dirPath, child), relativeTo))
      .filter(Boolean);

    return {
      name,
      path: relPath || '.',
      type: 'directory',
      children
    };
  } else {
    return {
      name,
      path: relPath,
      type: 'file',
      size: stats.size
    };
  }
}

// Helper: collect all markdown & doc reference files
function getAllReferences(dir, baseDir = ROOT_DIR) {
  let refs = [];
  if (!fs.existsSync(dir)) return refs;

  const items = fs.readdirSync(dir);
  for (const item of items) {
    const fullPath = path.join(dir, item);
    const stat = fs.statSync(fullPath);

    if (stat.isDirectory()) {
      refs = refs.concat(getAllReferences(fullPath, baseDir));
    } else if (item.endsWith('.md') || item.endsWith('.abap') || item.endsWith('.txt')) {
      const relPath = path.relative(baseDir, fullPath).replace(/\\/g, '/');
      const content = fs.readFileSync(fullPath, 'utf8');
      const catInfo = getCategoryInfo(relPath);
      refs.push({
        name: item,
        relPath,
        group: catInfo.group,
        category: catInfo.category,
        content
      });
    }
  }
  return refs;
}

function getCategoryInfo(relPath) {
  const norm = relPath.replace(/\\/g, '/');

  // Main Standard Rules & Documents
  if (norm.includes('AGENTS.md')) return { group: '📜 Стандарты и Регламенты СИБУР', category: '📜 Главный Регламент (AGENTS.md)' };
  if (norm.includes('architecture-patterns')) return { group: '📜 Стандарты и Регламенты СИБУР', category: '📐 Архитектура & Паттерны (MVC/DAO)' };
  if (norm.includes('optimization-rules')) return { group: '📜 Стандарты и Регламенты СИБУР', category: '⚡ Оптимизация Производительности & SQL' };
  if (norm.includes('naming-rules')) return { group: '📜 Стандарты и Регламенты СИБУР', category: '🏷️ Стандарты Наименований' };
  if (norm.includes('testing.md')) return { group: '📜 Стандарты и Регламенты СИБУР', category: '🧪 ABAP Unit Тестирование' };
  if (norm.includes('abap-rules')) return { group: '📜 Стандарты и Регламенты СИБУР', category: '📖 Общие Правила ABAP' };
  if (norm.includes('hcm-development')) return { group: '📜 Стандарты и Регламенты СИБУР', category: '💼 Справочник SAP HCM' };
  if (norm.includes('required_objects')) return { group: '📜 Стандарты и Регламенты СИБУР', category: '📋 Анализ Спецификаций' };

  // Subfolders inside "📂 Справочники Объектов (references)" Master Folder
  if (norm.includes('references/tables')) return { group: '📂 Справочники Объектов (references)', category: '📊 Таблицы' };
  if (norm.includes('references/utility_classes')) return { group: '📂 Справочники Объектов (references)', category: '🛠 Утилитарные Классы' };
  if (norm.includes('references/hcm_utility_classes')) return { group: '📂 Справочники Объектов (references)', category: '💼 HCM Утилиты' };
  if (norm.includes('references/classes')) return { group: '📂 Справочники Объектов (references)', category: '⚙️ Классы' };
  if (norm.includes('references/function_modules')) return { group: '📂 Справочники Объектов (references)', category: '🔧 Функциональные Модули' };
  if (norm.includes('references/types')) return { group: '📂 Справочники Объектов (references)', category: '📐 Типы Данных' };
  if (norm.includes('references')) return { group: '📂 Справочники Объектов (references)', category: '📁 Референсы' };

  // Boilerplate
  if (norm.includes('boilerplate')) return { group: '🚀 Каркас Разработки (Boilerplate)', category: '🚀 Архитектурный Бойлерплейт' };

  return { group: '📚 Прочая Документация', category: '📚 Документация Проекта' };
}
const BOILERPLATE_PRESETS = [
  {
    id: 'mvc_report',
    label: 'MVC Report (default)',
    description: 'Полный 11-file boilerplate для ABAP report: prog/top/s01/cd01/ci01/evt/tst и экранные include.',
    sourceDir: 'src/boilerplate',
    templateBaseUpper: 'Z_BP_REPORT',
    templateBaseLower: 'z_bp_report',
    suggestedTargetDir: 'src/z_my_new_report'
  },
  {
    id: 'salv_light_report',
    label: 'SALV Light Report',
    description: 'Облегченный read-only SALV boilerplate для быстрых списочных отчетов без dynpro и сложного UI.',
    sourceDir: 'src/boilerplate_salv_light',
    templateBaseUpper: 'Z_BP_SALV_LIGHT',
    templateBaseLower: 'z_bp_salv_light',
    suggestedTargetDir: 'src/z_my_salv_report'
  },
  {
    id: 'interactive_alv_report',
    label: 'Interactive ALV Report',
    description: 'Шаблон OO ALV с dynpro 0100, toolbar events и базовой интерактивностью для прикладных сценариев.',
    sourceDir: 'src/boilerplate_interactive_alv',
    templateBaseUpper: 'Z_BP_INTERACTIVE_ALV',
    templateBaseLower: 'z_bp_interactive_alv',
    suggestedTargetDir: 'src/z_my_interactive_alv'
  }
];

function normalizeReportName(reportName) {
  const normalized = String(reportName || '')
    .trim()
    .toUpperCase()
    .replace(/[^A-Z0-9_]/g, '_')
    .replace(/_+/g, '_');

  if (!normalized) {
    throw new Error('Имя отчета не может быть пустым.');
  }

  if (!/^[A-Z][A-Z0-9_]*$/.test(normalized)) {
    throw new Error('Имя отчета должно начинаться с буквы и содержать только A-Z, 0-9 и _.');
  }

  return normalized;
}

function getBoilerplatePreset(boilerplateId) {
  const preset = BOILERPLATE_PRESETS.find(item => item.id === boilerplateId) || BOILERPLATE_PRESETS[0];

  if (!preset) {
    throw new Error('Воркбенч не содержит настроенных boilerplate-шаблонов.');
  }

  return preset;
}

function listBoilerplatePresets() {
  return BOILERPLATE_PRESETS.map(({ id, label, description, suggestedTargetDir }) => ({
    id,
    label,
    description,
    suggestedTargetDir
  }));
}

function generateBoilerplateFiles(reportName, targetDir, boilerplateId) {
  const preset = getBoilerplatePreset(boilerplateId);
  const normalizedReportName = normalizeReportName(reportName);
  const boilerplateDir = path.join(ROOT_DIR, preset.sourceDir);
  const normalizedTargetDir = String(targetDir || '').trim().replace(/\\/g, '/').replace(/^\/+/, '');

  if (!normalizedTargetDir) {
    throw new Error('Целевая папка не может быть пустой.');
  }

  const targetRoot = path.resolve(ROOT_DIR, normalizedTargetDir);
  if (!targetRoot.startsWith(ROOT_DIR)) {
    throw new Error('Целевая папка должна находиться внутри репозитория.');
  }

  const sourceFiles = fs.readdirSync(boilerplateDir)
    .filter(item => item.endsWith('.abap'));

  const reportBaseLower = normalizedReportName.toLowerCase();
  const createdFiles = [];
  const skippedFiles = [];

  fs.mkdirSync(targetRoot, { recursive: true });

  for (const sourceFile of sourceFiles) {
    const sourcePath = path.join(boilerplateDir, sourceFile);
    const targetFileName = sourceFile.replace(new RegExp(preset.templateBaseLower, 'gi'), reportBaseLower);
    const targetPath = path.join(targetRoot, targetFileName);

    if (fs.existsSync(targetPath)) {
      skippedFiles.push(path.relative(ROOT_DIR, targetPath).replace(/\\/g, '/'));
      continue;
    }

    const templateContent = fs.readFileSync(sourcePath, 'utf8');
    const renderedContent = templateContent
      .replace(new RegExp(preset.templateBaseUpper, 'g'), normalizedReportName)
      .replace(new RegExp(preset.templateBaseLower, 'g'), reportBaseLower);

    fs.writeFileSync(targetPath, renderedContent, 'utf8');
    createdFiles.push(path.relative(ROOT_DIR, targetPath).replace(/\\/g, '/'));
  }

  return {
    boilerplateId: preset.id,
    boilerplateLabel: preset.label,
    reportName: normalizedReportName,
    targetDir: path.relative(ROOT_DIR, targetRoot).replace(/\\/g, '/'),
    createdFiles,
    skippedFiles
  };
}

// Create HTTP Server
const server = http.createServer(async (req, res) => {
  const parsedUrl = url.parse(req.url, true);
  const pathname = parsedUrl.pathname;

  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') {
    res.writeHead(200);
    res.end();
    return;
  }

  try {
    // 1. GET /api/tree
    if (pathname === '/api/tree' && req.method === 'GET') {
      const tree = getFileTree(ROOT_DIR);
      res.writeHead(200, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify(tree));
      return;
    }

    // 2. GET /api/file
    if (pathname === '/api/file' && req.method === 'GET') {
      const filePath = parsedUrl.query.path;
      if (!filePath) {
        res.writeHead(400, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ error: 'Missing path' }));
        return;
      }

      const fullPath = path.resolve(ROOT_DIR, filePath);
      if (!fullPath.startsWith(ROOT_DIR)) {
        res.writeHead(403, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ error: 'Access denied' }));
        return;
      }

      if (!fs.existsSync(fullPath) || fs.statSync(fullPath).isDirectory()) {
        res.writeHead(404, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ error: 'File not found' }));
        return;
      }

      if (fullPath.endsWith('.docx')) {
        const content = parseDocxFile(fullPath);
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ path: filePath, content, isDocx: true }));
        return;
      }

      const content = fs.readFileSync(fullPath, 'utf8');
      res.writeHead(200, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ path: filePath, content }));
      return;
    }

    // 3. POST /api/file
    if (pathname === '/api/file' && req.method === 'POST') {
      const body = await getRequestBody(req);
      if (!body.path || body.content === undefined) {
        res.writeHead(400, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ error: 'Missing path or content' }));
        return;
      }

      const fullPath = path.resolve(ROOT_DIR, body.path);
      if (!fullPath.startsWith(ROOT_DIR)) {
        res.writeHead(403, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ error: 'Access denied' }));
        return;
      }

      fs.mkdirSync(path.dirname(fullPath), { recursive: true });
      fs.writeFileSync(fullPath, body.content, 'utf8');

      res.writeHead(200, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ success: true, path: body.path }));
      return;
    }

    // 4. GET /api/references - ALL project reference docs & guides
    if (pathname === '/api/references' && req.method === 'GET') {
      const agentContextDir = path.join(ROOT_DIR, 'docs', 'agent-context');
      let refs = getAllReferences(agentContextDir);

      // Add AGENTS.md
      const agentsMd = path.join(ROOT_DIR, '.agents', 'AGENTS.md');
      if (fs.existsSync(agentsMd)) {
        refs.unshift({
          name: 'AGENTS.md',
          relPath: '.agents/AGENTS.md',
          category: '📜 Главный Регламент (AGENTS.md)',
          content: fs.readFileSync(agentsMd, 'utf8')
        });
      }

      // Add src/boilerplate files to Knowledge Base
      const bpDir = path.join(ROOT_DIR, 'src', 'boilerplate');
      let bpRefs = getAllReferences(bpDir);
      bpRefs.forEach(ref => {
        ref.category = '🚀 Архитектурный Бойлерплейт (src/boilerplate)';
      });
      refs = refs.concat(bpRefs);

      res.writeHead(200, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ references: refs }));
      return;
    }

    // 5. GET /api/boilerplates
    if (pathname === '/api/boilerplates' && req.method === 'GET') {
      res.writeHead(200, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ presets: listBoilerplatePresets() }));
      return;
    }

    // 6. POST /api/generate-boilerplate
    if (pathname === '/api/generate-boilerplate' && req.method === 'POST') {
      const body = await getRequestBody(req);

      try {
        const result = generateBoilerplateFiles(body.reportName, body.targetDir, body.boilerplateId);
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ success: true, ...result }));
      } catch (err) {
        res.writeHead(400, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ success: false, error: err.message }));
      }
      return;
    }

    // 7. POST /api/lint - ABAP Linter by SIBUR Rules
    if (pathname === '/api/lint' && req.method === 'POST') {
      const body = await getRequestBody(req);
      const code = body.code || '';
      const issues = lintAbapCode(code);
      res.writeHead(200, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ issues }));
      return;
    }

    // 8. POST /api/obfuscate - ABAP Code Obfuscation
    if (pathname === '/api/obfuscate' && req.method === 'POST') {
      const body = await getRequestBody(req);
      const code = body.code || '';
      const result = obfuscateAbapCode(code, body.options || {});
      res.writeHead(200, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify(result));
      return;
    }

    // --- STATIC FILES SERVING ---
    let reqPath = pathname === '/' ? '/index.html' : pathname;
    let safePath = path.normalize(reqPath).replace(/^(\.\.[\/\\])+/, '');
    let staticFilePath = path.join(PUBLIC_DIR, safePath);

    if (fs.existsSync(staticFilePath) && !fs.statSync(staticFilePath).isDirectory()) {
      const ext = path.extname(staticFilePath).toLowerCase();
      const contentType = MIME_TYPES[ext] || 'application/octet-stream';
      const fileContent = fs.readFileSync(staticFilePath);
      res.writeHead(200, { 'Content-Type': contentType });
      res.end(fileContent);
      return;
    }

    res.writeHead(404, { 'Content-Type': 'text/plain' });
    res.end('404 Not Found');

  } catch (err) {
    console.error('Server error:', err);
    res.writeHead(500, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ error: err.message }));
  }
});

server.listen(PORT, () => {
  console.log(`====================================================`);
  console.log(` SIBUR AI ABAP Workbench App is running OFFLINE!`);
  console.log(` URL: http://localhost:${PORT}`);
  console.log(`====================================================`);
});

// --- ABAP LINTER ENGINE ---
function lintAbapCode(code) {
  const lines = code.split('\n');
  const issues = [];
  let inLoop = false;
  let loopStartLine = 0;

  for (let i = 0; i < lines.length; i++) {
    const lineNum = i + 1;
    const line = lines[i];
    const trimmed = line.trim();

    if (trimmed.startsWith('*') || trimmed.startsWith('"')) continue;

    // Loop detection
    if (/^\s*(LOOP\s+AT|DO\b|WHILE\b)/i.test(line)) {
      inLoop = true;
      loopStartLine = lineNum;
    }
    if (/^\s*(ENDLOOP|ENDDO|ENDWHILE)\b/i.test(line)) {
      inLoop = false;
    }

    // 1. SELECT inside LOOP
    if (inLoop && /\bSELECT\b/i.test(line) && !/ENDSELECT/i.test(line)) {
      issues.push({
        line: lineNum,
        type: 'error',
        rule: 'SELECT_IN_LOOP',
        message: `Запрещено выполнять SELECT внутри цикла (цикл на стр. ${loopStartLine}). Соберите ключи и используйте FOR ALL ENTRIES за пределами цикла (AGENTS.md #3.1)`,
        codeSnippet: trimmed
      });
    }

    // 2. SELECT * warning
    if (/\bSELECT\s+\*\b/i.test(line)) {
      issues.push({
        line: lineNum,
        type: 'warning',
        rule: 'SELECT_ALL',
        message: `Избегайте 'SELECT *'. Указывайте только необходимые поля (AGENTS.md #3.1)`,
        codeSnippet: trimmed
      });
    }

    // 3. FOR ALL ENTRIES checks
    if (/FOR\s+ALL\s+ENTRIES\s+IN\s+([\w_]+)/i.test(line)) {
      const match = line.match(/FOR\s+ALL\s+ENTRIES\s+IN\s+([\w_]+)/i);
      const itabName = match ? match[1] : 'таблицы';
      
      let hasNotInitial = false;
      for (let j = Math.max(0, i - 15); j < i; j++) {
        if (new RegExp(`${itabName}\\s+IS\\s+NOT\\s+INITIAL`, 'i').test(lines[j])) {
          hasNotInitial = true;
          break;
        }
      }

      if (!hasNotInitial) {
        issues.push({
          line: lineNum,
          type: 'error',
          rule: 'FAE_NOT_INITIAL',
          message: `Перед запросом с FOR ALL ENTRIES IN ${itabName} обязательна проверка 'IF ${itabName} IS NOT INITIAL' (AGENTS.md #3.1)`,
          codeSnippet: trimmed
        });
      }

      if (/\bOR\b/i.test(line)) {
        issues.push({
          line: lineNum,
          type: 'error',
          rule: 'FAE_OR_CONDITION',
          message: `Запрещено использовать 'OR' в условиях FOR ALL ENTRIES — это критически снижает скорость выборки (AGENTS.md #3.1)`,
          codeSnippet: trimmed
        });
      }
    }

    // 4. Method name length > 30 chars
    const methodMatch = line.match(/\bMETHOD[S]?\s+([\w_]+)/i);
    if (methodMatch && methodMatch[1].length > 30) {
      issues.push({
        line: lineNum,
        type: 'error',
        rule: 'METHOD_NAME_LENGTH',
        message: `Имя метода '${methodMatch[1]}' (${methodMatch[1].length} символов) превышает технический лимит ABAP в 30 символов (AGENTS.md #2.2)`,
        codeSnippet: trimmed
      });
    }

    // 5. LOOP INTO wa warning
    if (/\bLOOP\s+AT\s+[\w_]+\s+INTO\s+[\w_]+/i.test(line) && !/ASSIGNING/i.test(line)) {
      issues.push({
        line: lineNum,
        type: 'warning',
        rule: 'LOOP_INTO_WA',
        message: `Рекомендуется использовать 'ASSIGNING <fs>' вместо 'INTO wa' для ускорения работы с памятью (AGENTS.md #3.2)`,
        codeSnippet: trimmed
      });
    }

    // 6. BINARY SEARCH without SORT check
    if (/\bBINARY\s+SEARCH\b/i.test(line)) {
      let hasSort = false;
      for (let j = Math.max(0, i - 25); j < i; j++) {
        if (/\bSORT\b/i.test(lines[j])) {
          hasSort = true;
          break;
        }
      }
      if (!hasSort) {
        issues.push({
          line: lineNum,
          type: 'warning',
          rule: 'BINARY_SEARCH_SORT',
          message: `Использование BINARY SEARCH без предшествующей сортировки SORT запрещено (AGENTS.md #3.2)`,
          codeSnippet: trimmed
        });
      }
    }

    // 7. READ_TEXT inside LOOP
    if (inLoop && /\bCALL\s+FUNCTION\s+['']READ_TEXT['']/i.test(line)) {
      issues.push({
        line: lineNum,
        type: 'error',
        rule: 'READ_TEXT_IN_LOOP',
        message: `Избегайте вызова 'READ_TEXT' в цикле. Используйте утилитарный класс ZCL_READ_MULTIPLE_TEXTS (AGENTS.md #3.1)`,
        codeSnippet: trimmed
      });
    }

    // 8. STATUS_TEXT_EDIT inside LOOP
    if (inLoop && /\bCALL\s+FUNCTION\s+['']STATUS_TEXT_EDIT['']/i.test(line)) {
      issues.push({
        line: lineNum,
        type: 'warning',
        rule: 'STATUS_TEXT_EDIT_IN_LOOP',
        message: `Избегайте вызова STATUS_TEXT_EDIT в цикле. Используйте STATUS_READ_MULTI или маску статусов (AGENTS.md #3.1)`,
        codeSnippet: trimmed
      });
    }

    // 9. DELETE in LOOP
    if (inLoop && /^\s*DELETE\s+[\w_]+\s+WHERE\b/i.test(line)) {
      issues.push({
        line: lineNum,
        type: 'warning',
        rule: 'DELETE_IN_LOOP',
        message: `Не удаляйте строки в цикле LOOP по одной через DELETE ... WHERE. Пометьте записи флагом и удалите одной массовой операцией (AGENTS.md #3.2)`,
        codeSnippet: trimmed
      });
    }

    // 10. INTO CORRESPONDING FIELDS OF TABLE
    if (/\bINTO\s+CORRESPONDING\s+FIELDS\s+OF\s+TABLE\b/i.test(line)) {
      issues.push({
        line: lineNum,
        type: 'warning',
        rule: 'INTO_CORRESPONDING',
        message: `Порядок полей в SELECT должен соответствовать внутренней таблице (быстрее на 15–20%, чем INTO CORRESPONDING FIELDS) (AGENTS.md #3.1)`,
        codeSnippet: trimmed
      });
    }
  }

  return issues;
}

// --- ABAP OBFUSCATOR ENGINE ---
function obfuscateAbapCode(code, options = {}) {
  const removeComments = options.removeComments !== false;
  const replaceVars = options.replaceVars !== false;

  let lines = code.split('\n');
  let linesRemoved = 0;

  if (removeComments) {
    const cleanedLines = [];
    for (let line of lines) {
      const trimmed = line.trim();
      if (trimmed.startsWith('*')) {
        linesRemoved++;
        continue;
      }
      let result = '';
      let inString = false;
      for (let i = 0; i < line.length; i++) {
        const char = line[i];
        if (char === "'") inString = !inString;
        if (char === '"' && !inString) {
          linesRemoved++;
          break;
        }
        result += char;
      }
      if (result.trim() || line.trim() === '') {
        cleanedLines.push(result);
      }
    }
    lines = cleanedLines;
  }

  let resultText = lines.join('\n');

  if (replaceVars) {
    const varMap = new Map();
    let vCounter = 1;
    let tCounter = 1;
    let sCounter = 1;
    let fsCounter = 1;

    const varRegex = /\b(lv_[a_zA-Z0-9_]+|lt_[a_zA-Z0-9_]+|ls_[a_zA-Z0-9_]+|<fs_[a_zA-Z0-9_]+>)\b/g;
    let match;
    while ((match = varRegex.exec(resultText)) !== null) {
      const varName = match[1];
      if (!varMap.has(varName)) {
        let anon = varName;
        if (varName.startsWith('lv_')) anon = `lv_v${vCounter++}`;
        else if (varName.startsWith('lt_')) anon = `lt_t${tCounter++}`;
        else if (varName.startsWith('ls_')) anon = `ls_s${sCounter++}`;
        else if (varName.startsWith('<fs_')) anon = `<fs_f${fsCounter++}>`;

        varMap.set(varName, anon);
      }
    }

    for (const [original, anon] of varMap.entries()) {
      const escaped = original.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
      const reg = new RegExp(`\\b${escaped}\\b`, 'g');
      resultText = resultText.replace(reg, anon);
    }
  }

  return {
    obfuscatedCode: resultText,
    stats: {
      linesRemoved,
      varsAnonymized: replaceVars ? 1 : 0
    }
  };
}





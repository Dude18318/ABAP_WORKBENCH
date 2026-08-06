// ============================================================================
// SIBUR AI ABAP WORKBENCH - NAVIGATION HUB FRONTEND
// ============================================================================

document.addEventListener('DOMContentLoaded', () => {
  let activeFilePath = null;
  let allReferences = [];
  let currentFontSize = 14;
  let lastLintIssues = [];

  const body = document.body;
  const tabButtons = document.querySelectorAll('.tab-btn');
  const tabPanes = document.querySelectorAll('.tab-pane');
  const sidebar = document.getElementById('sidebar');
  const sidebarToggleIcon = document.getElementById('sidebar-toggle-icon');
  const fileEditor = document.getElementById('file-editor');
  const fileHighlightView = document.getElementById('file-highlight-view');
  const currentFilePathBadge = document.getElementById('current-file-path');
  const specEditor = document.getElementById('spec-editor');
  const specDocTitle = document.getElementById('spec-doc-title');
  const specDocPath = document.getElementById('spec-doc-path');
  const specDocKind = document.getElementById('spec-doc-kind');
  const specDocDescription = document.getElementById('spec-doc-description');
  const specDocGuidance = document.getElementById('spec-doc-guidance');
  const specList = document.getElementById('spec-list');
  const specRelatedActions = document.getElementById('spec-related-actions');
  const lintPanel = document.getElementById('lint-results-panel');
  const lintList = document.getElementById('lint-issues-list');
  const refSearchInput = document.getElementById('ref-search-input');

  // --- THEME ---
  const themeToggleBtn = document.getElementById('theme-toggle-btn');
  const savedTheme = localStorage.getItem('sibur-theme');

  function applyTheme(theme) {
    const isDark = theme === 'dark';
    body.classList.toggle('light-theme', isDark);
    themeToggleBtn.textContent = isDark ? '☀️' : '🌙';
    localStorage.setItem('sibur-theme', theme);
  }

  applyTheme(savedTheme || 'warm');
  themeToggleBtn.addEventListener('click', () => {
    const nextTheme = body.classList.contains('light-theme') ? 'warm' : 'dark';
    applyTheme(nextTheme);
  });

  // --- FONT SIZE ---
  const fontDecreaseBtn = document.getElementById('font-decrease-btn');
  const fontIncreaseBtn = document.getElementById('font-increase-btn');
  const fontSizeDisplay = document.getElementById('font-size-display');

  function setFontSize(size) {
    currentFontSize = Math.min(24, Math.max(10, size));
    document.documentElement.style.setProperty('--editor-font-size', `${currentFontSize}px`);
    fontSizeDisplay.textContent = `${currentFontSize}px`;
    localStorage.setItem('sibur-font-size', String(currentFontSize));
  }

  const savedFontSize = parseInt(localStorage.getItem('sibur-font-size') || '', 10);
  if (!Number.isNaN(savedFontSize)) {
    setFontSize(savedFontSize);
  } else {
    setFontSize(currentFontSize);
  }

  fontDecreaseBtn.addEventListener('click', () => setFontSize(currentFontSize - 1));
  fontIncreaseBtn.addEventListener('click', () => setFontSize(currentFontSize + 1));

  // --- SIDEBAR ---
  function toggleSidebar() {
    sidebar.classList.toggle('collapsed');
    const isCollapsed = sidebar.classList.contains('collapsed');
    if (sidebarToggleIcon) {
      sidebarToggleIcon.textContent = isCollapsed ? '▶' : '◀';
    }
  }

  document.getElementById('main-sidebar-toggle-btn')?.addEventListener('click', toggleSidebar);
  document.getElementById('toggle-sidebar-btn')?.addEventListener('click', toggleSidebar);

  document.addEventListener('keydown', (event) => {
    if ((event.ctrlKey || event.metaKey) && event.key.toLowerCase() === 'b') {
      event.preventDefault();
      toggleSidebar();
    }
  });

  // --- TABS ---
  function activateTab(targetTab) {
    tabButtons.forEach((button) => {
      button.classList.toggle('active', button.dataset.tab === targetTab);
    });
    tabPanes.forEach((pane) => {
      pane.classList.toggle('active', pane.id === targetTab);
    });

    if (targetTab === 'tab-knowledge' && allReferences.length === 0) {
      loadAllReferences();
    }
  }

  tabButtons.forEach((button) => {
    button.addEventListener('click', () => activateTab(button.dataset.tab));
  });

  document.querySelectorAll('[data-jump-tab]').forEach((button) => {
    button.addEventListener('click', () => activateTab(button.dataset.jumpTab));
  });

  document.querySelectorAll('[data-open-file]').forEach((button) => {
    button.addEventListener('click', () => openFile(button.dataset.openFile));
  });

  // --- PROJECT TREE ---
  async function loadProjectTree() {
    try {
      const response = await fetch('/api/tree');
      const tree = await response.json();
      const treeContainer = document.getElementById('project-tree');
      treeContainer.innerHTML = '';

      if (tree && tree.children) {
        const stats = collectTreeStats(tree.children);
        const filesCountBadge = document.getElementById('sidebar-files-count');
        const docsCountBadge = document.getElementById('sidebar-docs-count');
        if (filesCountBadge) filesCountBadge.textContent = stats.files;
        if (docsCountBadge) docsCountBadge.textContent = stats.docs;

        treeContainer.appendChild(renderTreeNodes(tree.children, 0));
      }
    } catch (error) {
      document.getElementById('project-tree').innerHTML = '<div class="loading-state">Не удалось загрузить дерево проекта.</div>';
    }
  }

  function collectTreeStats(nodes) {
    return nodes.reduce((acc, node) => {
      if (node.type === 'directory') {
        const nested = collectTreeStats(node.children || []);
        acc.files += nested.files;
        acc.docs += nested.docs;
      } else {
        acc.files += 1;
        if (/\.(md|txt|docx|abap)$/i.test(node.name)) {
          acc.docs += 1;
        }
      }
      return acc;
    }, { files: 0, docs: 0 });
  }

  function renderTreeNodes(nodes, level = 0) {
    const container = document.createElement('div');

    nodes.forEach((node) => {
      if (node.type === 'directory') {
        const folderHeader = document.createElement('div');
        folderHeader.className = 'tree-item folder-item';

        const isExpanded = level === 0;
        const chevron = isExpanded ? '▼' : '▶';
        const folderIcon = isExpanded ? '📂' : '📁';

        folderHeader.innerHTML = `
          <span class="tree-chevron">${chevron}</span>
          <span class="folder-icon">${folderIcon}</span>
          <strong>${escapeHtml(node.name)}</strong>
        `;

        const childrenElement = document.createElement('div');
        childrenElement.className = 'tree-children';
        childrenElement.style.display = isExpanded ? 'block' : 'none';

        if (node.children && node.children.length > 0) {
          childrenElement.appendChild(renderTreeNodes(node.children, level + 1));
        }

        folderHeader.addEventListener('click', (event) => {
          event.stopPropagation();
          const hidden = childrenElement.style.display === 'none';
          childrenElement.style.display = hidden ? 'block' : 'none';
          folderHeader.querySelector('.tree-chevron').textContent = hidden ? '▼' : '▶';
          folderHeader.querySelector('.folder-icon').textContent = hidden ? '📂' : '📁';
        });

        container.appendChild(folderHeader);
        container.appendChild(childrenElement);
      } else {
        const itemElement = document.createElement('div');
        itemElement.className = 'tree-item';
        itemElement.innerHTML = `<span style="width: 12px; display: inline-block;"></span>${getFileIcon(node.name)} <span>${escapeHtml(node.name)}</span>`;

        itemElement.addEventListener('click', (event) => {
          event.stopPropagation();
          document.querySelectorAll('.tree-item').forEach((element) => element.classList.remove('active'));
          itemElement.classList.add('active');
          openFile(node.path);
        });

        container.appendChild(itemElement);
      }
    });

    return container;
  }

  function getFileIcon(filename) {
    if (filename.endsWith('.abap')) return '⚡';
    if (filename.endsWith('.md')) return '📝';
    if (filename.endsWith('.docx')) return '📘';
    if (filename.endsWith('.txt')) return '📄';
    return '📄';
  }

  // --- FILE OPEN/SAVE ---
  async function openFile(filePath) {
    try {
      const response = await fetch(`/api/file?path=${encodeURIComponent(filePath)}`);
      const data = await response.json();

      if (data.content === undefined) {
        return;
      }

      const isSpecLike = filePath.endsWith('.docx') || filePath.endsWith('plan.md') || filePath.includes('spec_analysis');
      const isAbapFile = filePath.endsWith('.abap') || filePath.endsWith('.prog.abap') || filePath.includes('.abap');

      if (isSpecLike) {
        specEditor.value = data.content;
        activateTab('tab-specs');
        return;
      }

      activeFilePath = filePath;
      currentFilePathBadge.textContent = filePath;
      fileEditor.value = data.content;

      const modeSwitchGroup = document.getElementById('mode-switch-group');
      const lintBtn = document.getElementById('lint-abap-btn');
      if (modeSwitchGroup) {
        modeSwitchGroup.style.display = isAbapFile ? 'flex' : 'none';
      }
      if (lintBtn) {
        lintBtn.style.display = isAbapFile ? 'inline-flex' : 'none';
      }
      if (!isAbapFile) {
        lintPanel.style.display = 'none';
        document.getElementById('mode-edit-btn')?.click();
      } else if (document.getElementById('mode-highlight-btn')?.classList.contains('active')) {
        fileHighlightView.innerHTML = highlightAbap(data.content);
      }

      activateTab('tab-workspace');
    } catch (error) {
      console.error('Failed to open file:', error);
    }
  }

  document.getElementById('save-file-btn')?.addEventListener('click', async () => {
    if (!activeFilePath) {
      alert('Сначала откройте файл для сохранения.');
      return;
    }

    try {
      const response = await fetch('/api/file', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ path: activeFilePath, content: fileEditor.value })
      });
      const result = await response.json();
      if (result.success) {
        alert(`Файл ${activeFilePath} сохранен.`);
      } else {
        alert(`Ошибка при сохранении: ${result.error || 'неизвестная ошибка'}`);
      }
    } catch (error) {
      alert('Ошибка соединения при сохранении файла.');
    }
  });

  // --- SPECS ---
  const specWorkspaceEntries = [
    {
      id: 'spec_workspace_guide',
      title: 'Как подготовить новую задачу',
      path: 'Spec and result/README.md',
      kind: 'Guide',
      description: 'Правила размещения ТЗ и рабочих артефактов в отдельной папке задачи.',
      guidance: [
        'Создайте папку с идентификатором задачи.',
        'Положите в неё исходное ТЗ.',
        'Скопируйте шаблоны анализа, сигнатур и результата.'
      ],
      relatedPaths: [
        'plan.md',
        'docs/agent-context/required_objects/spec_analysis.md',
        'docs/agent-context/required_objects/missing_signatures.md'
      ]
    },
    {
      id: 'plan_template',
      title: 'Шаблон плана задачи',
      path: 'plan.md',
      kind: 'Template',
      description: 'Нейтральный план, который следует скопировать в папку конкретной задачи.',
      guidance: [
        'Укажите цель и границы задачи.',
        'Зафиксируйте этапы анализа, согласования, реализации и проверки.'
      ],
      relatedPaths: [
        'Spec and result/README.md',
        'docs/agent-context/required_objects/spec_analysis.md'
      ]
    },
    {
      id: 'spec_analysis_template',
      title: 'Шаблон анализа спецификации',
      path: 'docs/agent-context/required_objects/spec_analysis.md',
      kind: 'Template',
      description: 'Шаблон для фиксации требований, вопросов, допущений и финальной сверки.',
      guidance: [
        'Скопируйте файл в папку новой задачи.',
        'Заполняйте его до реализации по ТЗ.'
      ],
      relatedPaths: [
        'Spec and result/README.md',
        'docs/agent-context/required_objects/missing_signatures.md'
      ]
    },
    {
      id: 'missing_signatures_template',
      title: 'Шаблон недостающих сигнатур',
      path: 'docs/agent-context/required_objects/missing_signatures.md',
      kind: 'Template',
      description: 'Очередь объектов, описание которых требуется выгрузить из SAP.',
      guidance: [
        'Скопируйте файл в папку новой задачи.',
        'После выгрузки добавьте сигнатуры в references и обновите статус.'
      ],
      relatedPaths: [
        'Spec and result/README.md',
        'docs/agent-context/playbooks/unknown-z-objects.md'
      ]
    }
  ];

  function findSpecEntryByPath(filePath) {
    return specWorkspaceEntries.find((entry) => entry.path === filePath) || null;
  }

  function renderSpecWorkspaceList() {
    if (!specList) return;
    specList.innerHTML = '';

    specWorkspaceEntries.forEach((entry) => {
      const button = document.createElement('button');
      button.type = 'button';
      button.className = 'quick-link-card spec-list-item';
      button.dataset.specId = entry.id;
      button.innerHTML = `<span class="quick-link-kicker">${escapeHtml(entry.kind)}</span><strong>${escapeHtml(entry.title)}</strong><span>${escapeHtml(entry.description)}</span>`;
      button.addEventListener('click', () => openSpecEntry(entry));
      specList.appendChild(button);
    });
  }

  function renderSpecGuidance(guidance) {
    if (!specDocGuidance) return;
    specDocGuidance.innerHTML = '';
    guidance.forEach((item) => {
      const li = document.createElement('li');
      li.textContent = item;
      specDocGuidance.appendChild(li);
    });
  }

  function renderSpecRelatedActions(entry) {
    if (!specRelatedActions) return;
    specRelatedActions.innerHTML = '';

    entry.relatedPaths.forEach((filePath) => {
      const relatedEntry = findSpecEntryByPath(filePath);
      const button = document.createElement('button');
      button.type = 'button';
      button.className = 'btn btn-secondary btn-small';
      button.textContent = relatedEntry ? relatedEntry.title : filePath.split('/').pop();
      button.addEventListener('click', () => {
        if (relatedEntry) {
          openSpecEntry(relatedEntry);
        } else {
          openFile(filePath);
        }
      });
      specRelatedActions.appendChild(button);
    });
  }

  async function openSpecEntry(entry, prefetchedContent = null) {
    try {
      const contentForView = prefetchedContent !== null
        ? prefetchedContent
        : await fetch(`/api/file?path=${encodeURIComponent(entry.path)}`)
            .then((response) => response.json())
            .then((data) => data.content || '');

      document.querySelectorAll('.spec-list-item').forEach((item) => item.classList.remove('active'));
      const activeButton = document.querySelector(`.spec-list-item[data-spec-id="${entry.id}"]`);
      if (activeButton) {
        activeButton.classList.add('active');
      }

      if (specDocTitle) specDocTitle.textContent = entry.title;
      if (specDocPath) specDocPath.textContent = entry.path;
      if (specDocKind) specDocKind.textContent = entry.kind;
      if (specDocDescription) specDocDescription.textContent = entry.description;
      renderSpecGuidance(entry.guidance);
      renderSpecRelatedActions(entry);
      if (specEditor) specEditor.value = contentForView;
      activateTab('tab-specs');
    } catch (error) {
      alert('Не удалось открыть документ spec workspace.');
    }
  }

  renderSpecWorkspaceList();
  const defaultSpecEntry = findSpecEntryByPath('Spec and result/README.md');
  if (defaultSpecEntry) {
    openSpecEntry(defaultSpecEntry);
  }

  // --- GENERATOR ---
  document.getElementById('generate-boilerplate-btn')?.addEventListener('click', async () => {
    const reportName = document.getElementById('gen-report-name').value.trim();
    const targetDir = document.getElementById('gen-target-dir').value.trim();
    const selectedPreset = getSelectedBoilerplatePreset();

    if (!reportName || !targetDir) {
      alert('Заполните имя отчета и целевую папку.');
      return;
    }

    if (!selectedPreset) {
      alert('Не найден ни один boilerplate-шаблон.');
      return;
    }

    try {
      const response = await fetch('/api/generate-boilerplate', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ reportName, targetDir, boilerplateId: selectedPreset.id })
      });
      const result = await response.json();

      if (!response.ok || !result.success) {
        alert(`Не удалось сгенерировать каркас: ${result.error || 'неизвестная ошибка'}`);
        return;
      }

      await loadProjectTree();
      renderBoilerplateResult(result);

      const createdCount = result.createdFiles ? result.createdFiles.length : 0;
      const skippedCount = result.skippedFiles ? result.skippedFiles.length : 0;
      let message = `Каркас ${result.reportName} по шаблону ${result.boilerplateLabel} подготовлен в ${result.targetDir}. Создано файлов: ${createdCount}.`;
      if (skippedCount > 0) {
        message += ` Уже существовало файлов: ${skippedCount}.`;
      }
      alert(message);

      if (createdCount > 0) {
        openFile(result.createdFiles[0]);
      }
    } catch (error) {
      alert('Ошибка соединения при генерации каркаса.');
    }
  });

  // --- REFERENCES ---
  async function loadAllReferences() {
    try {
      const response = await fetch('/api/references');
      const data = await response.json();
      allReferences = data.references || [];
      renderReferencesList('');
    } catch (error) {
      document.getElementById('all-references-list').innerHTML = '<div class="loading-state">Не удалось загрузить референсы.</div>';
    }
  }

  function renderReferencesList(filterQuery = '') {
    const listContainer = document.getElementById('all-references-list');
    listContainer.innerHTML = '';

    const filtered = allReferences.filter((ref) => {
      if (!filterQuery) return true;
      return ref.name.toLowerCase().includes(filterQuery)
        || ref.relPath.toLowerCase().includes(filterQuery)
        || (ref.content && ref.content.toLowerCase().includes(filterQuery));
    });

    if (filtered.length === 0) {
      listContainer.innerHTML = `<div class="loading-state">Ничего не найдено по запросу "${escapeHtml(filterQuery)}".</div>`;
      return;
    }

    const groups = {};
    filtered.forEach((ref) => {
      const groupName = ref.group || '📚 Прочая документация';
      const categoryName = ref.category || '📁 Общие референсы';
      groups[groupName] = groups[groupName] || {};
      groups[groupName][categoryName] = groups[groupName][categoryName] || [];
      groups[groupName][categoryName].push(ref);
    });

    let firstRendered = false;

    Object.entries(groups).forEach(([groupName, categories]) => {
      const groupHeader = document.createElement('div');
      groupHeader.className = 'ref-group-header';
      groupHeader.innerHTML = `<span>${escapeHtml(groupName)}</span><span class="ref-group-chevron">▼</span>`;

      const groupContainer = document.createElement('div');
      groupContainer.className = 'ref-subfolder-container';
      groupContainer.style.display = 'block';

      groupHeader.addEventListener('click', () => {
        const hidden = groupContainer.style.display === 'none';
        groupContainer.style.display = hidden ? 'block' : 'none';
        groupHeader.querySelector('.ref-group-chevron').textContent = hidden ? '▼' : '▶';
      });

      Object.entries(categories).forEach(([categoryName, items]) => {
        const subHeader = document.createElement('div');
        subHeader.className = 'ref-subfolder-header';
        subHeader.innerHTML = `<span>${escapeHtml(categoryName)} (${items.length})</span><span class="ref-sub-chevron">▼</span>`;

        const subItemsContainer = document.createElement('div');
        subItemsContainer.className = 'ref-subfolder-items';
        subItemsContainer.style.display = 'block';

        subHeader.addEventListener('click', () => {
          const hidden = subItemsContainer.style.display === 'none';
          subItemsContainer.style.display = hidden ? 'block' : 'none';
          subHeader.querySelector('.ref-sub-chevron').textContent = hidden ? '▼' : '▶';
        });

        items.forEach((item) => {
          const itemElement = document.createElement('div');
          itemElement.className = 'table-list-item';
          itemElement.innerHTML = `📄 <span>${escapeHtml(item.name)}</span>`;

          if (!firstRendered) {
            itemElement.classList.add('active');
            displayReference(item);
            firstRendered = true;
          }

          itemElement.addEventListener('click', () => {
            document.querySelectorAll('.table-list-item').forEach((element) => element.classList.remove('active'));
            itemElement.classList.add('active');
            displayReference(item);
          });

          subItemsContainer.appendChild(itemElement);
        });

        groupContainer.appendChild(subHeader);
        groupContainer.appendChild(subItemsContainer);
      });

      listContainer.appendChild(groupHeader);
      listContainer.appendChild(groupContainer);
    });
  }

  refSearchInput?.addEventListener('input', (event) => {
    renderReferencesList(event.target.value.toLowerCase().trim());
  });
  // --- BOILERPLATE PRESETS & RESULT PANEL ---
  const boilerplateSelect = document.getElementById('boilerplate-select');
  const boilerplatePicker = document.getElementById('boilerplate-picker');
  const boilerplateTrigger = document.getElementById('boilerplate-trigger');
  const boilerplateTriggerLabel = document.getElementById('boilerplate-trigger-label');
  const boilerplateMenu = document.getElementById('boilerplate-menu');
  const boilerplateDescription = document.getElementById('boilerplate-description');
  const targetDirInput = document.getElementById('gen-target-dir');
  const resultPanel = document.getElementById('boilerplate-result-panel');
  const resultTitle = document.getElementById('boilerplate-result-title');
  const resultMeta = document.getElementById('boilerplate-result-meta');
  const createdList = document.getElementById('boilerplate-created-list');
  const skippedList = document.getElementById('boilerplate-skipped-list');

  async function loadBoilerplatePresets() {
    try {
      const response = await fetch('/api/boilerplates');
      const data = await response.json();
      boilerplatePresets = data.presets || [];
      renderBoilerplatePresets();
    } catch (error) {
      if (boilerplateDescription) {
        boilerplateDescription.textContent = 'Не удалось загрузить шаблоны boilerplate.';
      }
    }
  }

  function renderBoilerplatePresets() {
    if (!boilerplateSelect) return;

    boilerplateSelect.innerHTML = '';
    if (boilerplateMenu) {
      boilerplateMenu.innerHTML = '';
    }

    if (!boilerplatePresets.length) {
      boilerplateSelect.disabled = true;
      if (boilerplateTrigger) {
        boilerplateTrigger.disabled = true;
      }
      const option = document.createElement('option');
      option.textContent = '������� �� �������';
      boilerplateSelect.appendChild(option);
      if (boilerplateTriggerLabel) {
        boilerplateTriggerLabel.textContent = '������� �� �������';
      }
      if (boilerplateDescription) {
        boilerplateDescription.textContent = '�������� ���� �� �������� ��������� boilerplate-��������.';
      }
      closeBoilerplateMenu();
      return;
    }

    boilerplatePresets.forEach((preset, index) => {
      const option = document.createElement('option');
      option.value = preset.id;
      option.textContent = preset.label;
      option.selected = index === 0;
      boilerplateSelect.appendChild(option);

      if (boilerplateMenu) {
        const item = document.createElement('button');
        item.type = 'button';
        item.className = 'boilerplate-option';
        item.dataset.presetId = preset.id;
        item.innerHTML =           '<span class="boilerplate-option-label">' + escapeHtml(preset.label) + '</span>' +
          '<span class="boilerplate-option-meta">' + escapeHtml(preset.description || '') + '</span>';
        item.addEventListener('click', () => {
          boilerplateSelect.value = preset.id;
          syncBoilerplatePresetUI();
          closeBoilerplateMenu();
        });
        boilerplateMenu.appendChild(item);
      }
    });

    boilerplateSelect.disabled = boilerplatePresets.length <= 1;
    if (boilerplateTrigger) {
      boilerplateTrigger.disabled = boilerplatePresets.length === 0;
    }
    syncBoilerplatePresetUI();
  }

  function getSelectedBoilerplatePreset() {
    if (!boilerplatePresets.length) return null;
    return boilerplatePresets.find((preset) => preset.id === boilerplateSelect.value) || boilerplatePresets[0];
  }

  function syncBoilerplatePresetUI() {
    const preset = getSelectedBoilerplatePreset();
    if (!preset) return;

    if (boilerplateTriggerLabel) {
      boilerplateTriggerLabel.textContent = preset.label;
    }

    if (boilerplateMenu) {
      boilerplateMenu.querySelectorAll('.boilerplate-option').forEach((item) => {
        item.classList.toggle('active', item.dataset.presetId === preset.id);
      });
    }

    if (boilerplateDescription) {
      const modeHint = boilerplatePresets.length <= 1
        ? '������ �������� ���� ������, ������� ������������ �������� ����������.'
        :           '�������� ��������: ' + boilerplatePresets.length + '.';
      boilerplateDescription.textContent = preset.description + ' ' + modeHint;
    }

    if (targetDirInput && (!targetDirInput.value.trim() || targetDirInput.dataset.autofill !== 'manual')) {
      targetDirInput.value = preset.suggestedTargetDir || targetDirInput.value;
      targetDirInput.dataset.autofill = 'preset';
    }
  }

  function openBoilerplateMenu() {
    if (!boilerplatePicker || !boilerplateTrigger || boilerplateSelect?.disabled) return;
    boilerplatePicker.classList.add('open');
    boilerplateTrigger.setAttribute('aria-expanded', 'true');
  }

  function closeBoilerplateMenu() {
    if (!boilerplatePicker || !boilerplateTrigger) return;
    boilerplatePicker.classList.remove('open');
    boilerplateTrigger.setAttribute('aria-expanded', 'false');
  }

  function toggleBoilerplateMenu() {
    if (!boilerplatePicker) return;
    if (boilerplatePicker.classList.contains('open')) {
      closeBoilerplateMenu();
    } else {
      openBoilerplateMenu();
    }
  }

  function renderResultFileList(container, files, emptyText) {
    if (!container) return;
    container.innerHTML = '';

    if (!files || files.length === 0) {
      const empty = document.createElement('div');
      empty.className = 'result-empty';
      empty.textContent = emptyText;
      container.appendChild(empty);
      return;
    }

    files.forEach((filePath) => {
      const button = document.createElement('button');
      button.type = 'button';
      button.className = 'result-file-button';
      button.textContent = filePath;
      button.addEventListener('click', () => openFile(filePath));
      container.appendChild(button);
    });
  }

  function renderBoilerplateResult(result) {
    lastBoilerplateResult = result;
    if (!resultPanel) return;

    resultPanel.style.display = 'block';
    resultTitle.textContent = `Результат генерации: ${result.reportName}`;
    resultMeta.textContent = `${result.boilerplateLabel} -> ${result.targetDir}`;
    renderResultFileList(createdList, result.createdFiles, 'Новых файлов не создано.');
    renderResultFileList(skippedList, result.skippedFiles, 'Пропущенных файлов нет.');
  }

  boilerplateSelect?.addEventListener('change', syncBoilerplatePresetUI);
  boilerplateTrigger?.addEventListener('click', () => {
    toggleBoilerplateMenu();
  });
  document.addEventListener('click', (event) => {
    if (!boilerplatePicker || boilerplatePicker.contains(event.target)) return;
    closeBoilerplateMenu();
  });
  document.addEventListener('keydown', (event) => {
    if (event.key === 'Escape') {
      closeBoilerplateMenu();
    }
  });
  targetDirInput?.addEventListener('input', () => {
    targetDirInput.dataset.autofill = 'manual';
  });

  function displayReference(ref) {
    document.getElementById('knowledge-item-title').textContent = ref.name;
    document.getElementById('knowledge-path-badge').textContent = ref.relPath;
    document.getElementById('knowledge-markdown-render').innerHTML = renderMarkdown(ref.content);
  }

  function renderMarkdown(markdown) {
    if (!markdown) return '';

    if (markdown.includes('REPORT ') || markdown.includes('CLASS ') || markdown.includes('ENDCLASS')) {
      return `<div class="abap-code-view">${highlightAbap(markdown)}</div>`;
    }

    const lines = markdown.split('\n');
    let html = '';
    let inTable = false;
    let tableHeaderDone = false;

    for (let i = 0; i < lines.length; i += 1) {
      const line = lines[i].trim();

      if (line.startsWith('|') && line.endsWith('|')) {
        if (line.includes('---')) {
          tableHeaderDone = true;
          continue;
        }
        const cells = line.split('|').slice(1, -1).map((cell) => cell.trim());
        if (!inTable) {
          inTable = true;
          tableHeaderDone = false;
          html += '<table><thead><tr>' + cells.map((cell) => `<th>${formatInlineMarkdown(cell)}</th>`).join('') + '</tr></thead><tbody>';
        } else if (!tableHeaderDone) {
          html += '<tr>' + cells.map((cell) => `<th>${formatInlineMarkdown(cell)}</th>`).join('') + '</tr>';
          tableHeaderDone = true;
        } else {
          html += '<tr>' + cells.map((cell) => `<td>${formatInlineMarkdown(cell)}</td>`).join('') + '</tr>';
        }
        continue;
      }

      if (inTable) {
        inTable = false;
        html += '</tbody></table>';
      }

      if (line.startsWith('# ')) {
        html += `<h1>${formatInlineMarkdown(line.slice(2))}</h1>`;
      } else if (line.startsWith('## ')) {
        html += `<h2>${formatInlineMarkdown(line.slice(3))}</h2>`;
      } else if (line.startsWith('### ')) {
        html += `<h3>${formatInlineMarkdown(line.slice(4))}</h3>`;
      } else if (line.startsWith('* ') || line.startsWith('- ')) {
        html += `<p style="padding-left: 16px;">• ${formatInlineMarkdown(line.slice(2))}</p>`;
      } else if (line === '') {
        html += '<br>';
      } else {
        html += `<p>${formatInlineMarkdown(line)}</p>`;
      }
    }

    if (inTable) {
      html += '</tbody></table>';
    }

    return html;
  }

  function formatInlineMarkdown(text) {
    return escapeHtml(text)
      .replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>')
      .replace(/`(.*?)`/g, '<code>$1</code>');
  }

  // --- ABAP HIGHLIGHT ---
  const abapKeywords = new Set([
    'REPORT', 'PROGRAM', 'CLASS', 'ENDCLASS', 'INTERFACE', 'ENDINTERFACE',
    'METHOD', 'ENDMETHOD', 'MODULE', 'ENDMODULE', 'FORM', 'ENDFORM', 'FUNCTION',
    'PUBLIC', 'PROTECTED', 'PRIVATE', 'SECTION', 'FINAL', 'ABSTRACT', 'INHERITING',
    'FROM', 'DEFINITION', 'IMPLEMENTATION', 'METHODS', 'CLASS-METHODS', 'EVENTS',
    'TYPES', 'DATA', 'FIELD-SYMBOLS', 'CONSTANTS', 'STATICS', 'TABLES', 'PARAMETERS',
    'SELECT-OPTIONS', 'SELECTION-SCREEN', 'INITIALIZATION', 'START-OF-SELECTION',
    'END-OF-SELECTION', 'AT', 'TOP-OF-PAGE', 'END-OF-PAGE',
    'SELECT', 'SINGLE', 'COUNT', 'INTO', 'CORRESPONDING', 'FIELDS', 'OF', 'TABLE',
    'WHERE', 'AND', 'OR', 'NOT', 'LIKE', 'IN', 'IS', 'INITIAL', 'BOUND', 'NULL',
    'UP', 'TO', 'ROWS', 'ORDER', 'BY', 'GROUP', 'HAVING', 'JOIN', 'ON', 'INNER',
    'LEFT', 'OUTER', 'FOR', 'ALL', 'ENTRIES', 'APPEND', 'INSERT', 'MODIFY', 'DELETE',
    'READ', 'WITH', 'KEY', 'BINARY', 'SEARCH', 'SORT', 'CLEAR', 'REFRESH', 'FREE',
    'LOOP', 'ENDLOOP', 'WHILE', 'ENDWHILE', 'DO', 'ENDDO', 'CHECK', 'EXIT', 'CONTINUE',
    'RETURN', 'IF', 'ELSEIF', 'ELSE', 'ENDIF', 'CASE', 'WHEN', 'OTHERS', 'ENDCASE',
    'TRY', 'CATCH', 'ENDTRY', 'RAISE', 'EXCEPTION', 'MESSAGE', 'VALUE', 'COND',
    'SWITCH', 'NEW', 'REF', 'LINE_EXISTS', 'OPTIONAL', 'DEFAULT', 'BASE', 'ASSIGN',
    'ASSIGNING', 'UNASSIGN', 'CALL', 'PERFORM', 'SUBMIT', 'LEAVE', 'SCREEN',
    'COMMIT', 'WORK', 'ROLLBACK', 'TYPE', 'STRUCTURE', 'BEGIN', 'END'
  ]);

  function highlightAbap(code) {
    if (!code) return '';
    const lines = code.split('\n');

    return lines.map((line, index) => {
      const trimmed = line.trim();
      let highlightedLine = '';

      if (trimmed.startsWith('*')) {
        highlightedLine = `<span class="abap-comment">${escapeHtml(line)}</span>`;
      } else {
        const tokens = [];
        let currentToken = '';
        let inString = false;
        let stringChar = '';
        let inComment = false;

        for (let i = 0; i < line.length; i += 1) {
          const char = line[i];

          if (inComment) {
            currentToken += char;
            continue;
          }

          if (inString) {
            currentToken += char;
            if (char === stringChar) {
              inString = false;
              tokens.push({ type: 'string', text: currentToken });
              currentToken = '';
            }
            continue;
          }

          if (char === '\'' || char === '`') {
            if (currentToken) {
              tokens.push({ type: 'text', text: currentToken });
              currentToken = '';
            }
            inString = true;
            stringChar = char;
            currentToken = char;
            continue;
          }

          if (char === '"') {
            if (currentToken) {
              tokens.push({ type: 'text', text: currentToken });
              currentToken = '';
            }
            inComment = true;
            currentToken = char;
            continue;
          }

          currentToken += char;
        }

        if (currentToken) {
          tokens.push({ type: inComment ? 'comment' : inString ? 'string' : 'text', text: currentToken });
        }

        highlightedLine = tokens.map((token) => {
          if (token.type === 'comment') return `<span class="abap-comment">${escapeHtml(token.text)}</span>`;
          if (token.type === 'string') return `<span class="abap-string">${escapeHtml(token.text)}</span>`;

          return token.text.replace(/([@<>\w_\-]+)/g, (match) => {
            const upper = match.toUpperCase();
            if (abapKeywords.has(upper)) return `<span class="abap-kw">${escapeHtml(match)}</span>`;
            if (match.startsWith('@')) return `<span class="abap-hostvar">${escapeHtml(match)}</span>`;
            if (match.startsWith('<') && match.endsWith('>')) return `<span class="abap-fs">${escapeHtml(match)}</span>`;
            if (/^\d+$/.test(match)) return `<span class="abap-num">${escapeHtml(match)}</span>`;
            return escapeHtml(match);
          });
        }).join('');
      }

      return `<div class="code-line"><span class="line-num">${index + 1}</span><span class="line-code">${highlightedLine}</span></div>`;
    }).join('');
  }

  // --- EDIT/HIGHLIGHT MODE ---
  const modeEditBtn = document.getElementById('mode-edit-btn');
  const modeHighlightBtn = document.getElementById('mode-highlight-btn');

  modeEditBtn?.addEventListener('click', () => {
    modeEditBtn.classList.add('active');
    modeHighlightBtn.classList.remove('active');
    fileEditor.style.display = 'block';
    fileHighlightView.style.display = 'none';
  });

  modeHighlightBtn?.addEventListener('click', () => {
    modeHighlightBtn.classList.add('active');
    modeEditBtn.classList.remove('active');
    fileHighlightView.innerHTML = highlightAbap(fileEditor.value);
    fileEditor.style.display = 'none';
    fileHighlightView.style.display = 'block';
  });

  // --- LINTER ---
  document.getElementById('close-lint-panel-btn')?.addEventListener('click', () => {
    lintPanel.style.display = 'none';
  });

  document.getElementById('export-agent-prompt-btn')?.addEventListener('click', () => {
    if (!lastLintIssues.length) {
      alert('Замечаний нет или проверка еще не выполнялась.');
      return;
    }

    let promptText = `Пожалуйста, исправь замечания SIBUR ABAP Linter в файле ${activeFilePath || 'ABAP-программы'}:\n\n### Замечания по коду (.agents/AGENTS.md):\n`;
    lastLintIssues.forEach((issue, index) => {
      const badge = issue.type === 'error' ? 'ОШИБКА' : 'ПРЕДУПРЕЖДЕНИЕ';
      promptText += `${index + 1}. [Стр. ${issue.line}] ${badge}: ${issue.message}\n   Код: \`${issue.codeSnippet}\`\n`;
    });
    promptText += '\nИсправь данные нарушения в соответствии со стандартами СИБУР.';

    navigator.clipboard.writeText(promptText)
      .then(() => alert('Текст замечаний скопирован в буфер обмена.'))
      .catch(() => window.prompt('Скопируйте текст ниже для отправки агенту:', promptText));
  });

  document.getElementById('lint-abap-btn')?.addEventListener('click', async () => {
    const code = fileEditor.value;
    if (!code.trim()) {
      alert('Откройте ABAP-код для проверки.');
      return;
    }

    try {
      const response = await fetch('/api/lint', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ code })
      });
      const data = await response.json();
      const issues = data.issues || [];
      lastLintIssues = issues;
      lintList.innerHTML = '';
      lintPanel.style.display = 'block';

      if (!issues.length) {
        lintList.innerHTML = '<div style="color: #0f9f6f; padding: 10px; background: rgba(15,159,111,0.12); border-radius: 12px;">Замечаний по правилам СИБУР не обнаружено.</div>';
        return;
      }

      issues.forEach((issue) => {
        const item = document.createElement('div');
        const isError = issue.type === 'error';
        const color = isError ? '#dc2626' : '#d97706';
        const background = isError ? 'rgba(220, 38, 38, 0.1)' : 'rgba(217, 119, 6, 0.1)';
        const badge = isError ? 'ОШИБКА' : 'ПРЕДУПРЕЖДЕНИЕ';

        item.style.cssText = `padding: 10px; background: ${background}; border-left: 3px solid ${color}; border-radius: 12px;`;
        item.innerHTML = `
          <div><span style="font-weight: 800; color: ${color};">[Стр. ${issue.line}] ${badge}:</span> ${escapeHtml(issue.message)}</div>
          <div style="font-family: var(--font-mono); color: var(--text-muted); font-size: 11px; margin-top: 4px;">Код: ${escapeHtml(issue.codeSnippet)}</div>
        `;
        lintList.appendChild(item);
      });
    } catch (error) {
      alert('Ошибка при выполнении проверки линтером.');
    }
  });

  // --- OBFUSCATOR ---
  document.getElementById('run-obfuscator-btn')?.addEventListener('click', async () => {
    const code = document.getElementById('obf-input').value;
    const removeComments = document.getElementById('obf-remove-comments').checked;
    const replaceVars = document.getElementById('obf-replace-vars').checked;

    if (!code.trim()) {
      alert('Вставьте ABAP-код для обфускации.');
      return;
    }

    try {
      const response = await fetch('/api/obfuscate', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          code,
          options: { removeComments, replaceVars }
        })
      });
      const data = await response.json();
      document.getElementById('obf-output').value = data.obfuscatedCode || '';
      document.getElementById('obf-stats-badge').textContent = data.stats
        ? `Удалено строк/комментариев: ${data.stats.linesRemoved}`
        : '';
    } catch (error) {
      alert('Ошибка при обфускации кода.');
    }
  });

  // --- TOUR ---
  const tourSteps = [
    {
      target: '#open-workflow-guide-btn',
      title: '1. Начните с агента',
      desc: 'Главный путь работы — ТЗ в папке «Spec and result», промпт агенту и контекст репозитория. Откройте «Как работать», чтобы получить готовые промпты и порядок действий.',
      tab: 'tab-overview'
    },
    {
      target: '#project-tree',
      title: '2. Навигатор репозитория',
      desc: 'Здесь быстро открываются ТЗ, исходники, регламенты и результаты анализа. Интерфейс помогает работать с файлами, но не заменяет агента или SAP-инструменты.',
      tab: 'tab-overview'
    },
    {
      target: '#tab-workspace',
      title: '3. Рабочая область',
      desc: 'Просматривайте и точечно редактируйте файлы. Для ABAP доступны подсветка и SIBUR Linter; реальные активация, ATC/SLIN и ABAP Unit выполняются в SAP.',
      tab: 'tab-workspace'
    },
    {
      target: '#tab-specs',
      title: '4. Контур ТЗ и сигнатур',
      desc: 'Здесь связаны исходное ТЗ, spec_analysis.md и missing_signatures.md. После анализа последний файл становится очередью того, что нужно выгрузить из SAP и добавить в references.',
      tab: 'tab-specs'
    },
    {
      target: '#tab-knowledge',
      title: '5. База знаний',
      desc: 'Здесь агент и разработчик находят корпоративные правила, playbooks, описания таблиц, классов и готовые утилиты для безопасной реализации.',
      tab: 'tab-knowledge'
    },
    {
      target: '#tab-tools',
      title: '6. Инструменты',
      desc: 'Создавайте каркас нового отчёта и обезличивайте фрагменты для обсуждения с AI. Линтер запускается из рабочей области. После тура откройте «Как работать» и начните анализ ТЗ.',
      tab: 'tab-tools'
    }
  ];

  let currentTourStep = 0;
  const startTourBtn = document.getElementById('start-tour-btn');
  const tourBackdrop = document.getElementById('tour-backdrop');
  const tourTooltip = document.getElementById('tour-tooltip');
  const tourStepBadge = document.getElementById('tour-step-badge');
  const tourTitle = document.getElementById('tour-title');
  const tourDesc = document.getElementById('tour-desc');
  const tourPrevBtn = document.getElementById('tour-prev-btn');
  const tourNextBtn = document.getElementById('tour-next-btn');
  const tourCloseBtn = document.getElementById('tour-close-btn');

  function renderTourStep(stepIndex) {
    if (stepIndex < 0 || stepIndex >= tourSteps.length) {
      closeTour();
      return;
    }

    const step = tourSteps[stepIndex];
    activateTab(step.tab);

    requestAnimationFrame(() => {
      const target = document.querySelector(step.target);
      if (!target) return;

      const rect = target.getBoundingClientRect();
      tourStepBadge.textContent = `Шаг ${stepIndex + 1} из ${tourSteps.length}`;
      tourTitle.textContent = step.title;
      tourDesc.textContent = step.desc;
      tourPrevBtn.disabled = stepIndex === 0;
      tourNextBtn.textContent = stepIndex === tourSteps.length - 1 ? 'Завершить' : 'Далее';

      const top = Math.min(window.innerHeight - 220, Math.max(20, rect.top + 20));
      const left = Math.min(window.innerWidth - 380, Math.max(20, rect.right - 280));
      tourTooltip.style.top = `${top}px`;
      tourTooltip.style.left = `${left}px`;
    });
  }

  function openTour() {
    currentTourStep = 0;
    tourBackdrop.style.display = 'block';
    tourTooltip.style.display = 'block';
    renderTourStep(currentTourStep);
  }

  function closeTour() {
    tourBackdrop.style.display = 'none';
    tourTooltip.style.display = 'none';
  }

  startTourBtn?.addEventListener('click', openTour);
  tourCloseBtn?.addEventListener('click', closeTour);
  tourBackdrop?.addEventListener('click', closeTour);
  tourPrevBtn?.addEventListener('click', () => {
    currentTourStep -= 1;
    renderTourStep(currentTourStep);
  });
  tourNextBtn?.addEventListener('click', () => {
    currentTourStep += 1;
    renderTourStep(currentTourStep);
  });


  // --- WORKFLOW GUIDE ---
  const workflowGuideSeenKey = 'sibur-workflow-guide-seen-v1';
  const workflowGuideModal = document.getElementById('workflow-guide-modal');
  const workflowGuideBackdrop = document.getElementById('workflow-guide-backdrop');
  const openWorkflowGuideBtn = document.getElementById('open-workflow-guide-btn');
  const closeWorkflowGuideBtn = document.getElementById('close-workflow-guide-btn');

  function openWorkflowGuide() {
    if (!workflowGuideModal || !workflowGuideBackdrop) return;
    workflowGuideBackdrop.style.display = 'block';
    workflowGuideModal.style.display = 'block';
    document.body.classList.add('workflow-guide-open');
    localStorage.setItem(workflowGuideSeenKey, 'true');
    closeWorkflowGuideBtn?.focus();
  }

  function closeWorkflowGuide() {
    if (!workflowGuideModal || !workflowGuideBackdrop) return;
    workflowGuideBackdrop.style.display = 'none';
    workflowGuideModal.style.display = 'none';
    document.body.classList.remove('workflow-guide-open');
  }

  openWorkflowGuideBtn?.addEventListener('click', openWorkflowGuide);
  closeWorkflowGuideBtn?.addEventListener('click', closeWorkflowGuide);
  workflowGuideBackdrop?.addEventListener('click', closeWorkflowGuide);
  document.addEventListener('keydown', (event) => {
    if (event.key === 'Escape' && workflowGuideModal?.style.display === 'block') closeWorkflowGuide();
  });
  document.querySelectorAll('[data-copy-prompt]').forEach((button) => {
    button.addEventListener('click', () => {
      const promptId = button.dataset.copyPrompt === 'analysis' ? 'workflow-analysis-prompt' : 'workflow-implementation-prompt';
      const promptText = document.getElementById(promptId)?.textContent.trim() || '';
      navigator.clipboard.writeText(promptText)
        .then(() => {
          const originalText = button.textContent;
          button.textContent = 'Скопировано';
          setTimeout(() => { button.textContent = originalText; }, 1600);
        })
        .catch(() => window.prompt('Скопируйте промпт:', promptText));
    });
  });
  // --- HELPERS ---
  function escapeHtml(text) {
    return String(text)
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;');
  }

  // --- INITIAL LOAD ---
  loadProjectTree();
  loadBoilerplatePresets();
  if (!localStorage.getItem(workflowGuideSeenKey)) openWorkflowGuide();
});


















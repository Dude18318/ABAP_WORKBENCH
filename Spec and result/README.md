# Спецификации и результаты задач

Для каждой новой задачи создайте отдельную папку:

```text
Spec and result/<ID_задачи>/
  specification.docx
  spec_analysis.md
  missing_signatures.md
  result.md
```

1. Поместите исходное ТЗ в папку задачи.
2. Дайте AI-агенту промпт анализа из окна «Как работать».
3. Агент заполнит `spec_analysis.md` и `missing_signatures.md` в папке задачи.
4. Выгрузите требуемые сигнатуры из SAP в `docs/agent-context/references/`.
5. После реализации сохраните результат и сведения о проверках в `result.md`.

Шаблоны рабочих файлов находятся в `docs/agent-context/required_objects/`.
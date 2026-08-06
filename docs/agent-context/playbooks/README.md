# Playbooks для AI-агента

Эта папка содержит короткие маршруты работы для типовых задач. Общий регламент остается в `.agents/AGENTS.md`, а playbooks помогают агенту подключать только релевантный контекст.

## Как выбирать playbook

| Ситуация | Playbook |
| --- | --- |
| Точечная правка существующего ABAP-кода | [legacy-change.md](legacy-change.md) |
| Новый полноценный ABAP-отчет | [greenfield-report.md](greenfield-report.md) |
| Работа по ТЗ/ФС/ТС | [spec-driven.md](spec-driven.md) |
| Неизвестный `Z_*` объект или неполная сигнатура | [unknown-z-objects.md](unknown-z-objects.md) |

Если подходят несколько playbooks, применяйте их в порядке: `spec-driven` -> `unknown-z-objects` -> `legacy-change` или `greenfield-report`.

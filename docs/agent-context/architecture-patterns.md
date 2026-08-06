# Архитектурные Паттерны Репозитория

Используй эти паттерны при изменении или добавлении ABAP report code в этом репозитории.

## Include-Структура

Сохраняй классическую структуру отчета:

- `*.prog.abap`: только report shell и список include.
- `*_top`: глобальные DDIC-based типы, константы и данные.
- `*_s01`: объявления selection screen.
- `*_cd*`: definitions классов и интерфейсов.
- `*_ci*`: implementations классов.
- `*_f01`: procedural helper FORMs, если их требуют legacy SAP APIs.
- `*_evt`: event blocks с делегированием в application class.
- `*_o01`/`*_i01`: PBO/PAI modules с делегированием в методы.
- `*_tst` или `*_ut01`: ABAP Unit tests.

## Главный Application Class

Паттерн из `zsd_3965_lp` и `report_ethalon2/zpm_pdm_log`:

- ABAP events и PBO/PAI modules должны быть тонкими и сразу делегировать работу.
- App/main class владеет use case flow:
  - читает состояние selection screen;
  - валидирует или нормализует параметры;
  - вызывает DAO для внешних данных;
  - строит ALV/application tables;
  - создает view;
  - добавляет сообщения в `zcl_logger`.
- Не помещай прямые UI-вызовы в parsing/filtering logic.

Текущие примеры:

- `lcl_app` в `zsd_3965_lp_cd01/ci01`
- `lcl_main` в `report_ethalon2/zpm_pdm_log_d01/i01`

## Параметры Selection Screen

Предпочтительный паттерн:

1. Использовать `cl_reca_ranges=>analyse_selection_screen`.
2. Переносить только нужные `selpar` values в типизированную структуру состояния экрана.
3. Делать `CONDENSE` и нормализацию при переносе.
4. Хранить состояние в одной application structure, а не размазывать по глобальным screen fields.
5. ЧТобы он работал рядом с остальными инклюдами надо подключать инклюду if_reca_ranges

Примеры:

- `zsd_3965_lp`: `lcl_app->analyze_sel_screen` и `get_selscreen_parameters`.
- `report_ethalon2`: `lcl_main->get_screen_parametrs` и маппинг в `ms_screen_fields` в constructor.

Если параметр влияет на видимость полей, держи эту логику в отдельном методе, например `show_hide_fields`.

## DAO Class

DAO classes являются границей для того, что трудно unit-тестировать:

- `SELECT` statements;
- SAP function modules;
- file conversion function modules;
- `AUTHORITY-CHECK`;
- `CALL SCREEN` и `CALL TRANSACTION`;
- прямое чтение BAL function modules;
- persistence/update task function modules;
- внешние custom helpers, например `zcl_3978_log`.

Основная логика должна вызывать именованные DAO methods, а не встраивать эти зависимости напрямую.

Примеры:

- В `zsd_3965_lp` есть `lif_dao` и `lcl_dao`; тесты заменяют DAO через `lcl_dao_mock`.
- В `report_ethalon2` методы `select_balhdr`, `select_viqmel_by_qmnum`, `load_log_messages`, `check_auth_*`, `call_screen_0100`, `call_iw23` находятся в `lcl_dao`.

Когда добавляешь зависимость, сначала реши, не должна ли она жить за DAO interface.

## File Reader / Parser

Для отчетов загрузки файлов:

- Raw file conversion держи за DAO (`get_converted_file_data` в `zsd_3965_lp`).
- Row mapping и validation держи в parser/file-reader class.
- Номера колонок из selection screen храни в typed parameter structure.
- Возвращай valid rows плюс `bapiret2_t` validation messages.
- До row loop делай bulk preload, например material existence и plant mapping.

Текущий пример: `lcl_filereader` в `zsd_3965_lp`.

## View И ALV

View classes отвечают за ALV setup, layout, column texts, buttons и event handlers.

- `lcl_view` должен получать уже подготовленные display data.
- Custom functions добавляй в одном setup method.
- Event handlers должны диспетчеризировать в маленькие view methods, например save/log handlers.
- Не помещай DB selection или file parsing в ALV event handlers.

Текущие примеры:

- `zsd_3965_lp`: SALV table с `ZZ_SAVE` и `ZZ_LOG`.
- `report_ethalon2`: `cl_gui_alv_grid` с toolbar/user-command/double-click handling.

## Логирование Через `zcl_logger`

Проектная договоренность: использовать `zcl_logger` вместо прямой работы с Application Log в application code.

Паттерны:

- Создавай или inject один logger на сценарий.
- Передавай logger в main, DAO и view classes, если им нужно добавлять или показывать сообщения.
- Используй `add_syst_msg` после `MESSAGE ... INTO`.
- Используй `add_bapiret` для validation result tables.
- Используй `display_log` в view/log action.
- Подробный референс: `docs/agent-context/references/zcl_logger.md`.

Прямые BAL reads допустимы в DAO/helper methods, когда отчет явно читает существующие application logs, как в эталонном проекте.

## Полномочия

Проверки полномочий размещай в DAO methods или маленьком authorization service, затем main class корректирует выбранные ranges или останавливает обработку.

Эталонный паттерн: `check_auth_iwerk`, `check_auth_swerk`, `check_iwerk_authorities`, `check_swerk_authorities` в `report_ethalon2`.

## Save Flow

Для save buttons:

- Регистрируй или готовь лог до persistence, если сохраняемым строкам нужен log GUID.
- Явно маппь selected/display rows обратно в DB rows.
- Перед update/persistence function modules удаляй дубли.
- Держи commit behavior централизованным и видимым.

# Паттерны ABAP Unit

Используй этот файл при добавлении или изменении unit-тестов.

## Что Тестировать

В первую очередь покрывай детерминированную логику:

- чтение и нормализацию selection-screen параметров;
- parsing строк файла;
- validation даты, количества, материала и завода;
- plant mapping;
- поиск дублей;
- построение ALV table;
- filtering по ranges и режимам;
- подготовку данных к сохранению до persistence;
- сбор log messages в `bapiret2_t` или `zcl_logger`.

Не unit-тестируй SAP GUI rendering, реальные file dialogs, реальное состояние БД, update tasks и transactions напрямую.

## Dependency Seams

Используй существующий seam style:

- Внешние зависимости держи за `lif_dao`/`lcl_dao`.
- В тестах заменяй DAO локальным mock class.
- File conversion мокай возвратом `tt_intab`.
- Reference data reads мокай явно: material texts, material existence, plant names, plant mapping.
- Save/log methods мокай через capture input или stable return IDs.

Текущий пример: `zsd_3965_lp_tst.prog.abap` содержит `lcl_dao_mock INHERITING FROM lcl_dao`.

## Осторожно С Singleton

`lcl_app=>get_instance` и `lcl_filereader=>get_instance` сохраняют состояние.

Для надежных тестов:

- инициализируй mocks в `class_setup` или `setup`;
- явно inject mock DAO;
- при необходимости сбрасывай singleton state через существующие `set_instance` methods;
- очищай mutable app state перед каждым тестом, если поведение зависит от предыдущих вызовов;
- не делай тесты, зависящие от порядка выполнения.

## Тестовые Данные

Данные должны быть маленькими и целевыми.

- Добавляй минимум одну валидную строку.
- Для parser logic добавляй invalid date, invalid number, unknown material, empty plant, unmapped `Q*` plant и plant outside selection.
- Для duplicate logic добавляй дублирующиеся display keys.
- Используй стабильные expected tables и `cl_abap_unit_assert=>assert_equals`.

## Рекомендуемая Форма Теста

1. Arrange: screen parameters и mock DAO returns.
2. Act: один public application/parser method.
3. Assert: DB rows, ALV rows, messages и captured save/log input.

Не делай широкий end-to-end test, если маленький parser или mapping test точнее изолирует поведение.

## Исключения и граничные случаи

Добавляйте тесты на ожидаемые ошибки рядом с обычным сценарием:

- отсутствие строки в reference table;
- неинициализированную ссылку или пустой результат DAO, если это допустимый вход;
- ожидаемое исключение DAO/внешнего API, преобразованное в `bapiret2_t` или лог;
- запрет продолжения save flow после технической ошибки.

В unit-тесте проверяйте наблюдаемый результат: сообщения, возвращаемый статус и отсутствие вызова persistence через mock. Не тестируйте реальный short dump или реальную БД.
## Тесты Логирования

Когда логика пишет сообщения:

- Лучше проверять собранный `bapiret2_t` до передачи в `zcl_logger`.
- Для `MESSAGE ... INTO` flows проверяй результат ветки, если нет logger mock.
- Не вызывай реальный `display_log` в unit tests.

## Текущие Пробелы В Покрытии

Сейчас тесты покрывают базовые selection-screen helpers и один сценарий `start_of_selection`. Хорошие следующие тесты:

- ветка `p_dpios = 'X'` и mapping в `z_tsd_3965_3_pl`;
- строки с invalid amount/date/material/plant;
- plant mapping для `Q*` из `ztsd_werkprd`;
- duplicate detection messages;
- подготовка save и GUID assignment без реального persistence.

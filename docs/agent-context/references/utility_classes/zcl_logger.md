# Референс `zcl_logger`

Этот файл нужен агенту как короткая памятка по проектному логированию.

## Роль

`zcl_logger` - проектный фасад логирования. В прикладной логике используй его вместо прямой работы с Application Log/BAL.

Прямые BAL function modules допустимы только в DAO/helper-коде, когда задача отчета - читать уже существующие application logs. Пример: `report_ethalon2/zpm_pdm_log_i02.prog.abap`.

## Создание И Передача

Типовой сценарий:

```abap
DATA(lo_logger) = NEW zcl_logger( ).
```

Для логов с именем:

```abap
DATA(lo_logger) = NEW zcl_logger( i_log_name = 'ZPM_PDM' ).
```

Передавай logger в main/app, DAO и view classes через constructor или параметр, если класс пишет или показывает сообщения.

## Сообщения Из `sy`

Паттерн из эталона:

```abap
MESSAGE s002(zpm_pdm_log) WITH lv_lines INTO DATA(lv_dummy).
mo_logger->add_syst_msg( is_syst = sy ).
```

Важно: `MESSAGE ... INTO` нужен, чтобы заполнить `sy-msg*`, затем `add_syst_msg` переносит сообщение в logger.

## BAPIRET2-Валидация

Для массовой валидации собирай `bapiret2_t`, затем добавляй в logger:

```abap
lo_logger->add_bapiret(
  EXPORTING
    im_ret = lt_bapiret ).
```

Так сделано в `zsd_3965_lp_ci01.prog.abap` после чтения и валидации файла.

## Показ Лога

Показ должен быть UI/action concern:

```abap
mo_logger->display_log( ).
```

Пример: кнопка `ZZ_LOG` в `lcl_view->handle_log`.

## Правила Для Нового Кода

- Не создавай параллельный механизм логирования.
- Не вызывай `display_log` из unit tests.
- Не размещай прямые BAL calls в business/parser logic.
- Для ошибок строк файла возвращай `bapiret2_t`, а не сразу показывай сообщения.
- Для DAO-операций можно логировать технический результат через `MESSAGE ... INTO` + `add_syst_msg`.

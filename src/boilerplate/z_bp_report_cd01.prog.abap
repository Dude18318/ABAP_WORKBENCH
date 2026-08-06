*&---------------------------------------------------------------------*
*& Include Z_BP_REPORT_CD01
*&---------------------------------------------------------------------*
*& Определения локальных классов и интерфейсов.
*& Здесь — ТОЛЬКО заголовки (DEFINITION). Реализация — в CI01.
*&---------------------------------------------------------------------*

* Forward-объявления тестовых классов (нужны для FRIENDS)
CLASS lcl_test_app DEFINITION DEFERRED.
CLASS lcl_test_view DEFINITION DEFERRED.

*======================================================================*
* INTERFACE lif_dao
*======================================================================*
* Контракт слоя доступа к данным.
* Изолирует нетестируемые зависимости:
*   - SELECT-запросы к БД
*   - Вызовы ФМ / BAPI
*   - COMMIT WORK / ROLLBACK
*   - CALL SCREEN (UI-переходы)
*   - AUTHORITY-CHECK
*----------------------------------------------------------------------*
INTERFACE lif_dao.

  "-- Типы, специфичные для DAO-контракта --
  TYPES:
    BEGIN OF ty_s_db_record,
      field1 TYPE char20,
      field2 TYPE char40,
      amount TYPE p LENGTH 8 DECIMALS 2,
    END OF ty_s_db_record,
    ty_t_db_records TYPE STANDARD TABLE OF ty_s_db_record WITH EMPTY KEY.

  "-- Чтение данных --
  METHODS select_data
    IMPORTING is_params      TYPE ty_s_screen_params
    RETURNING VALUE(rt_data) TYPE ty_t_alv_data.

  "-- Сохранение данных с возвратом сообщений --
  METHODS save_data
    IMPORTING it_data            TYPE ty_t_db_records
    RETURNING VALUE(rt_messages) TYPE bapiret2_t.

  "-- Фиксация / откат транзакции --
  METHODS commit_work
    IMPORTING iv_wait TYPE flag.

  METHODS rollback_work.

  "-- Вызов экрана (изолирован в DAO для мокирования в тестах) --
  METHODS call_screen_0100.

  "-- Вызов popup-экрана --
  METHODS call_screen_0200.

ENDINTERFACE.

*======================================================================*
* CLASS lcl_dao DEFINITION
*======================================================================*
* Продуктивная реализация DAO.
* Содержит реальные SQL-запросы, вызовы ФМ, COMMIT WORK, CALL SCREEN.
*----------------------------------------------------------------------*
CLASS lcl_dao DEFINITION.
  PUBLIC SECTION.
    INTERFACES lif_dao.
ENDCLASS.

*======================================================================*
* CLASS lcl_view DEFINITION
*======================================================================*
* Слой представления (View / GUI).
* Отвечает за:
*   - CL_GUI_ALV_GRID + CL_GUI_CUSTOM_CONTAINER
*   - Генерацию fieldcatalog
*   - Обработку событий ALV (toolbar, user_command, data_changed)
*   - Визуальное форматирование (cell_color, style)
*   - Освобождение ресурсов GUI (cleanup)
*
* FRIENDS lcl_test_view — позволяет Unit-тестам проверять приватное
* состояние view без нарушения инкапсуляции в продуктивном коде.
*----------------------------------------------------------------------*
CLASS lcl_view DEFINITION FRIENDS lcl_test_view.
  PUBLIC SECTION.

    METHODS constructor
      IMPORTING
        io_dao           TYPE REF TO lif_dao
        is_screen_params TYPE ty_s_screen_params.

    "-- Отображение ALV на экране 0100 --
    METHODS display_alv.

    "-- PBO / PAI экрана 0100 --
    METHODS pbo_0100.
    METHODS pai_0100.

    "-- Переключение режима редактирования --
    METHODS toggle_edit_mode.

    "-- Очистка ресурсов GUI и памяти (согласно правилам СИБУР) --
    METHODS cleanup.

  PRIVATE SECTION.

    DATA:
      mo_dao            TYPE REF TO lif_dao,
      ms_screen_params  TYPE ty_s_screen_params,
      mo_grid           TYPE REF TO cl_gui_alv_grid,
      mo_container      TYPE REF TO cl_gui_custom_container,
      mt_fcat           TYPE lvc_t_fcat,
      ms_layout         TYPE lvc_s_layo,
      ms_variant        TYPE disvariant,
      mv_edit_mode      TYPE abap_bool.

    "-- Настройка колонок fieldcatalog --
    METHODS setup_columns.

    "-- Регистрация обработчиков событий ALV --
    METHODS setup_events.

    "-- Раскраска ячеек по правилам валидации --
    METHODS fill_cell_colors
      CHANGING
        cs_row TYPE any.

    "-- Обработчик: формирование пользовательского тулбара ALV --
    METHODS handle_toolbar
      FOR EVENT toolbar OF cl_gui_alv_grid
      IMPORTING
        e_object
        e_interactive.

    "-- Обработчик: реакция на нажатие кнопок тулбара ALV --
    METHODS handle_user_command
      FOR EVENT user_command OF cl_gui_alv_grid
      IMPORTING
        e_ucomm.

    "-- Обработчик: реакция на изменение данных в гриде --
    METHODS handle_data_changed
      FOR EVENT data_changed OF cl_gui_alv_grid
      IMPORTING
        er_data_changed.

    "-- Диспетчер пользовательских команд --
    METHODS process_command
      IMPORTING
        iv_ucomm TYPE syucomm.

ENDCLASS.

*======================================================================*
* CLASS lcl_app DEFINITION
*======================================================================*
* Контроллер приложения (Application Controller).
* Singleton-паттерн: get_instance() / set_instance().
*
* Отвечает за:
*   - Управление жизненным циклом (initialize, run, cleanup)
*   - Парсинг экрана выбора -> ms_screen_params
*   - Вызов DAO для данных
*   - Передачу данных во View
*   - Оркестрацию бизнес-операций
*   - Логирование через zcl_logger
*
* FRIENDS lcl_test_app — позволяет Unit-тестам подменять и проверять
* приватные атрибуты контроллера.
*----------------------------------------------------------------------*
CLASS lcl_app DEFINITION FRIENDS lcl_test_app.
  PUBLIC SECTION.

    "-- Singleton: получение экземпляра --
    CLASS-METHODS get_instance
      IMPORTING
        io_dao             TYPE REF TO object OPTIONAL
      RETURNING
        VALUE(ro_instance) TYPE REF TO lcl_app.

    "-- Singleton: подмена экземпляра (используется в тестах) --
    CLASS-METHODS set_instance
      IMPORTING
        io_instance TYPE REF TO lcl_app.

    METHODS constructor
      IMPORTING io_dao TYPE REF TO object OPTIONAL.

    "-- Жизненный цикл --
    METHODS initialize.
    METHODS analyze_selection_screen.
    METHODS adjust_selection_screen.
    METHODS run.
    METHODS cleanup.

    "-- PBO / PAI —— делегация во View --
    METHODS pbo_0100.
    METHODS pai_0100.

  PRIVATE SECTION.

    CLASS-DATA:
      go_instance TYPE REF TO lcl_app.

    DATA:
      ms_screen_params TYPE ty_s_screen_params,
      mo_dao           TYPE REF TO lif_dao,
      mo_logger        TYPE REF TO zcl_logger,
      mo_view          TYPE REF TO lcl_view.

    "-- Загрузка данных через DAO --
    METHODS fetch_data
      IMPORTING is_params      TYPE ty_s_screen_params
      RETURNING VALUE(rt_data) TYPE ty_t_alv_data.

    "-- Вывод данных через View --
    METHODS output_data.

ENDCLASS.

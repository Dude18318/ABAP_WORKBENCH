*&---------------------------------------------------------------------*
*& Include Z_BP_REPORT_TST
*&---------------------------------------------------------------------*
*& ABAP Unit тесты.
*&
*& Архитектура тестирования:
*&   1. lcl_dao_mock — самостоятельный тестовый дублёр DAO (реализует
*&      интерфейс lif_dao напрямую, НЕ наследуя тяжелый lcl_dao).
*&      Возвращает предзаполненные mock-таблицы, записывает факт вызова
*&      commit/rollback/save и полностью изолирует тесты от БД и GUI.
*&   2. lcl_test_app — тестирует бизнес-логику lcl_app в изоляции от БД.
*&   3. lcl_test_view — тестирует алгоритмы lcl_view (чистые функции).
*&
*& Изоляция: DAO мокируется через DI (constructor injection в lcl_app).
*& Screen-вызовы (CALL SCREEN) в lif_dao обёрнуты и мокируются в тестах.
*&---------------------------------------------------------------------*

*======================================================================*
* CLASS lcl_dao_mock DEFINITION
*======================================================================*
* Тестовый дублёр DAO.
* Реализует lif_dao напрямую (SOLID: Interface Segregation & Dependency Inversion).
* Паттерн: «Recording mock» — записывает факт вызовов
* и возвращает предзаполненные данные.
*----------------------------------------------------------------------*
CLASS lcl_dao_mock DEFINITION.
  PUBLIC SECTION.
    INTERFACES lif_dao.

    "-- Mock-данные: заполняются в setup() каждого теста --
    DATA:
      mt_mock_data     TYPE ty_t_alv_data,        " Мок для select_data
      mt_mock_save_log TYPE lif_dao=>ty_t_db_records. " Лог сохранённых данных

    "-- Записи вызовов (для проверки в Assert) --
    DATA:
      mv_commit_called   TYPE abap_bool,
      mv_rollback_called TYPE abap_bool,
      mv_save_called     TYPE abap_bool,
      mv_screen_called   TYPE abap_bool.

ENDCLASS.

CLASS lcl_dao_mock IMPLEMENTATION.

  METHOD lif_dao~select_data.
    " Возвращаем предзаполненные mock-данные
    rt_data = mt_mock_data.
  ENDMETHOD.

  METHOD lif_dao~save_data.
    " Записываем переданные данные в лог (для Assert)
    mv_save_called = abap_true.
    mt_mock_save_log = it_data.
    APPEND VALUE #( type = 'S' id = 'ZMSG' number = '001' message = 'Mock: сохранено' ) TO rt_messages.
  ENDMETHOD.

  METHOD lif_dao~commit_work.
    mv_commit_called = abap_true.
  ENDMETHOD.

  METHOD lif_dao~rollback_work.
    mv_rollback_called = abap_true.
  ENDMETHOD.

  METHOD lif_dao~call_screen_0100.
    " Не вызываем реальный экран в тестах!
    mv_screen_called = abap_true.
  ENDMETHOD.

  METHOD lif_dao~call_screen_0200.
    mv_screen_called = abap_true.
  ENDMETHOD.

ENDCLASS.

*======================================================================*
* CLASS lcl_test_app DEFINITION
*======================================================================*
* Тесты контроллера приложения (lcl_app).
* FRIENDS-доступ позволяет проверять приватные атрибуты.
*----------------------------------------------------------------------*
CLASS lcl_test_app DEFINITION FOR TESTING
  DURATION SHORT RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    DATA:
      mo_cut      TYPE REF TO lcl_app,       " Class Under Test
      mo_dao_mock TYPE REF TO lcl_dao_mock.

    "-- Фикстура --
    METHODS setup.
    METHODS teardown.

    "-- Тесты --
    METHODS test_fetch_data        FOR TESTING.
    METHODS test_initialize        FOR TESTING.
    METHODS test_analyze_sel_screen FOR TESTING.
    METHODS test_cleanup           FOR TESTING.

ENDCLASS.

CLASS lcl_test_app IMPLEMENTATION.

  METHOD setup.
    " --- Arrange: создаём mock DAO и инжектируем в App ---
    mo_dao_mock = NEW lcl_dao_mock( ).
    mo_cut = NEW lcl_app( io_dao = mo_dao_mock ).

    " Подменяем синглтон, чтобы get_instance() возвращал наш экземпляр
    lcl_app=>set_instance( mo_cut ).
  ENDMETHOD.

  METHOD teardown.
    " --- Очистка: сбрасываем синглтон и глобальные ссылки ---
    IF mo_cut IS BOUND.
      mo_cut->cleanup( ).
    ENDIF.
    lcl_app=>set_instance( VALUE #( ) ).
  ENDMETHOD.

  METHOD test_fetch_data.
    " --- Arrange ---
    APPEND VALUE #( field1 = 'TEST1' field2 = 'VALUE1' amount = 100 )
      TO mo_dao_mock->mt_mock_data.

    " --- Act ---
    DATA(lt_result) = mo_cut->fetch_data(
      is_params = VALUE ty_s_screen_params( ) ).

    " --- Assert ---
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_result )
      msg = 'Должна вернуться одна строка из mock' ).

    cl_abap_unit_assert=>assert_equals(
      exp = 'TEST1'
      act = lt_result[ 1 ]-field1
      msg = 'field1 должен совпадать с mock-данными' ).

    " Статус должен быть установлен в fetch_data
    cl_abap_unit_assert=>assert_equals(
      exp = icon_green_light
      act = lt_result[ 1 ]-status
      msg = 'Статус должен быть зелёным для валидных данных' ).
  ENDMETHOD.

  METHOD test_initialize.
    " --- Act ---
    mo_cut->initialize( ).

    " --- Assert ---
    " Проверка инициализации
  ENDMETHOD.

  METHOD test_analyze_sel_screen.
    " --- Act ---
    mo_cut->analyze_selection_screen( ).
  ENDMETHOD.

  METHOD test_cleanup.
    " --- Arrange ---
    DATA lt_data TYPE ty_t_alv_data.
    APPEND VALUE #( field1 = 'TEST' ) TO lt_data.
    gr_disp_data = REF #( lt_data ).

    " --- Act ---
    mo_cut->cleanup( ).

    " --- Assert: глобальные ссылки очищены ---
    cl_abap_unit_assert=>assert_initial(
      act = gr_disp_data
      msg = 'Глобальная ссылка gr_disp_data должна быть очищена при cleanup' ).
  ENDMETHOD.

ENDCLASS.

*======================================================================*
* CLASS lcl_test_view DEFINITION
*======================================================================*
* Тесты слоя представления (lcl_view).
* Тестируются чистые алгоритмы, не требующие реального GUI.
* FRIENDS-доступ через lcl_test_view.
*----------------------------------------------------------------------*
CLASS lcl_test_view DEFINITION FOR TESTING
  DURATION SHORT RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    DATA:
      mo_cut      TYPE REF TO lcl_view,
      mo_dao_mock TYPE REF TO lcl_dao_mock.

    METHODS setup.
    METHODS teardown.

    "-- Тесты --
    METHODS test_toggle_edit_mode FOR TESTING.
    METHODS test_cleanup          FOR TESTING.

ENDCLASS.

CLASS lcl_test_view IMPLEMENTATION.

  METHOD setup.
    mo_dao_mock = NEW lcl_dao_mock( ).
    DATA ls_params TYPE ty_s_screen_params.
    mo_cut = NEW lcl_view(
      io_dao           = mo_dao_mock
      is_screen_params = ls_params ).
  ENDMETHOD.

  METHOD teardown.
  ENDMETHOD.

  METHOD test_toggle_edit_mode.
    " --- Assert: начальное состояние ---
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = mo_cut->mv_edit_mode
      msg = 'Начальный режим — просмотр' ).

    " --- Act ---
    mo_cut->toggle_edit_mode( ).

    " --- Assert: после переключения ---
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = mo_cut->mv_edit_mode
      msg = 'Должен переключиться в режим редактирования' ).

    " --- Act: обратное переключение ---
    mo_cut->toggle_edit_mode( ).

    " --- Assert ---
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = mo_cut->mv_edit_mode
      msg = 'Должен вернуться в режим просмотра' ).
  ENDMETHOD.

  METHOD test_cleanup.
    " --- Act ---
    mo_cut->cleanup( ).

    " --- Assert: после cleanup объект не падает ---
    cl_abap_unit_assert=>assert_initial(
      act = mo_cut->mo_grid
      msg = 'Grid должен быть сброшен после cleanup' ).
  ENDMETHOD.

ENDCLASS.

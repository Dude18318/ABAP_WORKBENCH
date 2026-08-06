*&---------------------------------------------------------------------*
*& Include Z_BP_REPORT_CI01
*&---------------------------------------------------------------------*
*& Реализация локальных классов.
*& Порядок: lcl_dao -> lcl_view -> lcl_app
*&---------------------------------------------------------------------*

*======================================================================*
* CLASS lcl_dao IMPLEMENTATION
*======================================================================*
* Продуктивный DAO: реальные SQL-запросы, ФМ, экраны.
* Все обращения к БД — ТОЛЬКО здесь.
*----------------------------------------------------------------------*
CLASS lcl_dao IMPLEMENTATION.

  METHOD lif_dao~select_data.
    " TODO: Реальный SELECT-запрос
    " Пример скелета:
    " SELECT field1, field2, amount
    "   FROM ztable
    "   INTO CORRESPONDING FIELDS OF TABLE @rt_data
    "   WHERE field1 IN @is_params-key1
    "     AND field2 IN @is_params-key2.
  ENDMETHOD.

  METHOD lif_dao~save_data.
    " TODO: Реальное сохранение с возвратом сообщений BAPI
    " Пример:
    " MODIFY ztable FROM TABLE @it_data.
    " IF sy-subrc = 0.
    "   APPEND VALUE #( type = 'S' id = 'ZMSG' number = '001' message = 'Данные успешно сохранены' ) TO rt_messages.
    " ELSE.
    "   APPEND VALUE #( type = 'E' id = 'ZMSG' number = '002' message = 'Ошибка при сохранении в БД' ) TO rt_messages.
    " ENDIF.
  ENDMETHOD.

  METHOD lif_dao~commit_work.
    IF iv_wait = abap_true.
      COMMIT WORK AND WAIT.
    ELSE.
      COMMIT WORK.
    ENDIF.
  ENDMETHOD.

  METHOD lif_dao~rollback_work.
    ROLLBACK WORK.
  ENDMETHOD.

  METHOD lif_dao~call_screen_0100.
    CALL SCREEN 0100.
  ENDMETHOD.

  METHOD lif_dao~call_screen_0200.
    CALL SCREEN 0200 STARTING AT 10 10 ENDING AT 50 20.
  ENDMETHOD.

ENDCLASS.

*======================================================================*
* CLASS lcl_view IMPLEMENTATION
*======================================================================*
* Слой представления: ALV Grid + CL_GUI_CUSTOM_CONTAINER.
* Все UI-операции — ТОЛЬКО здесь.
*----------------------------------------------------------------------*
CLASS lcl_view IMPLEMENTATION.

  METHOD constructor.
    mo_dao           = io_dao.
    ms_screen_params = is_screen_params.
    mv_edit_mode     = abap_false.
  ENDMETHOD.

  METHOD display_alv.
    " Делегируем отображение на экран 0100 через DAO
    " (CALL SCREEN изолирован в DAO для мокирования)
    mo_dao->call_screen_0100( ).
  ENDMETHOD.

  METHOD pbo_0100.

    IF mo_container IS NOT BOUND.
      " --- Создание контейнера и грида (один раз) ---
      CREATE OBJECT mo_container
        EXPORTING
          container_name = 'CONTAINER'.   " Имя Custom Control на экране 0100

      CREATE OBJECT mo_grid
        EXPORTING
          i_parent = mo_container.

      " --- Настройка колонок и событий ---
      setup_columns( ).
      setup_events( ).

      " --- Layout ---
      ms_layout-zebra      = abap_true.
      ms_layout-cwidth_opt = abap_true.
      ms_layout-sel_mode   = 'A'.         " Множественный выбор строк
      ms_layout-ctab_fname = 'CELL_COLOR'. " Поле раскраски ячеек
      ms_layout-stylefname = 'STYLE'.      " Поле стилей (редактируемость)

      " --- Вариант отображения ---
      ms_variant-report  = sy-repid.

      " --- Первичное отображение ---
      FIELD-SYMBOLS: <lt_data> TYPE STANDARD TABLE.
      IF gr_disp_data IS BOUND.
        ASSIGN gr_disp_data->* TO <lt_data>.

        mo_grid->set_table_for_first_display(
          EXPORTING
            is_layout       = ms_layout
            is_variant      = ms_variant
            i_save          = 'A'
            i_default       = abap_true
          CHANGING
            it_outtab       = <lt_data>
            it_fieldcatalog = mt_fcat ).
      ENDIF.

    ELSE.
      " --- Повторный PBO: обновляем данные ---
      mo_grid->refresh_table_display( ).
    ENDIF.

  ENDMETHOD.

  METHOD pai_0100.
    " Реакция на пользовательские команды экрана 0100
    " (команды ALV-тулбара обрабатываются в handle_user_command)
  ENDMETHOD.

  METHOD toggle_edit_mode.
    IF mv_edit_mode = abap_true.
      mv_edit_mode = abap_false.
    ELSE.
      mv_edit_mode = abap_true.
    ENDIF.
    " TODO: Обновить стили ячеек для включения/отключения редактирования
    " и вызвать mo_grid->refresh_table_display( ).
  ENDMETHOD.

  METHOD cleanup.
    " --- Корректное освобождение ресурсов GUI и очистка памяти ---
    " Регламент СИБУР: обязательное уничтожение ALV-сессии при выходе с экрана.
    IF mo_grid IS BOUND.
      mo_grid->free( ).
      FREE mo_grid.
    ENDIF.

    IF mo_container IS BOUND.
      mo_container->free( ).
      FREE mo_container.
    ENDIF.

    CLEAR mt_fcat.
  ENDMETHOD.

  METHOD setup_columns.
    " --- Генерация fieldcatalog из SALV-метаданных ---
    DATA: lo_salv  TYPE REF TO cl_salv_table,
          lt_dummy TYPE ty_t_alv_data.

    TRY.
        cl_salv_table=>factory(
          IMPORTING r_salv_table = lo_salv
          CHANGING  t_table      = lt_dummy ).

        mt_fcat = cl_salv_controller_metadata=>get_lvc_fieldcatalog(
                    r_columns      = lo_salv->get_columns( )
                    r_aggregations = lo_salv->get_aggregations( ) ).
      CATCH cx_salv_msg.
        RETURN.
    ENDTRY.

    " --- Настройка отдельных колонок ---
    LOOP AT mt_fcat ASSIGNING FIELD-SYMBOL(<ls_fcat>).
      CASE <ls_fcat>-fieldname.

        " Скрытые технические колонки
        WHEN 'CELL_COLOR' OR 'STYLE' OR 'MARK_DEL'.
          <ls_fcat>-tech = abap_true.

        " Иконка статуса
        WHEN 'STATUS'.
          <ls_fcat>-icon      = abap_true.
          <ls_fcat>-outputlen = 4.
          <ls_fcat>-coltext   = 'Ст'.

        " Иконка индикатора изменений
        WHEN 'EDIT_INDICATOR'.
          <ls_fcat>-icon      = abap_true.
          <ls_fcat>-outputlen = 4.
          <ls_fcat>-coltext   = 'Изм'.

        " TODO: Настройка предметных колонок (заголовки, ширина, edit и т.д.)
        WHEN OTHERS.
      ENDCASE.
    ENDLOOP.

  ENDMETHOD.

  METHOD setup_events.
    " --- Регистрация обработчиков событий ALV Grid ---
    SET HANDLER handle_toolbar      FOR mo_grid.
    SET HANDLER handle_user_command  FOR mo_grid.
    SET HANDLER handle_data_changed  FOR mo_grid.

    " --- Включение событий редактирования ---
    mo_grid->register_edit_event(
        i_event_id = cl_gui_alv_grid=>mc_evt_modified ).
    mo_grid->register_edit_event(
        i_event_id = cl_gui_alv_grid=>mc_evt_enter ).
  ENDMETHOD.

  METHOD fill_cell_colors.
    " --- Раскраска ячеек по правилам валидации ---
  ENDMETHOD.

  METHOD handle_toolbar.
    " --- Добавление кастомных кнопок в тулбар ALV ---
    DATA ls_button TYPE stb_button.

    " Разделитель
    CLEAR ls_button.
    ls_button-butn_type = 3. " Separator
    APPEND ls_button TO e_object->mt_toolbar.

    " Кнопка: Переключить редактирование
    CLEAR ls_button.
    ls_button-function  = 'ZEDITALL'.
    ls_button-icon      = icon_toggle_display_change.
    ls_button-text      = 'Редактирование'.
    ls_button-quickinfo = 'Переключить режим редактирования'.
    APPEND ls_button TO e_object->mt_toolbar.

    " Кнопка: Сохранить в БД
    CLEAR ls_button.
    ls_button-function  = 'ZSAVEDB'.
    ls_button-icon      = icon_system_save.
    ls_button-text      = 'Сохранить'.
    ls_button-quickinfo = 'Сохранить изменения в базу данных'.
    APPEND ls_button TO e_object->mt_toolbar.
  ENDMETHOD.

  METHOD handle_user_command.
    " --- Диспетчеризация команд тулбара ALV ---
    process_command( iv_ucomm = e_ucomm ).
  ENDMETHOD.

  METHOD handle_data_changed.
    " --- Реакция на inline-редактирование ячеек ---
  ENDMETHOD.

  METHOD process_command.
    " --- Обработка пользовательских команд ---
    CASE iv_ucomm.
      WHEN 'ZEDITALL'.
        toggle_edit_mode( ).

      WHEN 'ZSAVEDB'.
        " TODO: Собрать данные из ALV, вызвать сохранение через lcl_app

      WHEN OTHERS.
        " Неизвестная команда — игнорируем
    ENDCASE.
  ENDMETHOD.

ENDCLASS.

*======================================================================*
* CLASS lcl_app IMPLEMENTATION
*======================================================================*
* Контроллер приложения. Управляет жизненным циклом.
*----------------------------------------------------------------------*
CLASS lcl_app IMPLEMENTATION.

  METHOD get_instance.
    IF go_instance IS NOT BOUND.
      go_instance = NEW lcl_app( io_dao = io_dao ).
    ENDIF.
    ro_instance = go_instance.
  ENDMETHOD.

  METHOD set_instance.
    go_instance = io_instance.
  ENDMETHOD.

  METHOD constructor.
    " --- Dependency Injection: подмена DAO ---
    IF io_dao IS BOUND.
      mo_dao ?= io_dao.
    ELSE.
      mo_dao = NEW lcl_dao( ).
    ENDIF.

    " --- Логгер ---
    mo_logger = NEW zcl_logger( ).
  ENDMETHOD.

  METHOD initialize.
    " --- Начальная инициализация ---
  ENDMETHOD.

  METHOD analyze_selection_screen.
    " --- Маппинг параметров экрана выбора в единую структуру ---
    ms_screen_params-key1 = s_key1[].
    ms_screen_params-key2 = s_key2[].
  ENDMETHOD.

  METHOD adjust_selection_screen.
    " --- Динамическое управление видимостью полей ---
  ENDMETHOD.

  METHOD run.
    " --- Главная точка входа (START-OF-SELECTION) ---
    DATA(lt_data) = fetch_data( is_params = ms_screen_params ).

    " Сохраняем данные в глобальную ссылку для Dynpro/ALV
    gr_disp_data = REF #( lt_data ).

    " Выводим
    output_data( ).
  ENDMETHOD.

  METHOD cleanup.
    " --- Вызов очистки во View и освобождение глобальной памяти ---
    IF mo_view IS BOUND.
      mo_view->cleanup( ).
    ENDIF.

    IF gr_disp_data IS BOUND.
      CLEAR gr_disp_data->*.
      FREE gr_disp_data.
    ENDIF.
  ENDMETHOD.

  METHOD fetch_data.
    " --- Загрузка данных через DAO ---
    rt_data = mo_dao->select_data( is_params = is_params ).

    " --- Обогащение данных (статус-иконки, валидация) ---
    LOOP AT rt_data ASSIGNING FIELD-SYMBOL(<ls_row>).
      <ls_row>-status = icon_green_light.
    ENDLOOP.
  ENDMETHOD.

  METHOD output_data.
    " --- Создание View и отображение ALV ---
    mo_view = NEW lcl_view(
      io_dao           = mo_dao
      is_screen_params = ms_screen_params ).

    mo_view->display_alv( ).
  ENDMETHOD.

  METHOD pbo_0100.
    " --- PBO экрана 0100: делегация во View ---
    IF mo_view IS BOUND.
      mo_view->pbo_0100( ).
    ENDIF.
  ENDMETHOD.

  METHOD pai_0100.
    " --- PAI экрана 0100: делегация во View ---
    IF mo_view IS BOUND.
      mo_view->pai_0100( ).
    ENDIF.
  ENDMETHOD.

ENDCLASS.

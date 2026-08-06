*&---------------------------------------------------------------------*
*& Include Z_BP_INTERACTIVE_ALV_CI01
*&---------------------------------------------------------------------*
CLASS lcl_dao IMPLEMENTATION.
  METHOD lif_dao~select_data.
    " TODO: Реальный SELECT вынести сюда по правилам DAO
    rt_data = VALUE #(
      ( status = icon_green_light key1 = 'ROW_01' text1 = 'Interactive ALV boilerplate' amount = '10.00' )
      ( status = icon_yellow_light key1 = 'ROW_02' text1 = 'Подходит для toolbar/events' amount = '20.00' ) ).
  ENDMETHOD.
ENDCLASS.

CLASS lcl_view IMPLEMENTATION.
  METHOD display.
    CALL SCREEN 0100.
  ENDMETHOD.

  METHOD pbo_0100.
    IF mo_container IS NOT BOUND.
      CREATE OBJECT mo_container EXPORTING container_name = 'CONTAINER'.
      CREATE OBJECT mo_grid EXPORTING i_parent = mo_container.

      build_fieldcat( ).
      SET HANDLER handle_toolbar FOR mo_grid.
      SET HANDLER handle_user_command FOR mo_grid.

      mo_grid->set_table_for_first_display(
        CHANGING it_outtab = gt_alv_data it_fieldcatalog = mt_fcat ).
    ELSE.
      mo_grid->refresh_table_display( ).
    ENDIF.
  ENDMETHOD.

  METHOD pai_0100.
  ENDMETHOD.

  METHOD build_fieldcat.
    mt_fcat = VALUE #(
      ( fieldname = 'STATUS' icon = abap_true coltext = 'Ст' )
      ( fieldname = 'KEY1' coltext = 'Ключ' )
      ( fieldname = 'TEXT1' coltext = 'Описание' )
      ( fieldname = 'AMOUNT' coltext = 'Сумма' )
      ( fieldname = 'CELL_COLOR' tech = abap_true ) ).
  ENDMETHOD.

  METHOD handle_toolbar.
    DATA ls_button TYPE stb_button.
    ls_button-function = 'ZREFRESH'.
    ls_button-icon = icon_refresh.
    ls_button-text = 'Обновить'.
    APPEND ls_button TO e_object->mt_toolbar.
  ENDMETHOD.

  METHOD handle_user_command.
    CASE e_ucomm.
      WHEN 'ZREFRESH'.
        MESSAGE 'Здесь можно подключить повторную загрузку данных' TYPE 'S'.
      WHEN OTHERS.
    ENDCASE.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_app IMPLEMENTATION.
  METHOD constructor.
    mo_dao = NEW lcl_dao( ).
    mo_view = NEW lcl_view( ).
  ENDMETHOD.

  METHOD get_instance.
    IF go_instance IS NOT BOUND.
      go_instance = NEW lcl_app( ).
    ENDIF.
    ro_instance = go_instance.
  ENDMETHOD.

  METHOD get_params.
    rs_params-key1 = s_key1[].
  ENDMETHOD.

  METHOD run.
    gt_alv_data = mo_dao->select_data( is_params = get_params( ) ).
    mo_view->display( ).
  ENDMETHOD.

  METHOD pbo_0100.
    mo_view->pbo_0100( ).
  ENDMETHOD.

  METHOD pai_0100.
    mo_view->pai_0100( ).
  ENDMETHOD.
ENDCLASS.

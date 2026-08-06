*&---------------------------------------------------------------------*
*& Include Z_BP_SALV_LIGHT_CI01
*&---------------------------------------------------------------------*
CLASS lcl_dao IMPLEMENTATION.
  METHOD lif_dao~select_data.
    " TODO: Заменить на реальный SELECT по предметной таблице
    rt_data = VALUE #(
      ( status = icon_green_light key1 = 'DEMO_01' text1 = 'SALV light boilerplate' amount = '100.00' )
      ( status = icon_yellow_light key1 = 'DEMO_02' text1 = 'Подходит для read-only списков' amount = '250.50' ) ).
  ENDMETHOD.
ENDCLASS.

CLASS lcl_view IMPLEMENTATION.
  METHOD display.
    DATA lt_data TYPE ty_t_rows.
    DATA lo_salv TYPE REF TO cl_salv_table.

    lt_data = it_data.

    TRY.
        cl_salv_table=>factory(
          IMPORTING r_salv_table = lo_salv
          CHANGING  t_table      = lt_data ).

        lo_salv->get_columns( )->set_optimize( abap_true ).
        lo_salv->get_functions( )->set_all( abap_true ).
        lo_salv->display( ).
      CATCH cx_salv_msg.
        MESSAGE 'Ошибка создания SALV-представления' TYPE 'S' DISPLAY LIKE 'E'.
    ENDTRY.
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
    DATA(ls_params) = get_params( ).
    DATA(lt_data) = mo_dao->select_data( is_params = ls_params ).
    mo_view->display( lt_data ).
  ENDMETHOD.
ENDCLASS.

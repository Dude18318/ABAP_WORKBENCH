*&---------------------------------------------------------------------*
*& Include Z_BP_SALV_LIGHT_CD01
*&---------------------------------------------------------------------*
INTERFACE lif_dao.
  METHODS select_data
    IMPORTING is_params      TYPE ty_s_params
    RETURNING VALUE(rt_data) TYPE ty_t_rows.
ENDINTERFACE.

CLASS lcl_dao DEFINITION.
  PUBLIC SECTION.
    INTERFACES lif_dao.
ENDCLASS.

CLASS lcl_view DEFINITION.
  PUBLIC SECTION.
    METHODS display
      IMPORTING it_data TYPE ty_t_rows.
ENDCLASS.

CLASS lcl_app DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS get_instance
      RETURNING VALUE(ro_instance) TYPE REF TO lcl_app.

    METHODS run.
  PRIVATE SECTION.
    CLASS-DATA go_instance TYPE REF TO lcl_app.
    DATA mo_dao  TYPE REF TO lif_dao.
    DATA mo_view TYPE REF TO lcl_view.

    METHODS constructor.
    METHODS get_params
      RETURNING VALUE(rs_params) TYPE ty_s_params.
ENDCLASS.

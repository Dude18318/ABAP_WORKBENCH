*&---------------------------------------------------------------------*
*& Include Z_BP_INTERACTIVE_ALV_CD01
*&---------------------------------------------------------------------*
INTERFACE lif_dao.
  METHODS select_data
    IMPORTING is_params      TYPE ty_s_params
    RETURNING VALUE(rt_data) TYPE ty_t_alv_rows.
ENDINTERFACE.

CLASS lcl_dao DEFINITION.
  PUBLIC SECTION.
    INTERFACES lif_dao.
ENDCLASS.

CLASS lcl_view DEFINITION.
  PUBLIC SECTION.
    METHODS display.
    METHODS pbo_0100.
    METHODS pai_0100.
  PRIVATE SECTION.
    DATA mo_container TYPE REF TO cl_gui_custom_container.
    DATA mo_grid      TYPE REF TO cl_gui_alv_grid.
    DATA mt_fcat      TYPE lvc_t_fcat.

    METHODS build_fieldcat.
    METHODS handle_toolbar
      FOR EVENT toolbar OF cl_gui_alv_grid
      IMPORTING e_object e_interactive.
    METHODS handle_user_command
      FOR EVENT user_command OF cl_gui_alv_grid
      IMPORTING e_ucomm.
ENDCLASS.

CLASS lcl_app DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS get_instance
      RETURNING VALUE(ro_instance) TYPE REF TO lcl_app.
    METHODS run.
    METHODS pbo_0100.
    METHODS pai_0100.
  PRIVATE SECTION.
    CLASS-DATA go_instance TYPE REF TO lcl_app.
    DATA mo_dao  TYPE REF TO lif_dao.
    DATA mo_view TYPE REF TO lcl_view.

    METHODS constructor.
    METHODS get_params
      RETURNING VALUE(rs_params) TYPE ty_s_params.
ENDCLASS.

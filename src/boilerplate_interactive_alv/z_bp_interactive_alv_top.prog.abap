*&---------------------------------------------------------------------*
*& Include Z_BP_INTERACTIVE_ALV_TOP
*&---------------------------------------------------------------------*
TYPE-POOLS: icon.

TYPES:
  ty_r_key1 TYPE RANGE OF char20,
  BEGIN OF ty_s_params,
    key1 TYPE ty_r_key1,
  END OF ty_s_params,
  BEGIN OF ty_s_alv_row,
    status     TYPE icon_d,
    key1       TYPE char20,
    text1      TYPE char60,
    amount     TYPE p LENGTH 8 DECIMALS 2,
    cell_color TYPE lvc_t_scol,
  END OF ty_s_alv_row,
  ty_t_alv_rows TYPE STANDARD TABLE OF ty_s_alv_row WITH EMPTY KEY.

CLASS lcl_app DEFINITION DEFERRED.
DATA go_app TYPE REF TO lcl_app.
DATA gt_alv_data TYPE ty_t_alv_rows.

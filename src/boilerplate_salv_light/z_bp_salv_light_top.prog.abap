*&---------------------------------------------------------------------*
*& Include Z_BP_SALV_LIGHT_TOP
*&---------------------------------------------------------------------*
TYPE-POOLS: icon.

TYPES:
  BEGIN OF ty_s_row,
    status TYPE icon_d,
    key1   TYPE char20,
    text1  TYPE char60,
    amount TYPE p LENGTH 8 DECIMALS 2,
  END OF ty_s_row,
  ty_t_rows TYPE STANDARD TABLE OF ty_s_row WITH EMPTY KEY,
  ty_r_key1 TYPE RANGE OF char20,
  BEGIN OF ty_s_params,
    key1 TYPE ty_r_key1,
  END OF ty_s_params.

CLASS lcl_app DEFINITION DEFERRED.

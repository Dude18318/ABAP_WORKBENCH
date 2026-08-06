*&---------------------------------------------------------------------*
*& Include Z_BP_INTERACTIVE_ALV_S01
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b_main WITH FRAME TITLE TEXT-b01.
  SELECT-OPTIONS s_key1 FOR sy-uname.
SELECTION-SCREEN END OF BLOCK b_main.

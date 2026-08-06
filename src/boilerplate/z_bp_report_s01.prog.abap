*&---------------------------------------------------------------------*
*&  Include           Z_BP_REPORT_S01
*&---------------------------------------------------------------------*
*& Экран выбора.
*& Параметры группируются через MODIF ID для динамического
*& управления видимостью в AT SELECTION-SCREEN OUTPUT.
*&---------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK b_main WITH FRAME TITLE TEXT-b01.
  SELECT-OPTIONS:
    s_key1 FOR sy-datum MODIF ID k1,       " Пример: фильтр по ключу 1
    s_key2 FOR sy-uname MODIF ID k2.       " Пример: фильтр по ключу 2
SELECTION-SCREEN END OF BLOCK b_main.

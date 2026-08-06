CLASS ZCL_READ_MULTIPLE_TEXTS DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES:
      BEGIN OF ty_s_head,
        object TYPE tdobject,
        name   TYPE tdobname,
        id     TYPE tdid,
        spras  TYPE spras,
      END OF ty_s_head .
    TYPES:
      ty_t_thead TYPE TABLE OF ty_s_head WITH EMPTY KEY .
    TYPES:
      BEGIN OF ty_s_text,
        object TYPE tdobject,
        name   TYPE tdobname,
        id     TYPE tdid,
        spras  TYPE spras,
        text   TYPE string,
      END OF ty_s_text .
    TYPES:
      ty_t_text TYPE SORTED TABLE OF ty_s_text WITH UNIQUE KEY object name id spras .

    DATA MT_TEXTS TYPE TY_T_TEXT READ-ONLY .

    METHODS CONSTRUCTOR
      IMPORTING
        !IT_THEAD TYPE TY_T_THEAD .
    METHODS READ_ANY
      RAISING
        ZCX_COMMON .
    METHODS READ_BY_LANGU
      RAISING
        ZCX_COMMON .
  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA MO_DAO TYPE REF TO ZIF_MASS_TEXTS_API_WRAP_DAO .
    DATA MS_PARAMETERS TYPE ZIF_MASS_TEXTS_API_WRAP_DAO=>TY_S_PARAMETERS .
    DATA MT_TEXT_H1 TYPE TEXT_LH .
    DATA MT_THEAD TYPE TY_T_THEAD .

    METHODS SET_DAO
      IMPORTING
        !IO_DAO TYPE REF TO ZIF_MASS_TEXTS_API_WRAP_DAO .
    METHODS FILL_OUTTAB .
    METHODS READ
      RAISING
        ZCX_COMMON .
    METHODS MAP_THEAD_TO_RANGE .
ENDCLASS.

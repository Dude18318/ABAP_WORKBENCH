class ZCL_BDC definition
  public
  create public .

public section.
  type-pools ABAP .

  data M_BDCDATA type BDCDATA_TAB .
  data M_GT_MESTAB type TAB_BDCMSGCOLL .
  data M_GT_BAPIRET type BAPIRETTAB .

  methods CONSTRUCTOR .
  methods BDC_DYNPRO
    importing
      value(I_PROGRAM) type CSEQUENCE
      value(I_DYNPRO) type CSEQUENCE
    returning
      value(R_RC) type I .
  methods BDC_FIELD
    importing
      value(I_FIELD) type CSEQUENCE
      value(I_VALUE) type ANY
    returning
      value(R_RC) type I .
  methods CALL_TRANSACTION
    importing
      value(I_TCODE) type CSEQUENCE
      value(I_DISMODE) type CTU_PARAMS-DISMODE default 'E'
      value(I_UPDMODE) type CTU_PARAMS-UPDMODE default 'S'
      value(IT_BDCDATA) type BDCDATA_TAB optional        "#EC CI_VALPAR
      value(IS_CTU_PARAMS) type CTU_PARAMS optional
    exporting
      value(ET_MESSAGES) type TAB_BDCMSGCOLL .           "#EC CI_VALPAR
  class-methods CURR_TO_CHAR
    importing
      value(I_AMOUNT) type ANY
      value(I_CURRENCY) type WAERS
    returning
      value(R_CHAR_AMOUNT) type CHAR32 .
  class-methods MENG_TO_CHAR
    importing
      value(I_MENGE) type MENGE_D
      value(I_MEINS) type MEINS
    returning
      value(R_CHAR_MENGE) type CHAR32 .
  class-methods BDCMSG_TO_BAPIRET
    importing
      value(IT_MESTAB) type TAB_BDCMSGCOLL               "#EC CI_VALPAR
    returning
      value(RT_BAPIRETURN) type BAPIRETTAB .             "#EC CI_VALPAR
  class-methods TO_NUMC
    importing
      value(INPUT) type C
    returning
      value(RV_OUTPUT) type CHAR256 .
  class-methods TRANSLATE_MESSAGE_TO_TEXT
    importing
      value(I_BDCMSGCOLL) type BDCMSGCOLL
    returning
      value(R_TEXT) type BAPI_MSG .                      "#EC CI_VALPAR
protected section.
private section.
ENDCLASS.

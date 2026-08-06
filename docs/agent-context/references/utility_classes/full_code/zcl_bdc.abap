class ZCL_BDC definition
  public
  create public .

*"* public components of class ZCL_BDC
*"* do not include other source files here!!!
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
*"* protected components of class ZCL_BDC
*"* do not include other source files here!!!
private section.
*"* private components of class ZCL_BDC
*"* do not include other source files here!!!
ENDCLASS.



CLASS ZCL_BDC IMPLEMENTATION.


METHOD bdcmsg_to_bapiret.
*...
  FIELD-SYMBOLS:
    <lv_mestab> TYPE LINE OF tab_bdcmsgcoll,
    <lv_bapiret> TYPE LINE OF bapirettab.
*
  LOOP AT it_mestab ASSIGNING <lv_mestab>.
    APPEND INITIAL LINE TO rt_bapireturn ASSIGNING <lv_bapiret>.
    <lv_bapiret>-type       = <lv_mestab>-msgtyp.
    <lv_bapiret>-id         = <lv_mestab>-msgid.
    <lv_bapiret>-number     = <lv_mestab>-msgnr.
    <lv_bapiret>-message    = translate_message_to_text( <lv_mestab> ).
    <lv_bapiret>-log_msg_no = <lv_mestab>-msgnr.
    <lv_bapiret>-message_v1 = <lv_mestab>-msgv1.
    <lv_bapiret>-message_v2 = <lv_mestab>-msgv2.
    <lv_bapiret>-message_v3 = <lv_mestab>-msgv3.
    <lv_bapiret>-message_v4 = <lv_mestab>-msgv4.
  ENDLOOP.

ENDMETHOD.  "#EC CI_VALPAR


METHOD bdc_dynpro.
* ...
  DATA: ls_bdcdata LIKE LINE OF me->m_bdcdata.
  ls_bdcdata-program  = i_program.
  ls_bdcdata-dynpro   = i_dynpro.
  ls_bdcdata-dynbegin = 'X'.
  APPEND ls_bdcdata TO m_bdcdata.
  IF sy-subrc = 0.
    r_rc = 0.
  ELSE.
    r_rc = 4.
  ENDIF.
ENDMETHOD.


METHOD bdc_field.
* ...
  DATA: ls_bdcdata LIKE LINE OF me->m_bdcdata.
  ls_bdcdata-fnam = i_field.
  TRANSLATE ls_bdcdata-fnam TO UPPER CASE.
  ls_bdcdata-fval = i_value.
  APPEND ls_bdcdata TO m_bdcdata.
  IF sy-subrc = 0.
    r_rc = 0.
  ELSE.
    r_rc = 4.
  ENDIF.
ENDMETHOD.


METHOD call_transaction.
* ...
      DATA lv_bdcmode_active TYPE flag.
    DATA lv_nobim_active TYPE flag.

  DATA: lv_bdcmode TYPE bdc_mode.
  DATA: lv_bdcmode_1 TYPE bdc_mode.
  DATA: lv_nobim_1 TYPE ctu_nobim.
  DATA: lv_dismode TYPE bdc_mode.
  DATA: ls_mestab TYPE bdcmsgcoll.
  DATA: lt_bdcdata TYPE bdcdata_tab.
  DATA ls_ctuparams TYPE ctu_params.
* authority-check for 'S_TCODE'
  REFRESH et_messages.
  AUTHORITY-CHECK OBJECT 'S_TCODE'
        ID 'TCD' FIELD i_tcode.
  IF sy-subrc NE 0.
    ls_mestab-tcode   = i_tcode.
    ls_mestab-msgtyp  = 'E'.
    ls_mestab-msgspra = sy-langu.
    ls_mestab-msgid   = 'S '.
    ls_mestab-msgnr   = '077'.
    ls_mestab-msgv1   = i_tcode.
    APPEND ls_mestab TO et_messages.
    EXIT.
  ENDIF.
* read user parameter 'ZM_BDCMODE'
  GET PARAMETER ID 'ZM_BDCMODE' FIELD lv_bdcmode.
  TRANSLATE lv_bdcmode TO UPPER CASE.
  IF is_ctu_params IS SUPPLIED.
    ls_ctuparams = is_ctu_params.
    IF ls_ctuparams-dismode NA 'AEN'.
      ls_ctuparams-dismode = 'N'.
    ENDIF.
  ELSE.
    IF lv_bdcmode CO 'AEN'.
      lv_dismode = lv_bdcmode.
    ELSEIF i_dismode NA 'AEN'.
      lv_dismode = 'N'.
    ELSE.
      lv_dismode = i_dismode.
    ENDIF.
  ENDIF.
*
  IF it_bdcdata IS SUPPLIED.
    lt_bdcdata[] = it_bdcdata[].
  ELSE.
    lt_bdcdata[] = me->m_bdcdata[].
  ENDIF.

"{3000013716 belousovai 28.09.2022 меню: Система - Постоянные значения пользователя - Собственные данные и на вкладке Параметры завести параметр ZM_BDCMODE1
"Для гарантированного переключения режима запуска батч-инпута
  GET PARAMETER ID 'ZM_BDCMODE_1' FIELD lv_bdcmode_1.
  IF sy-subrc EQ 0.
    lv_bdcmode_active = abap_true.
  ENDIF.

  GET PARAMETER ID 'ZM_NOBIM_1' FIELD lv_nobim_1.
  IF sy-subrc EQ 0.
    lv_nobim_active = abap_true.
  ENDIF.

  IF lv_nobim_active EQ abap_true OR lv_bdcmode_active EQ abap_true.
    ls_ctuparams = is_ctu_params.

    IF lv_nobim_active EQ abap_true.
      ls_ctuparams-nobinpt = lv_nobim_1.
    ENDIF.

    IF lv_bdcmode_active EQ abap_true.
      ls_ctuparams-dismode = lv_bdcmode_1.
    ENDIF.

    CALL TRANSACTION i_tcode USING lt_bdcdata            "#EC CI_CALLTA
             MESSAGES INTO et_messages
             OPTIONS FROM ls_ctuparams.

    RETURN.

  ENDIF.

"}3000013716 belousovai 28.09.2022

  IF is_ctu_params IS SUPPLIED.
    CALL TRANSACTION i_tcode USING lt_bdcdata            "#EC CI_CALLTA
                 MESSAGES INTO et_messages
                 OPTIONS FROM is_ctu_params.
  ELSE.
    CALL TRANSACTION i_tcode USING lt_bdcdata            "#EC CI_CALLTA
                     MODE   lv_dismode
                     UPDATE i_updmode
                     MESSAGES INTO et_messages.
  ENDIF.

ENDMETHOD.                                               "#EC CI_VALPAR


METHOD constructor.
  CLEAR m_gt_bapiret.
  REFRESH m_gt_bapiret[].
ENDMETHOD.


METHOD curr_to_char.
*...
  TYPES:
    BEGIN OF ty_abap_componentdescr,
    name       TYPE string,
    type       TYPE REF TO cl_abap_datadescr,
    as_include TYPE abap_bool,
    suffix     TYPE string,
  END OF ty_abap_componentdescr,
  ty_t_abap_component_tab TYPE STANDARD TABLE OF ty_abap_componentdescr
                     WITH KEY name.

  DATA:
    lv_lo_xref TYPE REF TO cx_root,
    lv_txt TYPE string.
  DATA:
    ls_comp TYPE abap_componentdescr,
    lv_char_amount TYPE char32,
    lv_typekind TYPE c,
    lv_length TYPE i,
    lv_decimals TYPE i.
  DATA:
    ls_currency_decimals TYPE bapi1090_1,
    lv_bapireturn TYPE bapireturn .

  CLEAR: r_char_amount.

  TRY.
      ls_comp-type ?= cl_abap_datadescr=>describe_by_data( i_amount ).

      lv_typekind = ls_comp-type->type_kind.
      lv_length = ls_comp-type->length.
      lv_decimals = ls_comp-type->decimals.

      IF lv_typekind = 'P'. " DEC
        " variant write i_amount to lv_char_amount currency i_currency ...
        " don't working if incoming amount has for example 4 decimal plases and
        " CURRENCY has 2 decimal plases
        "
        CALL FUNCTION 'BAPI_CURRENCY_GETDECIMALS'
          EXPORTING
            currency          = i_currency
          IMPORTING
            currency_decimals = ls_currency_decimals
            return            = lv_bapireturn.
        WRITE i_amount TO lv_char_amount NO-GROUPING LEFT-JUSTIFIED
                                         DECIMALS ls_currency_decimals-curdecimals.
        CONDENSE lv_char_amount.
        r_char_amount = lv_char_amount.
      ENDIF.

    CATCH cx_root INTO lv_lo_xref.
      lv_txt = lv_lo_xref->get_text( ).
      MESSAGE s000(zreuse) DISPLAY LIKE 'W' WITH lv_txt.
  ENDTRY.

ENDMETHOD.


METHOD meng_to_char.
*...
  TYPES:
    BEGIN OF ty_abap_componentdescr,
    name       TYPE string,
    type       TYPE REF TO cl_abap_datadescr,
    as_include TYPE abap_bool,
    suffix     TYPE string,
  END OF ty_abap_componentdescr,
  ty_t_abap_component_tab TYPE STANDARD TABLE OF ty_abap_componentdescr
                     WITH KEY name.

  DATA:
    lv_lo_xref TYPE REF TO cx_root,
    lv_txt TYPE string.
  DATA:
    ls_comp TYPE ty_abap_componentdescr,
    lv_char_menge TYPE char32,
    lv_typekind TYPE c,
    lv_length TYPE i,
    lv_decimals TYPE i.

  CLEAR: r_char_menge.

  TRY.
      ls_comp-type ?= cl_abap_datadescr=>describe_by_data( i_menge ).

      lv_typekind = ls_comp-type->type_kind.
      lv_length = ls_comp-type->length.
      lv_decimals = ls_comp-type->decimals.

      IF lv_typekind = 'P'. " DEC
        WRITE i_menge TO lv_char_menge NO-GROUPING LEFT-JUSTIFIED UNIT i_meins.
        CONDENSE lv_char_menge.
        r_char_menge = lv_char_menge.
      ENDIF.

    CATCH cx_root INTO lv_lo_xref.
      lv_txt = lv_lo_xref->get_text( ).
      MESSAGE s000(zreuse) DISPLAY LIKE 'W' WITH lv_txt.
  ENDTRY.

ENDMETHOD.


METHOD to_numc.
* ...
* E X A M P L E
* class zcl_tools definition load.
* str = zcl_tools=>to_numc( str ).
  DATA: lv_lo_descr_ref TYPE REF TO cl_abap_typedescr.
  DATA: lv_lo_data_ref TYPE REF TO data.
  FIELD-SYMBOLS: <lv_fs> TYPE any.
*
  lv_lo_descr_ref = cl_abap_typedescr=>describe_by_data( input ).
  CHECK lv_lo_descr_ref->type_kind = 'C'.
  ASSIGN input TO <lv_fs>.
  CONDENSE input.
  CHECK input CO ' 0123456789'.
*
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = input
    IMPORTING
      output = <lv_fs>.
  rv_output = <lv_fs>.
*

ENDMETHOD.


METHOD translate_message_to_text.
*...
  DATA: lv_text TYPE t100-text.
  DATA: lv_langu TYPE t100-sprsl.
  DATA: lv_msg_id TYPE  t100-arbgb.
  DATA: lv_msg_no TYPE t100-msgnr.
  DATA: lv_msg_var1 TYPE balm-msgv1.
  DATA: lv_msg_var2 TYPE balm-msgv2.
  DATA: lv_msg_var3 TYPE balm-msgv3.
  DATA: lv_msg_var4 TYPE balm-msgv4.
* ...
  IF i_bdcmsgcoll IS INITIAL.
    EXIT.
  ENDIF.
  SELECT SINGLE text FROM t100 INTO lv_text WHERE
         sprsl = sy-langu AND
         arbgb = i_bdcmsgcoll-msgid AND
         msgnr = i_bdcmsgcoll-msgnr.
  lv_langu = sy-langu.
  IF sy-subrc  NE 0 OR lv_text EQ space.
    SELECT SINGLE text FROM t100 INTO lv_text WHERE
         sprsl = 'R' AND
         arbgb = i_bdcmsgcoll-msgid AND
         msgnr = i_bdcmsgcoll-msgnr.
    lv_langu = 'R'.
    IF sy-subrc  NE 0 OR lv_text EQ space.
      SELECT SINGLE text FROM t100 INTO lv_text WHERE
         sprsl = 'E' AND
         arbgb = i_bdcmsgcoll-msgid AND
         msgnr = i_bdcmsgcoll-msgnr.
      lv_langu = 'E'.
    ENDIF.
  ENDIF.
  IF NOT sy-subrc IS INITIAL.
    EXIT.
  ENDIF.
* ...
  lv_msg_id   = i_bdcmsgcoll-msgid.
  lv_msg_no   = i_bdcmsgcoll-msgnr.
  lv_msg_var1 = i_bdcmsgcoll-msgv1.
  lv_msg_var2 = i_bdcmsgcoll-msgv2.
  lv_msg_var3 = i_bdcmsgcoll-msgv3.
  lv_msg_var4 = i_bdcmsgcoll-msgv4.
*
  CALL FUNCTION 'MESSAGE_PREPARE'
    EXPORTING
      language = lv_langu
      msg_id   = lv_msg_id
      msg_no   = lv_msg_no
      msg_var1 = lv_msg_var1
      msg_var2 = lv_msg_var2
      msg_var3 = lv_msg_var3
      msg_var4 = lv_msg_var4
    IMPORTING
      msg_text = r_text
    EXCEPTIONS
      OTHERS   = 0.

ENDMETHOD.                                               "#EC CI_VALPAR
ENDCLASS.

CLASS ZCL_TEXT_STATIC DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

PUBLIC SECTION.

  CLASS-METHODS ITF2TEXT
    IMPORTING
      !IT_ITF TYPE TLINETAB
    RETURNING
      VALUE(RV_TEXT) TYPE STRING .
  
  CLASS-METHODS TEXT2ITF
    IMPORTING
      !IV_TEXT TYPE SIMPLE
    RETURNING
      VALUE(RT_ITF) TYPE TLINETAB .
  
  CLASS-METHODS READ
    IMPORTING
      !IV_NAME TYPE SIMPLE
      !IV_OBJECT TYPE SIMPLE DEFAULT 'TEXT'
      !IV_ID TYPE SIMPLE DEFAULT 'ST'
      !IV_LANGUAGE TYPE SIMPLE DEFAULT SY-LANGU
    RETURNING
      VALUE(RV_TEXT) TYPE STRING .
  
  CLASS-METHODS SAVE
    IMPORTING
      !IV_OBJECT TYPE SIMPLE DEFAULT 'TEXT'
      !IV_ID TYPE SIMPLE DEFAULT 'ST'
      !IV_NAME TYPE SIMPLE
      !IV_LANGUAGE TYPE SIMPLE DEFAULT SY-LANGU
      !IV_TEXT TYPE SIMPLE
      !IV_DIRECT TYPE ABAP_BOOL DEFAULT ABAP_FALSE
      !IV_COMMIT TYPE ABAP_BOOL DEFAULT ABAP_FALSE
    RAISING
      ZCX_GENERIC .
  
  CLASS-METHODS DELETE
    IMPORTING
      !IV_NAME TYPE SIMPLE
      !IV_OBJECT TYPE SIMPLE DEFAULT 'TEXT'
      !IV_ID TYPE SIMPLE DEFAULT 'ST'
      !IV_LANGUAGE TYPE SIMPLE DEFAULT SY-LANGU
      !IV_COMMIT TYPE ABAP_BOOL DEFAULT ABAP_FALSE
    RAISING
      ZCX_GENERIC .
  
  CLASS-METHODS EXISTS
    IMPORTING
      !IV_NAME TYPE SIMPLE
      !IV_OBJECT TYPE SIMPLE DEFAULT 'TEXT'
      !IV_ID TYPE SIMPLE DEFAULT 'ST'
      !IV_LANGUAGE TYPE SIMPLE DEFAULT SY-LANGU
    RETURNING
      VALUE(RV_EXISTS) TYPE ABAP_BOOL .

PROTECTED SECTION.
PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_TEXT_STATIC IMPLEMENTATION.


  METHOD itf2text.

    DATA lt_stream TYPE string_table.

    CALL FUNCTION 'CONVERT_ITF_TO_STREAM_TEXT'
      EXPORTING
        lf           = 'X'
      IMPORTING
        stream_lines = lt_stream
      TABLES
        itf_text     = it_itf.

    DATA(lv_newline) = cl_abap_char_utilities=>newline.
    CONCATENATE LINES OF lt_stream INTO rv_text SEPARATED BY lv_newline.

  ENDMETHOD.


  METHOD read.

    DATA:
      lt_lines TYPE TABLE OF tline.

    CALL FUNCTION 'READ_TEXT'
      EXPORTING
        object                  = CONV tdobject( iv_object )
        id                      = CONV tdid( iv_id )
        name                    = CONV tdobname( iv_name )
        language                = CONV langu( iv_language )
      TABLES
        lines                   = lt_lines
      EXCEPTIONS
        id                      = 1
        language                = 2
        name                    = 3
        not_found               = 4
        object                  = 5
        reference_check         = 6
        wrong_access_to_archive = 7
        OTHERS                  = 8.
    IF lt_lines IS INITIAL.
      RETURN.
    ENDIF.

    rv_text = itf2text( lt_lines ).

  ENDMETHOD.


  METHOD save.

    DATA:
      lt_itf      TYPE tlinetab.

    " Проверка обязательных параметров
    IF iv_name IS INITIAL.
      zcx_generic=>raise( 'Name is required' ).
    ENDIF.

    lt_itf = text2itf( iv_text ).

    DATA(ls_thead) =
      VALUE thead(
        tdobject = iv_object
        tdname   = iv_name
        tdid     = iv_id
        tdspras  = iv_language ).

    CALL FUNCTION 'SAVE_TEXT'
      EXPORTING
        header          = ls_thead
        savemode_direct = iv_direct
      TABLES
        lines           = lt_itf
      EXCEPTIONS
        id              = 1
        language        = 2
        name            = 3
        object          = 4
        OTHERS          = 5.
    IF sy-subrc NE 0.
      zcx_generic=>raise( |Save error: { sy-subrc }| ).
    ENDIF.

    IF iv_commit EQ abap_true.

      CALL FUNCTION 'COMMIT_TEXT'
        EXPORTING
          object          = ls_thead-tdobject
          name            = ls_thead-tdname
          id              = ls_thead-tdid
          language        = ls_thead-tdspras
          savemode_direct = iv_direct.

      COMMIT WORK.

    ENDIF.

  ENDMETHOD.


  METHOD text2itf.

    DATA lt_stream TYPE string_table.

    DATA(lv_text) = CONV string( iv_text ).

    INSERT lv_text INTO TABLE lt_stream.

    CALL FUNCTION 'CONVERT_STREAM_TO_ITF_TEXT'
      EXPORTING
        stream_lines = lt_stream
        lf           = 'X'
      TABLES
        itf_text     = rt_itf.

  ENDMETHOD.


  METHOD delete.

    DATA ls_thead TYPE thead.

    ls_thead-tdobject = iv_object.
    ls_thead-tdname   = iv_name.
    ls_thead-tdid     = iv_id.
    ls_thead-tdspras  = iv_language.

    CALL FUNCTION 'DELETE_TEXT'
      EXPORTING
        header = ls_thead
      EXCEPTIONS
        OTHERS = 1.
    IF sy-subrc NE 0.
      zcx_generic=>raise( |Delete error: { sy-subrc }| ).
    ENDIF.

    IF iv_commit EQ abap_true.
      COMMIT WORK.
    ENDIF.

  ENDMETHOD.


  METHOD exists.

    DATA lt_lines TYPE TABLE OF tline.

    CALL FUNCTION 'READ_TEXT'
      EXPORTING
        object                  = CONV tdobject( iv_object )
        id                      = CONV tdid( iv_id )
        name                    = CONV tdobname( iv_name )
        language                = CONV langu( iv_language )
      TABLES
        lines                   = lt_lines
      EXCEPTIONS
        OTHERS                  = 1.

    rv_exists = COND #( WHEN sy-subrc = 0 AND lt_lines IS NOT INITIAL THEN ABAP_TRUE
                        ELSE ABAP_FALSE ).

  ENDMETHOD.
ENDCLASS.

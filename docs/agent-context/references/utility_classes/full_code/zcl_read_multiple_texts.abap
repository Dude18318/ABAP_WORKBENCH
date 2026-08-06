" Массовое чтение текстов 
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

CLASS ZCL_READ_MULTIPLE_TEXTS IMPLEMENTATION.

  METHOD constructor.
    mt_thead = it_thead.
  ENDMETHOD.

  METHOD fill_outtab.
    DATA lt_thead TYPE ty_t_thead.
    DATA lt_text_table TYPE TABLE OF text1000.

    SORT mt_text_h1 BY header-tdobject header-tdname header-tdid header-tdspras.
    LOOP AT mt_thead INTO DATA(ls_thead).
      IF line_exists( mt_texts[ id = ls_thead-id
                                name = ls_thead-name
                                object = ls_thead-object
                                spras = ls_thead-spras ] ).
        CONTINUE.
      ENDIF.

      DATA(lv_text) = VALUE string( ).
      READ TABLE mt_text_h1 INTO DATA(ls_text)
        WITH KEY header-tdobject = ls_thead-object
                 header-tdname   = ls_thead-name
                 header-tdid     = ls_thead-id
                 header-tdspras  = ls_thead-spras
        BINARY SEARCH.
      IF sy-subrc = 0.
        CALL FUNCTION 'CONVERT_ITF_TO_STREAM_TEXT'
          EXPORTING
            language    = ls_thead-spras
          TABLES
            itf_text    = ls_text-lines
            text_stream = lt_text_table.

        lv_text = REDUCE string( INIT lv_reduce TYPE string FOR <ls_row> IN lt_text_table
                                   NEXT lv_reduce = lv_reduce && <ls_row> ).
        REPLACE ALL OCCURRENCES OF cl_abap_char_utilities=>cr_lf IN lv_text WITH ` `.
      ENDIF.
      IF lv_text IS NOT INITIAL.
        INSERT VALUE #( id = ls_thead-id
                        name = ls_thead-name
                        object = ls_thead-object
                        spras = ls_thead-spras
                        text = lv_text ) INTO TABLE mt_texts.
        CLEAR lv_text.
      ELSEIF ls_thead-spras <> 'R'.
        ls_thead-spras = 'R' .
        INSERT ls_thead INTO TABLE lt_thead.
      ENDIF.
    ENDLOOP.

    mt_thead = lt_thead.
  ENDMETHOD.

  METHOD map_thead_to_range.
    CLEAR ms_parameters.

    LOOP AT mt_thead INTO DATA(ls_thead).
      IF NOT line_exists( ms_parameters-id_ranges[ low = ls_thead-id ] ).
        INSERT VALUE #( sign = 'I' option = 'EQ' low = ls_thead-id ) INTO TABLE ms_parameters-id_ranges.
      ENDIF.
      INSERT VALUE #( sign = 'I' option = 'EQ' low = ls_thead-name ) INTO TABLE ms_parameters-name_ranges.
      IF NOT line_exists( ms_parameters-object_ranges[ low = ls_thead-object ] ).
        INSERT VALUE #( sign = 'I' option = 'EQ' low = ls_thead-object ) INTO TABLE ms_parameters-object_ranges.
      ENDIF.
      IF NOT line_exists( ms_parameters-language_ranges[ low = ls_thead-spras ] ).
        INSERT VALUE #( sign = 'I' option = 'EQ' low = ls_thead-spras ) INTO TABLE ms_parameters-language_ranges.
      ENDIF.
    ENDLOOP.
    SORT ms_parameters-name_ranges BY low.
    DELETE ADJACENT DUPLICATES FROM ms_parameters-name_ranges COMPARING low.
  ENDMETHOD.

  METHOD read.
    map_thead_to_range( ).
    mt_text_h1 = mo_dao->read_multiple_texts( ms_parameters ).
    fill_outtab( ).
  ENDMETHOD.

  METHOD read_any.
    set_dao( NEW lcl_dao( ) ).
    read( ).
    IF mt_thead IS NOT INITIAL.
      read( ).
    ENDIF.
  ENDMETHOD.

  METHOD READ_BY_LANGU.
    set_dao( NEW lcl_dao( ) ).
    read( ).
  ENDMETHOD.

  METHOD SET_DAO.
    IF mo_dao IS NOT BOUND.
      mo_dao = io_dao.
    ENDIF.
  ENDMETHOD.
ENDCLASS.

*"* use this source file for any type of declarations (class
*"* definitions, interfaces or type declarations) you need for
*"* components in the private section
CLASS lcl_dao DEFINITION.
  PUBLIC SECTION.
    INTERFACES: zif_mass_texts_api_wrap_dao.
    ALIASES:
    read_multiple_texts FOR zif_mass_texts_api_wrap_dao~read_multiple_texts.
ENDCLASS.

*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations
CLASS lcl_dao IMPLEMENTATION.
  METHOD read_multiple_texts.
    CONSTANTS: lc_range_size TYPE i VALUE 4000.
    DATA: lr_name_pack  TYPE tspsrname,
          lt_texts_pack TYPE text_lh.

    CHECK is_parameters IS NOT INITIAL.

    DATA(lv_lines) = lines( is_parameters-name_ranges ).
    DATA(lv_from) = 1.
    DATA(lv_to) = COND #( WHEN lv_lines > lc_range_size THEN lc_range_size ELSE lv_lines ).

    WHILE lv_to <= lv_lines.
      CLEAR: lr_name_pack, lt_texts_pack.
      INSERT LINES OF is_parameters-name_ranges FROM lv_from TO lv_to INTO TABLE lr_name_pack.

      CALL FUNCTION 'READ_MULTIPLE_TEXTS'
        EXPORTING
          name_ranges             = lr_name_pack
          object_ranges           = is_parameters-object_ranges
          id_ranges               = is_parameters-id_ranges
          language_ranges         = is_parameters-language_ranges
        IMPORTING
          text_table              = lt_texts_pack
        EXCEPTIONS
          wrong_access_to_archive = 1
          OTHERS                  = 2.
      IF sy-subrc <> 0.
        zcl_ex_helper=>raise_symsg( ).
      ENDIF.

      INSERT LINES OF lt_texts_pack INTO TABLE rt_result.

      IF lv_to = lv_lines.
        EXIT.
      ENDIF.
      lv_from = lv_to + 1.
      lv_to = lv_from + lc_range_size.
      IF lv_to > lv_lines.
        lv_to = lv_lines.
      ENDIF.
    ENDWHILE.
  ENDMETHOD.
ENDCLASS.

*"* use this source file for your ABAP unit test classes
CLASS ltc_read_multiple_texts DEFINITION DEFERRED.
CLASS zcl_read_multiple_texts DEFINITION LOCAL FRIENDS ltc_read_multiple_texts.
CLASS ltc_read_multiple_texts DEFINITION FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
.
  PRIVATE SECTION.
    DATA:
     mo_cut TYPE REF TO zcl_read_multiple_texts.

    CLASS-METHODS: class_setup.
    CLASS-METHODS: class_teardown.
    METHODS: setup.
    METHODS: teardown.
    METHODS: select_1 FOR TESTING RAISING zcx_common.
    METHODS: select_2 FOR TESTING RAISING zcx_common.
ENDCLASS.

CLASS ltc_read_multiple_texts IMPLEMENTATION.
  METHOD class_setup.
  ENDMETHOD.
  METHOD class_teardown.
  ENDMETHOD.
  METHOD setup.
  ENDMETHOD.
  METHOD teardown.
  ENDMETHOD.
  METHOD select_1.
    DATA lo_dao TYPE REF TO zif_mass_texts_api_wrap_dao.
    DATA lt_expected TYPE zcl_read_multiple_texts=>ty_t_text.

    "given
    lo_dao ?= cl_abap_testdouble=>create( object_name = 'ZIF_MASS_TEXTS_API_WRAP_DAO' ).
    DATA(lt_thead) = VALUE zcl_read_multiple_texts=>ty_t_thead(
          (
                 object = 'EBAN'
                 name = '001000005100010'
                 id = 'B01'
                 spras = 'R'
                 )
         (
                 object = 'EBAN'
                 name = '001000005100010'
                 id = 'B07'
                 spras = 'R'
                 )
         (
                 object = 'MATERIAL'
                 name = '001000005100010'
                 id = 'GRUN'
                 spras = 'R'
                 )
         ).

    DATA(ls_parameters) = VALUE zif_mass_texts_api_wrap_dao=>ty_s_parameters(
             name_ranges = VALUE #(
                     (
                             sign = 'I'
                             option = 'EQ'
                             low = '001000005100010'
                             )
                     )
             object_ranges = VALUE #(
                     (
                             sign = 'I'
                             option = 'EQ'
                             low = 'EBAN'
                             )
                     (
                             sign = 'I'
                             option = 'EQ'
                             low = 'MATERIAL'
                             )
                     )
             id_ranges = VALUE #(
                     (
                             sign = 'I'
                             option = 'EQ'
                             low = 'B01'
                             )
                     (
                             sign = 'I'
                             option = 'EQ'
                             low = 'B07'
                             )
                     (
                             sign = 'I'
                             option = 'EQ'
                             low = 'GRUN'
                             )
                     )
             language_ranges = VALUE #(
                     (
                             sign = 'I'
                             option = 'EQ'
                             low = 'R'
                             )
                     )
             ).

    DATA(lt_text) = VALUE text_lh(   (
                     header = VALUE #(
                             tdobject = 'EBAN'
                             tdname = '001000005100010'
                             tdid = 'B01'
                             tdspras = 'R'
                             tdform = 'SYSTEM'
                             tdfuser = 'MORKOVINANA'
                             tdfreles = '740'
                             tdfdate = '20180911'
                             tdftime = '171407'
                             tdluser = 'MORKOVINANA'
                             tdlreles = '740'
                             tdldate = '20180911'
                             tdltime = '171706'
                             tdlinesize = '072'
                             tdtxtlines = '00001'
                             mandt = '060'
                             )
                     lines = VALUE #(
                             (
                                     tdformat = '*'
                                     tdline = '5555555'
                                     )
                                                           (
                                     tdformat = '*'
                                     tdline = '666'
                                     )
                             )
                     )
             ).

    cl_abap_testdouble=>configure_call( lo_dao
    )->set_parameter( name = 'is_parameters' value = ls_parameters
    )->returning( lt_text ).
    lo_dao->read_multiple_texts( ls_parameters ).

    mo_cut = NEW #( lt_thead ).
    mo_cut->set_dao( lo_dao ).

    lt_expected = VALUE #( ( object = 'EBAN'
                             name = '001000005100010'
                             id = 'B01'
                             spras = 'R'
                             text = `5555555 666` ) ).
    "when
    mo_cut->read_any( ).

    "then
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->mt_texts
      exp = lt_expected ).
  ENDMETHOD.
  METHOD select_2.
    DATA lo_dao TYPE REF TO zif_mass_texts_api_wrap_dao.
    DATA lt_expected TYPE zcl_read_multiple_texts=>ty_t_text.

    "given
    lo_dao ?= cl_abap_testdouble=>create( object_name = 'ZIF_MASS_TEXTS_API_WRAP_DAO' ).
    DATA(lt_thead) = VALUE zcl_read_multiple_texts=>ty_t_thead(
          (
                 object = 'EBAN'
                 name = '001000005100010'
                 id = 'B01'
                 spras = 'E'
                 )
         (
                 object = 'EBAN'
                 name = '001000005100010'
                 id = 'B07'
                 spras = 'E'
                 )
         (
                 object = 'MATERIAL'
                 name = '001000005100010'
                 id = 'GRUN'
                 spras = 'E'
                 )
         ).

    DATA(ls_parameters) = VALUE zif_mass_texts_api_wrap_dao=>ty_s_parameters(
             name_ranges = VALUE #(
                     (
                             sign = 'I'
                             option = 'EQ'
                             low = '001000005100010'
                             )
                     )
             object_ranges = VALUE #(
                     (
                             sign = 'I'
                             option = 'EQ'
                             low = 'EBAN'
                             )
                     (
                             sign = 'I'
                             option = 'EQ'
                             low = 'MATERIAL'
                             )
                     )
             id_ranges = VALUE #(
                     (
                             sign = 'I'
                             option = 'EQ'
                             low = 'B01'
                             )
                     (
                             sign = 'I'
                             option = 'EQ'
                             low = 'B07'
                             )
                     (
                             sign = 'I'
                             option = 'EQ'
                             low = 'GRUN'
                             )
                     )
             language_ranges = VALUE #(
                     (
                             sign = 'I'
                             option = 'EQ'
                             low = 'R'
                             )
                     )
             ).

    DATA(lt_text) = VALUE text_lh(   (
                     header = VALUE #(
                             tdobject = 'EBAN'
                             tdname = '001000005100010'
                             tdid = 'B01'
                             tdspras = 'R'
                             tdform = 'SYSTEM'
                             tdfuser = 'MORKOVINANA'
                             tdfreles = '740'
                             tdfdate = '20180911'
                             tdftime = '171407'
                             tdluser = 'MORKOVINANA'
                             tdlreles = '740'
                             tdldate = '20180911'
                             tdltime = '171706'
                             tdlinesize = '072'
                             tdtxtlines = '00001'
                             mandt = '060'
                             )
                     lines = VALUE #(
                             (
                                     tdformat = '*'
                                     tdline = '5555555'
                                     )
                                                           (
                                     tdformat = '*'
                                     tdline = '666'
                                     )
                             )
                     )
             ).

    cl_abap_testdouble=>configure_call( lo_dao
    )->set_parameter( name = 'is_parameters' value = ls_parameters
    )->returning( lt_text ).
    lo_dao->read_multiple_texts( ls_parameters ).

    mo_cut = NEW #( lt_thead ).
    mo_cut->set_dao( lo_dao ).

    lt_expected = VALUE #( ( object = 'EBAN'
                             name = '001000005100010'
                             id = 'B01'
                             spras = 'R'
                             text = `5555555 666` ) ).
    "when
    mo_cut->read_any( ).

    "then
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->mt_texts
      exp = lt_expected ).
  ENDMETHOD.
ENDCLASS.

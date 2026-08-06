class ZCL_SD_LONG_TEXT_EDITOR definition
  public
  create public .

public section.

  data MO_TEXTEDIT type ref to CL_GUI_TEXTEDIT .
  data MV_MULTI_LINGU type XFELD .

  methods CONSTRUCTOR
    importing
      !IS_THEAD type THEAD
      !IV_CAPTION type C optional
      !IO_PARENT type ref to CL_GUI_CONTAINER optional .
  methods SHOW
    importing
      value(IV_SHOW_BUTTONS) type ABAP_BOOL default ABAP_TRUE
      value(IV_TITLE) type STRING optional
      value(IS_THEAD) type THEAD optional
      !IT_TEXT type WCB_TDLINE_TAB optional
      !IV_READ_BY_ALL_LANG type ABAP_BOOL optional .
  methods SAVE .
  methods GET_TEXT
    returning
      value(RT_TEXT) type LOP_TDLINE_TAB .
protected section.

  data MS_THEAD type THEAD .
  data MO_CONTAINER type ref to CL_GUI_DIALOGBOX_CONTAINER .
  data M_CAPTION type CHAR30 .
  data MO_PARENT type ref to CL_GUI_CONTAINER .

  methods ON_TOOLBAR_FUNC_SEL
    for event FUNCTION_SELECTED of CL_GUI_TOOLBAR
    importing
      !FCODE .
  methods FREE .
private section.
ENDCLASS.



CLASS ZCL_SD_LONG_TEXT_EDITOR IMPLEMENTATION.


  METHOD constructor.
    " 3000004678
    me->ms_thead   = is_thead.
    me->m_caption  = iv_caption.
*{3000004917
    me->mo_parent  = io_parent.
*3000004917}
  ENDMETHOD.


METHOD free.
  " 3000004678
  IF me->mo_parent IS INITIAL. "{3000004917}
    me->mo_textedit->free( ).
    me->mo_container->free( ).
  ENDIF. "{3000004917}
ENDMETHOD.


  METHOD get_text.
    " 3000004917
    IF mo_textedit IS BOUND.
      CALL METHOD mo_textedit->get_text_as_stream
        IMPORTING
          text = rt_text.
    ENDIF.
  ENDMETHOD.


  METHOD on_toolbar_func_sel.
    " 3000004678
    CASE fcode.
      WHEN 'SAVE'.
        me->save( ).
        MESSAGE i605(01). "Data saved
        me->free( ).
      WHEN 'CLOSE'.
        me->free( ).
    ENDCASE.
  ENDMETHOD.


METHOD save.
  " 3000004678
  DATA: lt_text      TYPE STANDARD TABLE OF tdline,
        lt_lines     TYPE STANDARD TABLE OF tline,
        ls_lines     TYPE tline,
        lv_p2        TYPE tdline,
        lv_text_temp TYPE tdline,
        lv_line_temp TYPE tdline,
        lv_splitted  TYPE char1.

  CONSTANTS: lc_kna           TYPE tdobject VALUE 'KNA1',
             lc_text          TYPE tdobject VALUE 'TEXT',
             lc_tdid_standart TYPE tdobject VALUE 'ST',
             lc_verm          TYPE tdid VALUE 'VERM', "3000018874 sibgatulli30 05/11/2024
             lc_charge        TYPE tdobject VALUE 'CHARGE'"3000018874 sibgatulli30 05/11/2024
             .

  FIELD-SYMBOLS: <lv_text> TYPE tdline.
  CALL METHOD me->mo_textedit->get_text_as_stream
    IMPORTING
      text = lt_text.
  LOOP AT lt_text ASSIGNING <lv_text>.
    AT FIRST. ls_lines-tdformat = '*'. ENDAT.
    lv_p2 = <lv_text>.
    DO.
      CLEAR lv_splitted.
      SPLIT lv_p2 AT cl_abap_char_utilities=>cr_lf
                      INTO lv_text_temp lv_p2.
      IF NOT lv_p2 IS INITIAL.
        lv_splitted = 'X'.
      ENDIF.
      CONCATENATE lv_line_temp lv_text_temp INTO lv_line_temp.
      IF sy-subrc NE 0.
        APPEND ls_lines TO lt_lines.
        CLEAR ls_lines.
        lv_line_temp = lv_text_temp.
      ENDIF.
      ls_lines-tdline = lv_line_temp.
      IF lv_splitted = 'X'.
        APPEND ls_lines TO lt_lines.
        CLEAR lv_line_temp.
        ls_lines-tdformat = '/'.
      ENDIF.
      IF lv_p2 IS INITIAL. EXIT. ENDIF.
    ENDDO.
    AT LAST.
      ls_lines-tdline = lv_line_temp.
      APPEND ls_lines TO lt_lines.
    ENDAT.
  ENDLOOP. "LOOP AT t_text

  DATA(lv_text_len) = REDUCE i( INIT lv_len TYPE i FOR ls_line IN lt_lines
                                  NEXT lv_len = lv_len + strlen( ls_line-tdline ) ).

  IF me->ms_thead-tdid = zcl_tvarvc=>get_const( 'ZCONST_SD_2003_COMM' ) AND me->ms_thead-tdobject = lc_kna.
    IF lv_text_len > zcl_tvarvc=>get_const( 'ZCONST_2003_MAX_SYMBOL_TEXT3' ).
      MESSAGE e098(zsd_sh_order) WITH zcl_tvarvc=>get_const( 'ZCONST_2003_MAX_SYMBOL_TEXT3' ).
    ENDIF.
  ENDIF.

  IF me->ms_thead-tdid = lc_tdid_standart AND me->ms_thead-tdobject = lc_text.
    IF lv_text_len > zcl_tvarvc=>get_const( 'ZCONST_2003_MAX_SYMBOL_TEXT2' ).
      MESSAGE e097(zsd_sh_order) WITH zcl_tvarvc=>get_const( 'ZCONST_2003_MAX_SYMBOL_TEXT2' ).
    ENDIF.
  ENDIF.

  CALL FUNCTION 'SAVE_TEXT'
    EXPORTING
      header          = me->ms_thead
      savemode_direct = 'X'
    TABLES
      lines           = lt_lines.
*{    APPOLINAROV1 Наряд 3000017007 08.02.2024
  NEW zcl_sd_save_long_text_cd( )->save_cd(
                                              is_thead = me->ms_thead
                                              it_lines = lt_lines
                                          ).
*} 3000017007
  DATA(ls_thead) = me->ms_thead.
  IF mv_multi_lingu = abap_true OR
    ( lt_lines IS INITIAL AND ls_thead-tdobject = lc_charge AND ls_thead-tdid = lc_verm ). "3000018874 sibgatulli30 05/11/2024

    ls_thead-tdspras = COND #( WHEN me->ms_thead-tdspras = 'R' THEN 'E' ELSE 'R' ) .
    CALL FUNCTION 'SAVE_TEXT'
      EXPORTING
        header          = ls_thead
        savemode_direct = 'X'
      TABLES
        lines           = lt_lines.
*{    APPOLINAROV1 Наряд 3000017007 08.02.2024
    NEW zcl_sd_save_long_text_cd( )->save_cd(
                                            is_thead = ls_thead
                                            it_lines = lt_lines
                                        ).
*} 3000017007
  ENDIF.

ENDMETHOD.


METHOD show.
  " 3000004678
  " 3000004917
  DATA:
    lo_splitter        TYPE REF TO cl_gui_easy_splitter_container,
    lo_splitter2       TYPE REF TO cl_gui_easy_splitter_container,
    lo_toolbar         TYPE REF TO cl_gui_toolbar,
    lt_text            TYPE STANDARD TABLE OF tdline,
    ls_event           TYPE cntl_simple_event,
    lt_events          TYPE cntl_simple_events,
    lt_lines           TYPE STANDARD TABLE OF tline,
    lv_text            TYPE tdline,
    lv_text_temp       TYPE tdline,
    lv_line_temp       TYPE tdline,
    lv_button_text(40) TYPE c,
    lo_document        TYPE REF TO cl_dd_document.
  FIELD-SYMBOLS:
    <ls_line>      TYPE tline.
  IF is_thead IS SUPPLIED.
    me->ms_thead   = is_thead.
  ENDIF.
  "-- begin 21.09.2021 15:49:40 - shustikov 3000012004
  mv_multi_lingu = iv_read_by_all_lang.
  "-- end 21.09.2021 15:49:40

  IF me->mo_textedit IS NOT BOUND.
    IF me->mo_parent IS NOT INITIAL.
      CREATE OBJECT lo_splitter
        EXPORTING
          parent        = me->mo_parent
          orientation   = lo_splitter->orientation_vertical
          sash_position = 20. "percentage for upper container
    ELSE.
*------ containers
      CREATE OBJECT me->mo_container
        EXPORTING
          top     = 50
          left    = 200
          height  = 150
          width   = 500
          caption = me->m_caption.
      CREATE OBJECT lo_splitter
        EXPORTING
          parent        = me->mo_container
          orientation   = lo_splitter->orientation_vertical
          sash_position = 20. "percentage for upper container
    ENDIF.
    IF iv_show_buttons = abap_true.
* toolbar
      IF me->mo_parent IS INITIAL.
        CREATE OBJECT lo_toolbar
          EXPORTING
            parent = lo_splitter->top_left_container.
        lv_button_text = TEXT-001.
        lo_toolbar->add_button(
          fcode     = 'SAVE'
          icon      = icon_system_save
          butn_type = cntb_btype_button
          text      = lv_button_text ).
        lv_button_text = TEXT-002.
        lo_toolbar->add_button(
          fcode     = 'CLOSE'
          icon      = icon_close
          butn_type = cntb_btype_button
          text      = lv_button_text ).
      ELSE.
        CREATE OBJECT lo_splitter2
          EXPORTING
            parent        = lo_splitter->top_left_container
            orientation   = lo_splitter->orientation_horizontal
            sash_position = 20. "percentage for right container
        CREATE OBJECT lo_toolbar
          EXPORTING
            parent = lo_splitter2->top_left_container.
        lv_button_text = TEXT-001.
        lo_toolbar->add_button(
          fcode     = 'SAVE'
          icon      = icon_system_save
          butn_type = cntb_btype_button
          text      = lv_button_text ).
        IF iv_title IS SUPPLIED.
          CREATE OBJECT lo_document.
          CALL METHOD lo_document->add_text
            EXPORTING
              text = CONV #( iv_title ).
          CALL METHOD lo_document->display_document
            EXPORTING
              parent = lo_splitter2->bottom_right_container.
        ENDIF.
      ENDIF.
* register toolbar events
      REFRESH lt_events.
      ls_event-eventid =
               cl_gui_toolbar=>m_id_function_selected.
      ls_event-appl_event = 'X'.
      APPEND ls_event TO lt_events.
      CALL METHOD lo_toolbar->set_registered_events( lt_events ).
      SET HANDLER:
         me->on_toolbar_func_sel FOR lo_toolbar.
    ELSE.
      IF iv_title IS SUPPLIED.
        CREATE OBJECT lo_document.
        CALL METHOD lo_document->add_text
          EXPORTING
            text = CONV #( iv_title ).
        CALL METHOD lo_document->display_document
          EXPORTING
            parent = lo_splitter->top_left_container.
      ENDIF.
    ENDIF.
* create textedit control
    CREATE OBJECT me->mo_textedit
      EXPORTING
        parent = lo_splitter->bottom_right_container.
* TO HIDE THE TOOLBAR
    CALL METHOD me->mo_textedit->set_toolbar_mode
      EXPORTING
        toolbar_mode           = 0
      EXCEPTIONS
        error_cntl_call_method = 0
        invalid_parameter      = 0
        OTHERS                 = 0.
*    IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
* WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*    ENDIF.
* TO HIDE THE STATUS BAR
    CALL METHOD me->mo_textedit->set_statusbar_mode
      EXPORTING
        statusbar_mode         = 0
      EXCEPTIONS
        error_cntl_call_method = 0
        invalid_parameter      = 0
        OTHERS                 = 0.
*    IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
* WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*    ENDIF.
  ENDIF.

* get text

*{ 3000008301
  IF it_text IS NOT INITIAL.
    APPEND LINES OF it_text TO lt_text.
  ELSE.
*} 3000008301

    CALL FUNCTION 'READ_TEXT'
      EXPORTING
        id       = me->ms_thead-tdid
        language = me->ms_thead-tdspras
        name     = me->ms_thead-tdname
        object   = me->ms_thead-tdobject
      TABLES
        lines    = lt_lines
      EXCEPTIONS
        OTHERS   = 0.
*  IF sy-subrc NE 0. EXIT. ENDIF.
*------- convert text to text editor format
    LOOP AT lt_lines ASSIGNING <ls_line>.
*   normal line
      IF <ls_line>-tdformat = space OR
         <ls_line>-tdformat = '=' OR
               sy-tabix = 1.
        lv_line_temp = <ls_line>-tdline.
        CONCATENATE lv_text lv_line_temp INTO lv_text_temp.
*   line with break
      ELSE.
        CONCATENATE:
          cl_abap_char_utilities=>cr_lf <ls_line>-tdline
                                INTO lv_line_temp,
          lv_text lv_line_temp INTO lv_text_temp.
      ENDIF.
      IF sy-subrc = 0.
        lv_text = lv_text_temp.
      ELSE.
        APPEND lv_text TO lt_text.
        lv_text = lv_line_temp.
      ENDIF.
    ENDLOOP.
    IF sy-subrc = 0.
      APPEND lv_text TO lt_text.
    ENDIF.

  ENDIF. " 3000008301
  "-- begin 16.09.2021 20:10:49 - shustikov  3000012004
  IF iv_read_by_all_lang = abap_true AND lt_text IS INITIAL.
    CALL FUNCTION 'READ_TEXT'
      EXPORTING
        id       = me->ms_thead-tdid
        language = COND #( WHEN me->ms_thead-tdspras = 'R' THEN 'E' ELSE 'R' )
        name     = me->ms_thead-tdname
        object   = me->ms_thead-tdobject
      TABLES
        lines    = lt_lines
      EXCEPTIONS
        OTHERS   = 0.
*  IF sy-subrc NE 0. EXIT. ENDIF.
*------- convert text to text editor format
    LOOP AT lt_lines ASSIGNING <ls_line>.
*   normal line
      IF <ls_line>-tdformat = space OR
         <ls_line>-tdformat = '=' OR
               sy-tabix = 1.
        lv_line_temp = <ls_line>-tdline.
        CONCATENATE lv_text lv_line_temp INTO lv_text_temp.
*   line with break
      ELSE.
        CONCATENATE:
          cl_abap_char_utilities=>cr_lf <ls_line>-tdline
                                INTO lv_line_temp,
          lv_text lv_line_temp INTO lv_text_temp.
      ENDIF.
      IF sy-subrc = 0.
        lv_text = lv_text_temp.
      ELSE.
        APPEND lv_text TO lt_text.
        lv_text = lv_line_temp.
      ENDIF.
    ENDLOOP.
    IF sy-subrc = 0.
      APPEND lv_text TO lt_text.
    ENDIF.

  ENDIF.
  "-- end 16.09.2021 20:10:49
* display text
  me->mo_textedit->set_text_as_stream( EXPORTING text = lt_text ).
  cl_gui_cfw=>flush( ).
ENDMETHOD. "#EC CI_VALPAR
ENDCLASS.

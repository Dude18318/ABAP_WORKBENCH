class ZCL_REUSE_MAILER definition
  public
  create public .

public section.
*"* public components of class ZCL_REUSE_MAILER
*"* do not include other source files here!!!
  type-pools ABAP .

  constants GC_TYPE_TABLE type CHAR1 value 'h' ##NO_TEXT.
  constants M_GC_NEWLINE_MAIL type CHAR3 value '%0A' ##NO_TEXT.
  constants M_GC_SPACE_MAIL type CHAR3 value '%20' ##NO_TEXT.
  constants M_GC_COMMAND type CHAR8 value 'Command=' ##NO_TEXT.
  constants M_GC_COMMAND_SKIP type CHAR9 value 'Command=*' ##NO_TEXT.
  data M_GO_SEND_REQUEST type ref to CL_BCS .
  data M_GO_DOCUMENT type ref to CL_DOCUMENT_BCS .
  data M_GO_SENDER type ref to CL_SAPUSER_BCS .
  data M_GO_RECIPIENT type ref to IF_RECIPIENT_BCS .
  data M_GT_ATTACHMENTS type RMPS_T_POST_CONTENT .
  class-data M_GT_TEXT type SOLI_TAB .
  data M_GT_SOLI_TAB type SOLI_TAB .
  data M_GT_SOLIX_TAB type SOLIX_TAB .
  data M_GV_SIZE type SOOD-OBJLEN .

  methods CONSTRUCTOR
    importing
      value(IV_SUBJECT) type SO_OBJ_DES optional
      !IV_TYPOBJ type SO_OBJ_TP default 'HTM'
      !IT_TEXT type SOLI_TAB optional .
  methods SET_SUBJECT_AND_BODY_TEXT
    importing
      value(IV_SUBJECT) type SO_OBJ_DES optional
      !IV_TYPOBJ type SO_OBJ_TP default 'HTM'
      !IT_TEXT type SOLI_TAB optional .
  methods SET_MESSAGE_SUBJECT
    importing
      value(IV_SUBJECT) type STRING .
  methods ADD_ATTACHMENT
    importing
      value(IV_ATTACHMENT_TYPE) type SOODK-OBJTP
      value(IV_ATTACHMENT_SUBJECT) type SOOD-OBJDES
      value(IV_ATTACHMENT_SIZE) type SOOD-OBJLEN optional
      value(IV_ATTACHMENT_LANGUAGE) type SOOD-OBJLA default SPACE
      value(IT_ATT_CONTENT_TEXT) type SOLI_TAB optional
      value(IT_ATT_CONTENT_HEX) type SOLIX_TAB optional
      value(IT_ATTACHMENT_HEADER) type SOLI_TAB optional .
  methods ADD_RECIPIENT_MAIL
    importing
      value(IV_RECIPIENT_MAIL) type STRING
      value(IV_INCL_SAPUSER) type OS_BOOLEAN optional
      value(IV_COPY) type OS_BOOLEAN optional .
  methods ADD_RECIPIENT_UID
    importing
      value(IV_RECIPIENT_UID) type STRING
      !IV_EXPRESS type OS_BOOLEAN default ABAP_TRUE .
  methods ADD_RECIPIENT_LIST
    importing
      !IV_RECIPIENT_LIST_NAME type STRING .
  methods SEND
    importing
      !IV_WITH_ERROR_SCREEN type OS_BOOLEAN default SPACE
      !IV_COMMIT_WORK type XFELD default SPACE
    returning
      value(RV_RESULT) type OS_BOOLEAN .
  class-methods XSTRING_TO_SOLIX
    importing
      !IV_XSTRING type XSTRING
    returning
      value(RT_SOLIX) type SOLIX_TAB .
  class-methods STRING_TO_SOLI
    importing
      !IV_STRING type STRING
    returning
      value(RT_SOLI) type SOLI_TAB .
  class-methods COUNT_DOC_SIZE
    importing
      !IT_TEXT type SOLI_TAB optional
      !IT_HEX type SOLIX_TAB optional
    returning
      value(RV_RESULT) type SO_OBJ_LEN .
  class-methods FIELD_AS_HYPERLINK
    importing
      !IV_NAME_ATTACH type SO_OBJ_DES
      !IV_ATTACH_TYPE type SO_OBJ_TP default 'SAP'
    changing
      !CV_FIELD type STRING .
  class-methods CONV_TABLE_TO_HTML
    importing
      !IT_HEADER type Z_TREUSE_TABLE_PROP optional
      !IT_TABLE type ANY TABLE
      !IS_TAB_PROP type ZSPROP_HTML_TAB
      !IV_COLOR_FIELD type FIELDNAME optional
    returning
      value(RT_TABLE_HTML) type SOLI_TAB .
  class-methods CREATE_SHORTCUT
    importing
      value(IV_TRANSACTION) type TCODE optional "#EC CI_VALPAR
      value(IV_REPORT) type PROGRAMM optional "#EC CI_VALPAR
      value(IV_SYSTEM_COMMAND) type CHAR40 optional "#EC CI_VALPAR
      value(IV_PARAMETER) type TEXT255 optional "#EC CI_VALPAR
      value(IV_SAPLOGON_ID) type CHAR50 optional "#EC CI_VALPAR
      value(IV_SYSID) type SYSYSID default SY-SYSID "#EC CI_VALPAR
      value(IV_GUIPARM) type CHAR80 optional "#EC CI_VALPAR
      value(IV_CLIENT) type SYMANDT default SY-MANDT "#EC CI_VALPAR
      value(IV_USER) type SYUNAME default SY-UNAME "#EC CI_VALPAR
      value(IV_LANGUAGE) type SYLANGU default SY-LANGU "#EC CI_VALPAR
      value(IV_WINDOWSIZE) type CHAR40 default 'Maximized' "#EC CI_VALPAR
      value(IV_TITLE) type CHAR80 optional "#EC CI_VALPAR
      value(IV_CUSTOM) type TEXT255 optional "#EC CI_VALPAR
      value(IV_SKIP_FIRST_SCREEN) type XFELD default 'X' "#EC CI_VALPAR
    exporting
      value(ET_SHORTCUT_TABLE) type SOLI_TAB
      value(EV_SHORTCUT_STRING) type STRING
    exceptions
      INCONSISTENT_PARAMETERS .
  class-methods LINK_RESEND_MAIL
    importing
      !IV_TEXT_LINK type STRING
      !IV_MAIL_TO type AD_SMTPADR
      !IV_MAIL_COPY type AD_SMTPADR optional
      !IV_SUBJECT type SO_OBJ_DES
      !IT_CONTENT type SOLI_TAB
    returning
      value(RT_RESEND_MAIL) type SOLI_TAB .
  class-methods LINK_RESEND_MAIL_JAVA
    importing
      !IV_TEXT_LINK type STRING
      !IV_MAIL_TO type AD_SMTPADR
      !IV_SUBJECT type SO_OBJ_DES
      !IT_CONTENT type SOLI_TAB
    returning
      value(RT_RESEND_MAIL) type SOLI_TAB .
protected section.
*"* protected components of class ZCL_REUSE_MAILER
*"* do not include other source files here!!!
private section.
*"* private components of class ZCL_REUSE_MAILER
*"* do not include other source files here!!!
ENDCLASS.



CLASS ZCL_REUSE_MAILER IMPLEMENTATION.


METHOD add_attachment.

  TRY.
      CALL METHOD me->m_go_document->add_attachment
        EXPORTING
          i_attachment_type     = iv_attachment_type
          i_attachment_subject  = iv_attachment_subject
          i_attachment_size     = iv_attachment_size
          i_attachment_language = iv_attachment_language
          i_att_content_text    = it_att_content_text
          i_att_content_hex     = it_att_content_hex
          i_attachment_header   = it_attachment_header.
    CATCH cx_document_bcs.                               "#EC CI_VALPAR
  ENDTRY.

ENDMETHOD.                                               "#EC CI_VALPAR


method ADD_RECIPIENT_LIST.
*...
  data: ls_soos1 type SOOS1.
*
  try.
      check not iv_recipient_list_name is initial.
      ls_soos1-RECESC = 'C'.   " Addr. list`
      ls_soos1-RECNAM = iv_recipient_list_name.   " Like Z_LIST_1 from SAP Office
      me->m_go_send_request->send_request->add_recipient_from_soos1( i_soos1 = ls_soos1 ).
    catch cx_root.
      return.
  endtry.

endmethod.


METHOD add_recipient_mail.
*...
  DATA: lv_smtp_addr TYPE adr6-smtp_addr.
*
  TRY.
      CHECK NOT iv_recipient_mail IS INITIAL.
      lv_smtp_addr = iv_recipient_mail.   " Like `IvanovVV@it-sk.ru`
      me->m_go_recipient = cl_cam_address_bcs=>create_internet_address( i_address_string = lv_smtp_addr
                                                                        i_incl_sapuser   = iv_incl_sapuser ).
      me->m_go_send_request->add_recipient( i_recipient = me->m_go_recipient
                                            i_copy = iv_copy ). "  APPOLINAROV1 Наряд 3000012910 25.03.2022
    CATCH cx_root.
      RETURN.
  ENDTRY.

ENDMETHOD.                                               "#EC CI_VALPAR


METHOD add_recipient_uid.
*...
  DATA: lv_uname TYPE uname.
*
  TRY.
      CHECK NOT iv_recipient_uid IS INITIAL.
      lv_uname = iv_recipient_uid.   " Like `IvanovVV` from sy-uname
      me->m_go_recipient = cl_sapuser_bcs=>create( lv_uname ).
      me->m_go_send_request->add_recipient(
          EXPORTING i_recipient = me->m_go_recipient
                    i_express   = iv_express ).
    CATCH cx_root.
      RETURN.
  ENDTRY.

ENDMETHOD.                                               "#EC CI_VALPAR


METHOD constructor.
*...
*--------------------------
* Create Persistent Send Request
  TRY.
      m_go_send_request = cl_bcs=>create_persistent( ).
*
*--------------------------
* Create document
      TRY.
          m_go_document = cl_document_bcs=>create_document( i_type = iv_typobj
                                                            i_text = it_text
                                                            i_subject = iv_subject ).
        CATCH cx_document_bcs.
      ENDTRY.
*--------------------------
* Pass the document to send request
      m_go_send_request->set_document( m_go_document ).
    CATCH cx_send_req_bcs.
  ENDTRY.
*
ENDMETHOD.


METHOD conv_table_to_html.

  DATA
        : lt_header	TYPE z_treuse_table_prop
        , lt_soli   TYPE soli_tab
        , lt_table_header	TYPE soli_tab
        , lt_col_prop	TYPE soli_tab

        , lv_string    TYPE string
        , lv_tab_style TYPE string
        , lv_sep       TYPE char2
        , lv_type      TYPE char1
        , lv_span      TYPE string
        , lv_col_span  TYPE i
        , lv_width TYPE string
        .
  DATA lref_type TYPE REF TO cl_abap_structdescr.

  FIELD-SYMBOLS
                 : <lv_field> TYPE any
                 , <ls_header> LIKE LINE OF lt_header
                 , <ls_table_html> LIKE LINE OF rt_table_html
                 , <ls_col_prop> LIKE LINE OF lt_col_prop
                 , <lt_any_tab> TYPE ANY TABLE
                 .

  CONSTANTS
            : lc_pixels TYPE char2 VALUE 'px'
            , lc_percent TYPE char1 VALUE '%'
            .

  IF it_table IS INITIAL.
    RETURN.
  ENDIF.

  IF is_tab_prop-width IS INITIAL.
    IF is_tab_prop-width_pixel = abap_true.
      lv_width = |{ is_tab_prop-width }{ lc_pixels }|.
    ELSE.
      lv_width = |{ is_tab_prop-width }{ lc_percent }|.
    ENDIF.
  ELSE.
    lv_width = |100%|.
  ENDIF.

  CONDENSE lv_width NO-GAPS.

  CLEAR rt_table_html.
* Style
  IF is_tab_prop-border = abap_true.
    APPEND INITIAL LINE TO rt_table_html ASSIGNING <ls_table_html>.
    <ls_table_html>-line = |<table style="width:{ lv_width }" border="1">|.
  ELSE.
    APPEND INITIAL LINE TO rt_table_html ASSIGNING <ls_table_html>.
    <ls_table_html>-line = |<table style="width:{ lv_width }" border="0">|.
  ENDIF.

*   Наименования столбцов
  IF it_header IS NOT INITIAL.
    lt_header = it_header.
    SORT lt_header.

    LOOP AT lt_header ASSIGNING <ls_header>.

*     Свойства столбцов, каждого отдельно
      IF <ls_header>-col_width_pixel = abap_true.
        lv_sep = lc_pixels.
      ELSE.
        lv_sep = lc_percent.
      ENDIF.

      APPEND INITIAL LINE TO lt_col_prop ASSIGNING <ls_col_prop>.
      <ls_col_prop>-line = |<col width="{ <ls_header>-col_width }{ lv_sep }">|.
**********************************************************************
*   Заголовок
      IF is_tab_prop-header = abap_true.
        AT FIRST.
          APPEND INITIAL LINE TO lt_table_header ASSIGNING <ls_table_html>.
          <ls_table_html> = '<tr>'.
        ENDAT.

        IF lv_col_span <= 0.

          IF <ls_header>-col_span IS NOT INITIAL.
            lv_col_span = <ls_header>-col_span.
            lv_span = | colspan="{ <ls_header>-col_span }"|.
          ENDIF.

*       Новый столбеw
          CLEAR lv_string.
          lv_string = |<th{ lv_span }>{ <ls_header>-col_name }</th>|.

          lv_col_span = lv_col_span - 1.

          CLEAR lt_soli.
          lt_soli = zcl_reuse_mailer=>string_to_soli( iv_string = lv_string ).

          APPEND LINES OF lt_soli TO lt_table_header.
        ENDIF.

        AT LAST.
          APPEND INITIAL LINE TO lt_table_header ASSIGNING <ls_table_html>.
          <ls_table_html> = '</tr>'.
        ENDAT.
      ENDIF.

    ENDLOOP.
*   Конец заголовка

  ENDIF.

***   Таблица
**  APPEND INITIAL LINE TO rt_table_html ASSIGNING <ls_table_html>.
**  <ls_table_html> = '<table style="width:100%">'.

  APPEND LINES OF lt_col_prop TO rt_table_html. " Ширина столбцов

  APPEND LINES OF lt_table_header TO rt_table_html. " Наименования столбцов


  LOOP AT it_table ASSIGNING FIELD-SYMBOL(<ls_table>).
    IF lref_type IS NOT BOUND.
      lref_type ?= cl_abap_typedescr=>describe_by_data( <ls_table> ).
    ENDIF.
*   Новая строка
    APPEND INITIAL LINE TO rt_table_html ASSIGNING <ls_table_html>.
    IF iv_color_field IS NOT INITIAL.
      ASSIGN COMPONENT iv_color_field OF STRUCTURE <ls_table> TO FIELD-SYMBOL(<lv_color>).
      IF sy-subrc = 0 AND <lv_color> IS NOT INITIAL.
        <ls_table_html>-line = '<tr bgcolor ="' && <lv_color> && '">'.
      ENDIF.
    ENDIF.
    IF <ls_table_html> IS INITIAL.
      <ls_table_html> = '<tr>'.
    ENDIF.


    LOOP AT lref_type->components ASSIGNING FIELD-SYMBOL(<ls_components>).
*      DO.
      IF <ls_components>-name = iv_color_field. CONTINUE. ENDIF.
      ASSIGN COMPONENT <ls_components>-name OF STRUCTURE <ls_table> TO <lv_field>.
      IF sy-subrc = 0.
*       Новый столбец
        CLEAR : lv_string, lv_type.
        DESCRIBE FIELD <lv_field> TYPE lv_type.
        IF lv_type = gc_type_table. " SOLI_TAB поле - пересылаемое письмо
          lv_string = |<td>|.
          ASSIGN <lv_field> TO <lt_any_tab>.
          LOOP AT <lt_any_tab> ASSIGNING FIELD-SYMBOL(<ls_soli_tab>).
            CONCATENATE lv_string
                        <ls_soli_tab>
                        INTO lv_string.
          ENDLOOP.
          lv_string = |{ lv_string }</td>|.
        ELSE.
          lv_string = |<td>{ <lv_field> }</td>|.
        ENDIF.


        CLEAR lt_soli.
        lt_soli = zcl_reuse_mailer=>string_to_soli( iv_string = lv_string ).

        APPEND LINES OF lt_soli TO rt_table_html.
*        ELSE.
*          EXIT.
      ENDIF.

**      ASSIGN COMPONENT sy-index OF STRUCTURE <ls_table> TO <lv_field>.
**      IF sy-subrc = 0.
**        APPEND INITIAL LINE TO rt_table_html ASSIGNING <ls_table_html>.
**        <ls_table_html> = '<td>'.
***       Новый столбец
**        CLEAR : lt_soli, lv_string, lv_type.
**        DESCRIBE FIELD <lv_field> TYPE lv_type.
**
**        IF lv_type = gc_type_table. " SOLI_TAB поле - пересылаемое письмо
**
***         Обязательно SOLI_TAB
**          ASSIGN <lv_field> TO <lt_any_tab>.
**          LOOP AT <lt_any_tab> ASSIGNING FIELD-SYMBOL(<ls_soli_tab>).
**            ASSIGN COMPONENT 'LINE' OF STRUCTURE <ls_soli_tab> TO FIELD-SYMBOL(<lv_line>).
**            IF sy-subrc = 0.
**              APPEND INITIAL LINE TO lt_soli ASSIGNING FIELD-SYMBOL(<ls_soli>).
**              <ls_soli>-line = <lv_line>.
**            ENDIF.
**          ENDLOOP.
**
**        ELSE.
**          lv_string = <lv_field>.
**          lt_soli = zcl_reuse_mailer=>string_to_soli( iv_string = lv_string ).
**        ENDIF.
**
**        APPEND LINES OF lt_soli TO rt_table_html.
**        APPEND INITIAL LINE TO rt_table_html ASSIGNING <ls_table_html>.
**        <ls_table_html> = '</td>'.
**      ELSE.
**        EXIT.
**      ENDIF.
    ENDLOOP.
*      ENDDO.
*   Конец строки
    APPEND INITIAL LINE TO rt_table_html ASSIGNING <ls_table_html>.
    <ls_table_html> = '</tr>'.
  ENDLOOP.

*   Закончилась таблица
  APPEND INITIAL LINE TO rt_table_html ASSIGNING <ls_table_html>.
  <ls_table_html> = '</table>'.

ENDMETHOD.


METHOD COUNT_DOC_SIZE.

  DATA: lv_doc_lines  TYPE i,
        lv_hex_line   TYPE solix-line,
        lv_text_line  TYPE soli-line,
        lv_line_size  TYPE i,
        lv_last_line  TYPE i,
        lv_doc_size   TYPE i,
        lv_is_binary  TYPE os_boolean.


  DESCRIBE TABLE it_hex LINES lv_doc_lines.
  IF lv_doc_lines > 0.
    lv_is_binary = 'X'.
  ENDIF.

  IF lv_is_binary = 'X'.
* *--- binary document ---------------------------
    DESCRIBE TABLE it_hex LINES lv_doc_lines.
    IF lv_doc_lines = 0.
      lv_doc_size = 0.
    ELSE.
      lv_line_size = xstrlen( lv_hex_line ).
      lv_doc_size = lv_line_size * lv_doc_lines.
    ENDIF.
  ELSE.
* *--- text document ---------------------------
    DESCRIBE TABLE it_text LINES lv_doc_lines.
    IF lv_doc_lines = 0.
      lv_doc_size = 0.
    ELSE.
      READ TABLE it_text INTO lv_text_line
           INDEX lv_doc_lines."#EC CI_SUBRC
      lv_last_line = strlen( lv_text_line ).
      lv_doc_size = 255 * ( lv_doc_lines - 1 ) + lv_last_line.
    ENDIF.
  ENDIF.

  rv_result = lv_doc_size.

ENDMETHOD.


  METHOD create_shortcut.

    CALL FUNCTION 'SWN_CREATE_SHORTCUT'
      EXPORTING
        i_transaction           = iv_transaction
        i_report                = iv_report
        i_system_command        = iv_system_command
        i_parameter             = iv_parameter
        i_saplogon_id           = iv_saplogon_id
        i_sysid                 = iv_sysid
        i_guiparm               = iv_guiparm
        i_client                = iv_client
        i_user                  = iv_user
        i_language              = iv_language
        i_windowsize            = iv_windowsize
        i_title                 = iv_title
        i_custom                = iv_custom
      IMPORTING
        shortcut_table          = et_shortcut_table
        shortcut_string         = ev_shortcut_string
      EXCEPTIONS
        inconsistent_parameters = 1.
    IF sy-subrc <> 0.
      RAISE inconsistent_parameters.
    ENDIF.

    IF iv_skip_first_screen = abap_true.
*  Пропускаем первый экран 'Command=' на 'Command=*'
      REPLACE FIRST OCCURRENCE OF m_gc_command IN TABLE et_shortcut_table WITH m_gc_command_skip.

      REPLACE FIRST OCCURRENCE OF m_gc_command IN ev_shortcut_string WITH m_gc_command_skip.
    ENDIF.

  ENDMETHOD. "#EC CI_VALPAR


METHOD field_as_hyperlink.
  DATA: lv_full_name TYPE char100.
* При создании вложения необходимо
* в параметр метода add_attachment
* iv_attachment_type = SAP - расширение ярлыка
* iv_attachment_subject передать значение  IV_NAME_ATTACH

* в поле ссылки нужно дописать расширениев название
  IF iv_attach_type IS NOT INITIAL.
    lv_full_name = |{ iv_name_attach }.{ iv_attach_type }|.
  ELSE.
    lv_full_name = iv_name_attach.
  ENDIF.

  cv_field = |<P><U><a href="cid:{ lv_full_name }">{ cv_field }</a></U></P>|.

ENDMETHOD.


  METHOD link_resend_mail.

    DATA
          : lv_mail_text  TYPE string
          , lv_subject    TYPE string
          , lv_mail_copy  TYPE string
          .
    CLEAR rt_resend_mail.

    lv_subject   = iv_subject.
    REPLACE ALL OCCURRENCES OF | | IN lv_subject WITH m_gc_space_mail. " Заменить все пробелы на спец символ

* ?SUBJECT= Тема письма
    lv_mail_text = |SUBJECT={ lv_subject }&BODY=|.
*  &BODY= - Тело письма
*  Разбиваем по строкам. Знак новой строки
*  CL_ABAP_CHAR_UTILITIES=>NEWLINE

    LOOP AT it_content ASSIGNING FIELD-SYMBOL(<ls_content>).
      lv_mail_text = |{ lv_mail_text }{ <ls_content>-line }|.
    ENDLOOP.

    CONDENSE lv_mail_text.
    REPLACE ALL OCCURRENCES OF | | IN lv_mail_text WITH m_gc_space_mail. " Заменить все пробелы на спец символ

    REPLACE ALL OCCURRENCES OF cl_abap_char_utilities=>newline IN lv_mail_text WITH m_gc_newline_mail. " Заменить "новую строку" на спец символ
* Кнопка "переслать" - пересылает текст после тега BODY (берем из таблицы IT_CONTENT)
* MAILTO - адресат
    IF iv_mail_copy IS NOT INITIAL.
      lv_mail_copy = |cc={ iv_mail_copy }&|.
    ENDIF.

    lv_mail_text = |<P><U><a href=MAILTO:{ iv_mail_to }?{ lv_mail_copy }{ lv_mail_text }|.

    lv_mail_text = |{ lv_mail_text }>  { iv_text_link }</a></U></P>|.

    rt_resend_mail = zcl_reuse_mailer=>string_to_soli( iv_string = lv_mail_text ).

*<P><U><a href=MAILTO:Адрес?SUBJECT=Тема&BODY=ТекстПисьма>  Текст в ссылке</a></U></P>


  ENDMETHOD.


  METHOD link_resend_mail_java.

    DATA
          : lt_body       TYPE soli_tab

          , lv_line       TYPE SO_TEXT255
          , lv_mail_text  TYPE string
          , lv_subject    TYPE string
          .
    CLEAR rt_resend_mail.

    lv_subject   = iv_subject.
    REPLACE ALL OCCURRENCES OF | | IN lv_subject WITH m_gc_space_mail. " Заменить все пробелы на спец символ

    APPEND INITIAL LINE TO rt_resend_mail ASSIGNING FIELD-SYMBOL(<ls_resend_mail>).
    <ls_resend_mail>-line = |<html>|.

    APPEND INITIAL LINE TO rt_resend_mail ASSIGNING <ls_resend_mail>.
    <ls_resend_mail>-line = |<head>|.

    APPEND INITIAL LINE TO rt_resend_mail ASSIGNING <ls_resend_mail>.
    <ls_resend_mail>-line = |<script type='text/javascript' language='javascript'>|.

    APPEND INITIAL LINE TO rt_resend_mail ASSIGNING <ls_resend_mail>.
    <ls_resend_mail>-line = |function OpenOutlookNewEmail()|.

    APPEND INITIAL LINE TO rt_resend_mail ASSIGNING <ls_resend_mail>.
    <ls_resend_mail>-line = '{'.

    APPEND INITIAL LINE TO rt_resend_mail ASSIGNING <ls_resend_mail>.
    <ls_resend_mail>-line = |try|.

    APPEND INITIAL LINE TO rt_resend_mail ASSIGNING <ls_resend_mail>.
    <ls_resend_mail>-line = '{'.

    APPEND INITIAL LINE TO rt_resend_mail ASSIGNING <ls_resend_mail>.
    <ls_resend_mail>-line = |var outlookApp = new ActiveXObject("Outlook.Application");|.

    APPEND INITIAL LINE TO rt_resend_mail ASSIGNING <ls_resend_mail>.
    <ls_resend_mail>-line = |var nameSpace = outlookApp.getNameSpace("MAPI");|.

    APPEND INITIAL LINE TO rt_resend_mail ASSIGNING <ls_resend_mail>.
    <ls_resend_mail>-line = |mailFolder = nameSpace.getDefaultFolder(6);|.

    APPEND INITIAL LINE TO rt_resend_mail ASSIGNING <ls_resend_mail>.
    <ls_resend_mail>-line = |mailItem = mailFolder.Items.add('IPM.Note.FormA');|.

    APPEND INITIAL LINE TO rt_resend_mail ASSIGNING <ls_resend_mail>.
    <ls_resend_mail>-line = |mailItem.Subject="{ lv_subject }";|.

    APPEND INITIAL LINE TO rt_resend_mail ASSIGNING <ls_resend_mail>.
    <ls_resend_mail>-line = |mailItem.To = "{ iv_mail_to }";|.

*
    lv_mail_text = |mailItem.HTMLBody = "|.
    LOOP AT it_content ASSIGNING FIELD-SYMBOL(<ls_content>).
      CLEAR lv_line.
      lv_line = <ls_content>-line.
      REPLACE ALL OCCURRENCES OF |"| IN lv_line WITH '\"'.
      lv_mail_text = |{ lv_mail_text }{ lv_line }|.
    ENDLOOP.
    lv_mail_text = |{ lv_mail_text }";|.
    CONDENSE lv_mail_text.

    REPLACE ALL OCCURRENCES OF cl_abap_char_utilities=>newline IN lv_mail_text WITH '</p>'.

    lt_body = zcl_reuse_mailer=>string_to_soli( iv_string = lv_mail_text ).

    APPEND LINES OF lt_body TO rt_resend_mail.

    APPEND INITIAL LINE TO rt_resend_mail ASSIGNING <ls_resend_mail>.
    <ls_resend_mail>-line = |mailItem.display (0); |.

    APPEND INITIAL LINE TO rt_resend_mail ASSIGNING <ls_resend_mail>.
    <ls_resend_mail>-line = '}'.

    APPEND INITIAL LINE TO rt_resend_mail ASSIGNING <ls_resend_mail>.
    <ls_resend_mail>-line = |catch(e)|.

    APPEND INITIAL LINE TO rt_resend_mail ASSIGNING <ls_resend_mail>.
    <ls_resend_mail>-line = '{'.

    APPEND INITIAL LINE TO rt_resend_mail ASSIGNING <ls_resend_mail>.
    <ls_resend_mail>-line = |alert(e);|.

    APPEND INITIAL LINE TO rt_resend_mail ASSIGNING <ls_resend_mail>.
    <ls_resend_mail>-line = '}'.

    APPEND INITIAL LINE TO rt_resend_mail ASSIGNING <ls_resend_mail>.
    <ls_resend_mail>-line = '}'.

    APPEND INITIAL LINE TO rt_resend_mail ASSIGNING <ls_resend_mail>.
    <ls_resend_mail>-line = |</script>|.

    APPEND INITIAL LINE TO rt_resend_mail ASSIGNING <ls_resend_mail>.
    <ls_resend_mail>-line = |</head>|.

    APPEND INITIAL LINE TO rt_resend_mail ASSIGNING <ls_resend_mail>.
    <ls_resend_mail>-line = |<body>|.

    APPEND INITIAL LINE TO rt_resend_mail ASSIGNING <ls_resend_mail>.
    <ls_resend_mail>-line = |<a href='javascript:OpenOutlookNewEmail()' >{ iv_text_link }</a>|.

    APPEND INITIAL LINE TO rt_resend_mail ASSIGNING <ls_resend_mail>.
    <ls_resend_mail>-line = |</body>|.

    APPEND INITIAL LINE TO rt_resend_mail ASSIGNING <ls_resend_mail>.
    <ls_resend_mail>-line = |</html>|.

  ENDMETHOD.


METHOD send.
*...

  CONSTANTS: lc_wf TYPE if_fdt_types=>name VALUE 'ZCONST_WF_REUSE_WFBATCH'.
  TRY.

*--------------------------
* Set the Send Immediately Flag
      m_go_send_request->set_send_immediately( abap_true ).
*
*--------------------------
* Send Document
      rv_result = m_go_send_request->send( i_with_error_screen = iv_with_error_screen ).

      IF iv_commit_work = abap_true.
        IF sy-uname <> zcl_tvarvc=>get_const( iv_name = lc_wf ). " Dovbnya 15042024 9000046536
          COMMIT WORK AND WAIT.
        ENDIF.
      ENDIF.

    CATCH cx_send_req_bcs.
      rv_result = ''.
  ENDTRY.
*
ENDMETHOD.


  METHOD set_message_subject. "#EC CI_VALPAR
    " 3000007960_
    m_go_send_request->set_message_subject( iv_subject ).
  ENDMETHOD. "#EC CI_VALPAR


METHOD SET_SUBJECT_AND_BODY_TEXT.
*...
*--------------------------
* Create document
*  if go_document is bound.
*    free go_document.
*  endif.
  TRY.
      m_go_document = cl_document_bcs=>create_document( i_type = iv_typobj
                                                        i_text = it_text
                                                        i_subject = iv_subject ).
    CATCH cx_document_bcs.
  ENDTRY.
*--------------------------
* Pass the document to send request
  TRY.
      m_go_send_request->set_document( m_go_document ).
    CATCH cx_send_req_bcs.
  ENDTRY.
*
ENDMETHOD.


method STRING_TO_SOLI.

  data  lv_offset type i.
  data  lt_soli type soli_tab.
  data  ls_soli_line type soli.
  data  lv_string_len type i.
  data  lv_soli_rows type i.
  data  lv_last_row_length type i.
  data  lv_row_length type i.
  data  lv_doc_length type so_obj_len.

* * transform string to SOLI
  describe field ls_soli_line length lv_row_length in character mode.
  lv_offset = 0.

  lv_string_len = strlen( iv_string ).

  lv_soli_rows = lv_string_len div lv_row_length.
  lv_last_row_length = lv_string_len mod lv_row_length.
  do lv_soli_rows times.
    ls_soli_line-line =
           iv_string+lv_offset(lv_row_length).
    append ls_soli_line to rt_soli.
    add lv_row_length to lv_offset.
  enddo.
  if lv_last_row_length > 0.
    clear ls_soli_line-line.
    ls_soli_line-line = iv_string+lv_offset(lv_last_row_length).
    append ls_soli_line to rt_soli.
  endif.

endmethod.


METHOD XSTRING_TO_SOLIX.

  DATA  lv_offset TYPE i.
  DATA  lt_solix TYPE solix_tab.
  DATA  ls_solix_line TYPE solix.
  DATA  ls_archive_params TYPE toa_dara.
  DATA  lv_pdf_string_len TYPE i.
  DATA  lv_solix_rows TYPE i.
  DATA  lv_last_row_length TYPE i.
  DATA  lv_row_length TYPE i.
  DATA  lv_doc_length TYPE so_obj_len.

* * transform xstring to SOLIX
  DESCRIBE TABLE lt_solix.
  lv_row_length = sy-tleng.
  lv_offset = 0.

  lv_pdf_string_len = xstrlen( iv_xstring ).

  lv_solix_rows = lv_pdf_string_len DIV lv_row_length.
  lv_last_row_length = lv_pdf_string_len MOD lv_row_length.
  DO lv_solix_rows TIMES.
    ls_solix_line-line =
           iv_xstring+lv_offset(lv_row_length).
    APPEND ls_solix_line TO rt_solix.
    ADD lv_row_length TO lv_offset.
  ENDDO.
  IF lv_last_row_length > 0.
    CLEAR ls_solix_line-line.
    ls_solix_line-line = iv_xstring+lv_offset(lv_last_row_length).
    APPEND ls_solix_line TO rt_solix.
  ENDIF.

ENDMETHOD.
ENDCLASS.

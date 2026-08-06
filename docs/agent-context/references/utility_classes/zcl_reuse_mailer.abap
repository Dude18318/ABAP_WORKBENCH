class ZCL_REUSE_MAILER definition
  public
  create public .

public section.
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
private section.
ENDCLASS.

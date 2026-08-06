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

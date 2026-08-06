class ZCL_HCM_OBJ_MASS definition
  public
  create protected .

public section.
  type-pools ABAP .

  types:
    BEGIN OF ty_descr,
        otype       TYPE otype,
        objid       TYPE hrobjid,
        begda       TYPE begda,
        endda       TYPE endda,
        description TYPE text1000,
      END OF ty_descr .
  types:
    ty_t_descr TYPE STANDARD TABLE OF ty_descr WITH EMPTY KEY .
  types:
    BEGIN OF ty_attrib,
        otype       TYPE otype,
        objid       TYPE hrobjid,
        begda       TYPE begda,
        endda       TYPE endda,
        attrib      TYPE hrt1222-attrib,
        low         TYPE hrt1222-low,
        high        TYPE hrt1222-high,
      END OF ty_attrib .
  types:
    ty_t_attrib TYPE STANDARD TABLE OF ty_attrib WITH EMPTY KEY .

  class-methods GET_INSTANCE
    importing
      !IV_PLVAR type PLVAR optional
      !IV_BEGDA type BEGDA default SY-DATUM
      !IV_ENDDA type ENDDA default SY-DATUM
    returning
      value(RO_INSTANCE) type ref to ZCL_HCM_OBJ_MASS .
  methods ADD_PERNR
    importing
      !IV_PERNR type PERNR_D .
  methods ADD_OBJECT
    importing
      !IV_NO_EXIST_CHK type ABAP_BOOL default ABAP_FALSE
      !IV_OTYPE type OTYPE
      !IV_OBJID type HROBJID .
  methods REFRESH
    importing
      !IV_DEL_OBJECTS type FLAG default ABAP_TRUE
      !IV_DEL_PERNR type FLAG default ABAP_TRUE .
  methods READ_RH_INFOTYPE
    importing
      !IV_INFTY type INFTY
      !IV_SUBTY type SUBTY optional
      !IV_CHECK_AUTH type FLAG default ABAP_TRUE
    exporting
      !ET_PNNNN type STANDARD TABLE .
  methods READ_RELATIONS
    importing
      !IV_SUBTY type SUBTY
      !IV_REQU_OTYPE type OTYPE optional
      !IV_CHECK_AUTH type FLAG default ABAP_TRUE
      !IV_WITH_ADATA type FLAG default ABAP_TRUE
    exporting
      !ET_P1001 type P1001_T .
  methods GET_PERNR_NUM
    returning
      value(RV_NUM) type INT4 .
  methods GET_OBJECTS_NUM
    returning
      value(RV_NUM) type INT4 .
  methods FILL_HR_INFTY_BUFFER
    importing
      !IV_INFTY type INFTY .
  methods GET_PERNR_TAB
    returning
      value(RT_PERNR) type PERNR_TAB .
  methods READ_DESCRIPTIONS
    importing
      !IV_SUBTY type SUBTYP
      !IV_LANGU type SY-LANGU default SY-LANGU
      !IV_WITH_SHORT type FLAG default ABAP_FALSE
      !IV_CHECK_AUTH type FLAG default ABAP_FALSE
    returning
      value(RT_DESCR) type TY_T_DESCR .
  methods READ_ATTRIBUTES
    importing
      !IV_CHECK_AUTH type FLAG default ABAP_TRUE
      !IV_ATTRIB type OM_ATTRIB optional
    returning
      value(RT_ATTRIB) type TY_T_ATTRIB .
  methods READ_INFTY_TAB_DATA
    importing
      !IV_INFTY type WPLOG-INFTY
      !IT_INNNN type STANDARD TABLE
    exporting
      !ET_HRTNNNN type STANDARD TABLE .
  PROTECTED SECTION.
private section.

  data MV_BEGDA type BEGDA .
  data MV_ENDDA type ENDDA .
  data MV_PLVAR type PLVAR .
  data MT_OBJECTS type HROBJECT_T .
  data MT_PERNR type PERNR_TAB .
ENDCLASS.
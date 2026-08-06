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



CLASS ZCL_HCM_OBJ_MASS IMPLEMENTATION.


METHOD add_object.

  IF iv_no_exist_chk = abap_false.
    READ TABLE me->mt_objects TRANSPORTING NO FIELDS WITH KEY plvar = me->mv_plvar
                                                              otype = iv_otype
                                                              objid = iv_objid.
  ENDIF.

  IF sy-subrc IS NOT INITIAL OR iv_no_exist_chk = abap_true.
    APPEND VALUE hrobject( plvar = me->mv_plvar
                           otype = iv_otype
                           objid = iv_objid ) TO me->mt_objects.
  ENDIF.

ENDMETHOD.


  METHOD add_pernr.

    READ TABLE me->mt_pernr TRANSPORTING NO FIELDS WITH KEY table_line = iv_pernr.
    IF sy-subrc IS NOT INITIAL.
      APPEND iv_pernr TO me->mt_pernr.
    ENDIF.
  ENDMETHOD.


  METHOD fill_hr_infty_buffer.

    CALL FUNCTION 'HR_FILL_BUFFER_MULTIPLE_PERNR'
      EXPORTING
        it_pernr        = me->mt_pernr
        iv_infty        = iv_infty
        iv_begda        = me->mv_begda
        iv_endda        = me->mv_endda
      EXCEPTIONS
        infty_not_found = 1
        invalid_input   = 2
        OTHERS          = 3.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

  ENDMETHOD.


  METHOD get_instance.

    CREATE OBJECT ro_instance.

    IF iv_plvar IS NOT INITIAL.
      ro_instance->mv_plvar = iv_plvar.
    ELSE.
      ro_instance->mv_plvar = cl_hrtmc_const=>plvar.
    ENDIF.

    ro_instance->mv_begda = iv_begda.
    ro_instance->mv_endda = iv_endda.

  ENDMETHOD.


  METHOD get_objects_num.
    rv_num = lines( me->mt_objects ).
  ENDMETHOD.


  METHOD get_pernr_num.
    rv_num = lines( me->mt_pernr ).
  ENDMETHOD.


  METHOD get_pernr_tab.

    rt_pernr = me->mt_pernr.
  ENDMETHOD.


METHOD read_attributes.

  DATA: lt_p1222   TYPE zthcm_lso_hap_t_p1222,
        lt_hrt1222 TYPE STANDARD TABLE OF hrt1222,
        lv_tabix   TYPE sy-tabix VALUE 1.

  read_rh_infotype( EXPORTING
                      iv_infty      = zcl_int_mass_proc_tab=>mc_infty-infty_1222
                      iv_check_auth = iv_check_auth
                    IMPORTING
                      et_pnnnn      = lt_p1222 ).

  CHECK lt_p1222 IS NOT INITIAL.

  read_infty_tab_data( EXPORTING
                         iv_infty   = zcl_int_mass_proc_tab=>mc_infty-infty_1222
                         it_innnn   = lt_p1222
                       IMPORTING
                         et_hrtnnnn = lt_hrt1222 ).

  CHECK lt_hrt1222 IS NOT INITIAL.

  IF iv_attrib IS NOT INITIAL.
    DELETE lt_hrt1222 WHERE attrib <> iv_attrib.
  ENDIF.

  SORT lt_p1222 BY tabnr.
  SORT lt_hrt1222 BY tabnr tabseqnr.

  LOOP AT lt_p1222 ASSIGNING FIELD-SYMBOL(<ls_p1222>).

    LOOP AT lt_hrt1222 ASSIGNING FIELD-SYMBOL(<ls_hrt1222>) FROM lv_tabix. "#EC CI_NESTED

      IF <ls_hrt1222>-tabnr <> <ls_p1222>-tabnr.
        lv_tabix = sy-tabix.
        EXIT.
      ENDIF.

      APPEND VALUE #( otype  = <ls_p1222>-otype
                      objid  = <ls_p1222>-objid
                      begda  = <ls_p1222>-begda
                      endda  = <ls_p1222>-endda
                      attrib = <ls_hrt1222>-attrib
                      low    = <ls_hrt1222>-low
                      high   = <ls_hrt1222>-high ) TO rt_attrib.

    ENDLOOP.

  ENDLOOP.

  SORT rt_attrib BY otype objid begda endda attrib.

ENDMETHOD.


METHOD read_descriptions.

  DATA: lt_p1002   TYPE TABLE OF p1002,
        lt_hrt1002 TYPE TABLE OF hrt1002,
        lt_p1000   TYPE hap_t_p1000,
        lt_objects LIKE me->mt_objects,
        lv_index   TYPE sy-tabix VALUE 1,
        lv_tabix   TYPE sy-tabix VALUE 1.


  IF me->mt_objects IS INITIAL.
    RETURN.
  ENDIF.

* Читаем описания из 1002
  CALL FUNCTION 'HRIQ_READ_DESCRIPT_FOR_OBJECTS'
    EXPORTING
      language       = iv_langu
      subty          = iv_subty
      begda          = me->mv_begda
      endda          = me->mv_endda
      stru_auth      = iv_check_auth
    TABLES
      objects        = me->mt_objects
      p1002          = lt_p1002
      hrt1002        = lt_hrt1002
    EXCEPTIONS
      nothing_found  = 1
      internal_error = 2
      OTHERS         = 3.

  IF sy-subrc <> 0.
    CLEAR: lt_p1002, lt_hrt1002.
  ENDIF.

  SORT lt_p1002 BY tabnr.
  SORT lt_hrt1002 BY tabnr tabseqnr.

* Склеиваем надйенные описания из 1002 по объектам
  LOOP AT lt_p1002 ASSIGNING FIELD-SYMBOL(<ls_p1002>).

    DATA(lt_text) = VALUE tline_tab( ).

    LOOP AT lt_hrt1002 ASSIGNING FIELD-SYMBOL(<ls_hrt1002>) FROM lv_tabix. "#EC CI_NESTED
      IF <ls_hrt1002>-tabnr <> <ls_p1002>-tabnr.
        lv_tabix = sy-tabix.
        EXIT.
      ENDIF.
      INSERT CORRESPONDING #( <ls_hrt1002> MAPPING tdformat = tformat tdline = tline ) INTO TABLE lt_text.
    ENDLOOP.

    DATA(lt_line) = VALUE string_table( ).

    CALL FUNCTION 'CONVERT_ITF_TO_STREAM_TEXT'
      EXPORTING
        lf           = abap_on
      IMPORTING
        stream_lines = lt_line
      TABLES
        itf_text     = lt_text.

    APPEND VALUE #( otype       = <ls_p1002>-otype
                    objid       = <ls_p1002>-objid
                    begda       = <ls_p1002>-begda
                    endda       = <ls_p1002>-endda
                    description = concat_lines_of( lt_line ) ) TO rt_descr.
  ENDLOOP.

  SORT rt_descr BY otype objid begda endda.

* Дополнить наименованиями из 1000 ИТ, если не нашлись в 1002
  IF iv_with_short = abap_true.

*   Список объектов, для которых не нашлось имен в 1002
    LOOP AT me->mt_objects ASSIGNING FIELD-SYMBOL(<ls_object>).
      READ TABLE rt_descr TRANSPORTING NO FIELDS WITH KEY otype = <ls_object>-otype objid = <ls_object>-objid BINARY SEARCH.
      CHECK sy-subrc <> 0.
      APPEND <ls_object> TO lt_objects.
    ENDLOOP.

    IF iv_check_auth = abap_false.
      CALL FUNCTION 'RH_AUTHORITY_CHECK_OFF'.
    ENDIF.
*   Читаем 1000 ИТ
    CALL FUNCTION 'RH_READ_INFTY'
      EXPORTING
        with_stru_auth       = iv_check_auth
        infty                = zcl_int_mass_proc_tab=>mc_infty-infty_1000
        begda                = me->mv_begda
        endda                = me->mv_endda
      TABLES
        innnn                = lt_p1000
        objects              = lt_objects
      EXCEPTIONS
        all_infty_with_subty = 1
        nothing_found        = 2
        no_objects           = 3
        wrong_condition      = 4
        wrong_parameters     = 5
        OTHERS               = 6.

    IF sy-subrc <> 0.
      CLEAR: lt_p1000.
    ENDIF.

    IF iv_check_auth = abap_false.
      CALL FUNCTION 'RH_AUTHORITY_CHECK_ON'.
    ENDIF.

    DELETE lt_p1000 WHERE langu <> iv_langu.
    SORT lt_p1000 BY otype objid begda endda.

*   Находим наименования из 1000 ИТ для оставшихся объектов
    LOOP AT lt_objects ASSIGNING <ls_object>.

      LOOP AT lt_p1000 ASSIGNING FIELD-SYMBOL(<ls_p1000>) FROM lv_index. "#EC CI_NESTED

        IF <ls_p1000>-objid <> <ls_object>-objid OR <ls_p1000>-otype <> <ls_object>-otype.
          lv_index = sy-tabix.
          EXIT.
        ENDIF.

        APPEND VALUE #( otype       = <ls_object>-otype
                        objid       = <ls_object>-objid
                        begda       = me->mv_begda
                        endda       = me->mv_endda
                        description = <ls_p1000>-stext ) TO rt_descr.
      ENDLOOP.

    ENDLOOP.

    SORT rt_descr BY otype objid begda endda.

  ENDIF.

ENDMETHOD.


METHOD read_infty_tab_data.

  CHECK it_innnn IS NOT INITIAL.

  CALL FUNCTION 'RH_READ_INFTY_TABDATA'
    EXPORTING
      infty          = iv_infty
    TABLES
      innnn          = it_innnn
      hrtnnnn        = et_hrtnnnn
    EXCEPTIONS
      no_table_infty = 1
      innnn_empty    = 2
      nothing_found  = 3
      OTHERS         = 4.

  IF sy-subrc <> 0.
    CLEAR et_hrtnnnn.
  ENDIF.

ENDMETHOD.


  METHOD read_relations.

    CLEAR: et_p1001.

    IF me->mt_objects IS INITIAL.
      RETURN.
    ENDIF.

    IF iv_check_auth = abap_false.
      CALL FUNCTION 'RH_AUTHORITY_CHECK_OFF'.
    ENDIF.

    CALL FUNCTION 'RH_READ_INFTY_1001'
      EXPORTING
        with_stru_auth   = iv_check_auth
        subty            = iv_subty
        begda            = me->mv_begda
        endda            = me->mv_endda
        adata            = iv_with_adata
      TABLES
        objects          = me->mt_objects
        i1001            = et_p1001
      EXCEPTIONS
        nothing_found    = 1
        wrong_condition  = 2
        wrong_parameters = 3
        OTHERS           = 4.
    IF sy-subrc <> 0.
      CLEAR: et_p1001.
      RETURN.
    ENDIF.

    IF iv_requ_otype IS NOT INITIAL.
      DELETE et_p1001 WHERE sclas <> iv_requ_otype.
    ENDIF.

    IF iv_check_auth = abap_false.
      CALL FUNCTION 'RH_AUTHORITY_CHECK_ON'.
    ENDIF.

  ENDMETHOD.


  METHOD read_rh_infotype.

    CLEAR: et_pnnnn.

    IF me->mt_objects IS INITIAL.
      RETURN.
    ENDIF.

    IF iv_check_auth = abap_false.
      CALL FUNCTION 'RH_AUTHORITY_CHECK_OFF'.
      CALL FUNCTION 'HR_READ_INFOTYPE_AUTHC_DISABLE'.
      CALL FUNCTION 'RH_DEACTIVATE_STRUCTURED_AC'.
    ENDIF.

    CALL FUNCTION 'RH_READ_INFTY'
      EXPORTING
        with_stru_auth       = iv_check_auth
        infty                = iv_infty
        subty                = iv_subty
        begda                = me->mv_begda
        endda                = me->mv_endda
      TABLES
        innnn                = et_pnnnn
        objects              = me->mt_objects
      EXCEPTIONS
        all_infty_with_subty = 1
        nothing_found        = 2
        no_objects           = 3
        wrong_condition      = 4
        wrong_parameters     = 5
        OTHERS               = 6.
    IF sy-subrc <> 0.
      CLEAR: et_pnnnn.
    ENDIF.

    IF iv_check_auth = abap_false.
      CALL FUNCTION 'RH_AUTHORITY_CHECK_ON'.
    ENDIF.

  ENDMETHOD.


  METHOD refresh.
    IF iv_del_objects = abap_true.
      CLEAR: me->mt_objects.
    ENDIF.

    IF iv_del_pernr = abap_true.
      CLEAR: me->mt_pernr.
      CALL FUNCTION 'HR_INITIALIZE_BUFFER'.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
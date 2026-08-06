" FINAL VASCHENKOIA 08.08.2024
CLASS zcl_hcm_om_obj DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES zif_type_om_obj. " AnisimovSV оптимизация

    TYPES:
      BEGIN OF ty_s_pernr_struc,
        orgeh       TYPE hrp1001-sobid,
        orgeh_name  TYPE stext,
        orgeh_langu TYPE hrp1000-langu,
        plans       TYPE hrp1001-sobid,
        plans_name  TYPE stext,
        plans_langu TYPE hrp1000-langu,
        pernr       TYPE hrp1001-sobid,
        boss        TYPE flag,
        subty       TYPE hrp1001-subty,
      END OF ty_s_pernr_struc.
    TYPES ty_t_pernr_struc TYPE STANDARD TABLE OF ty_s_pernr_struc WITH NON-UNIQUE SORTED KEY person COMPONENTS orgeh plans pernr.
    TYPES:
      BEGIN OF ty_s_orgstr,
        objid TYPE hrp1001-objid,
        stext TYPE hrp1000-stext,
      END OF ty_s_orgstr.
    TYPES ty_t_orgstr TYPE STANDARD TABLE OF ty_s_orgstr WITH EMPTY KEY
                                                                     WITH NON-UNIQUE SORTED KEY key_objid COMPONENTS objid.
    TYPES:
      BEGIN OF ty_struct,
        lvl   TYPE i,
        objid TYPE hrp1001-objid,
        otype TYPE hrp1001-otype,
        subty TYPE hrp1001-subty,
      END OF ty_struct.
    TYPES ty_t_struct TYPE SORTED TABLE OF ty_struct WITH UNIQUE KEY table_line.
    TYPES:
      BEGIN OF ty_orgstr,
        ind     TYPE index,
        orgtext TYPE string,
        abtel   TYPE flag,
        stabs   TYPE flag,
      END OF ty_orgstr.
    TYPES:
      BEGIN OF ty_orgeh_struc,
        ind     TYPE index,
        orgtext TYPE string,
        orgeh   TYPE orgeh,
        abtel   TYPE flag,
        stabs   TYPE flag,
      END OF ty_orgeh_struc.
    TYPES ty_orgstr_tab TYPE STANDARD TABLE OF ty_orgstr WITH DEFAULT KEY.
    TYPES ty_orgeh_tab  TYPE STANDARD TABLE OF ty_orgeh_struc WITH DEFAULT KEY. " SavinovaEA 13.07.2022

    DATA ms_object TYPE hrobject.

    CONSTANTS mc_relat_p_s TYPE subty VALUE 'B008' ##NO_TEXT.

    CLASS-DATA mv_cache_enabled TYPE abap_bool.

    CLASS-METHODS class_constructor.
"! <p class="shorttext synchronized" lang="ru">Очистка кэша</p>
    CLASS-METHODS clear_cache.

    "! <p class="shorttext synchronized" lang="ru">Установка включения cache из tvarvc</p>
    CLASS-METHODS is_cache_enabled
      RETURNING VALUE(rv_enabled) TYPE abap_bool.

    CLASS-METHODS get_normalized_plvar
      IMPORTING iv_plvar        TYPE plvar OPTIONAL
      RETURNING VALUE(rv_plvar) TYPE plvar.

    METHODS constructor
      IMPORTING iv_objid       TYPE hrobjid
                iv_otype       TYPE otype
                iv_begda       TYPE begda     DEFAULT sy-datum
                iv_endda       TYPE endda     DEFAULT sy-datum
                iv_plvar       TYPE plvar     OPTIONAL
                iv_is_easy_run TYPE abap_bool DEFAULT abap_false.

    METHODS enqueue
      EXPORTING ev_ok        TYPE flag
                ev_lock_user TYPE sy-uname.

    METHODS get_effective_begda
      IMPORTING iv_begda        TYPE datum OPTIONAL
      RETURNING VALUE(rv_begda) TYPE datum.

    METHODS get_effective_endda
      IMPORTING iv_endda        TYPE datum OPTIONAL
      RETURNING VALUE(rv_endda) TYPE datum.

    METHODS read_relation
      IMPORTING iv_subty      TYPE subty OPTIONAL
                iv_requ_otype TYPE otype OPTIONAL
                iv_check_auth TYPE flag  DEFAULT abap_true
                iv_with_adata TYPE flag  DEFAULT abap_true
                iv_begda      TYPE begda OPTIONAL
                iv_endda      TYPE endda OPTIONAL
      EXPORTING et_p1001      TYPE p1001_t
                ev_objid      TYPE hrobjid
      RETURNING VALUE(ro_obj) TYPE REF TO zcl_hcm_om_obj.

    METHODS dequeue.

    METHODS read_object
      IMPORTING iv_check_auth TYPE flag DEFAULT 'X'
      EXPORTING ev_begda      TYPE begda
                ev_endda      TYPE endda
                ev_stext      TYPE csequence
                ev_short      TYPE csequence.

    CLASS-METHODS get_instance
      IMPORTING iv_objid         TYPE hrobjid
                iv_otype         TYPE otype
                iv_begda         TYPE begda DEFAULT sy-datum
                iv_endda         TYPE endda DEFAULT sy-datum
                iv_plvar         TYPE plvar OPTIONAL
                iv_valid         TYPE flag  OPTIONAL
      EXPORTING ev_exist         TYPE flag
      RETURNING VALUE(ro_object) TYPE REF TO zcl_hcm_om_obj.

    METHODS read_rh_infotype
      IMPORTING iv_check_auth TYPE flag      DEFAULT 'X'
                iv_infty      TYPE infty
                iv_subty      TYPE subty     OPTIONAL
                iv_begda      TYPE begda     OPTIONAL
                iv_endda      TYPE endda     OPTIONAL
                iv_authority  TYPE abap_bool DEFAULT abap_false
      EXPORTING es_pnnnn      TYPE any
                et_pnnnn      TYPE STANDARD TABLE.

    "! <p class="shorttext synchronized" lang="ru">Путь анализа</p>
    METHODS read_wegid
      IMPORTING iv_wegid      TYPE wegid         OPTIONAL
                iv_depth      TYPE hrrhas-tdepth DEFAULT 0
                iv_requ_otype TYPE otype         OPTIONAL
                iv_check_auth TYPE flag          DEFAULT abap_true
                iv_with_adata TYPE flag          OPTIONAL
                iv_include_me TYPE flag          OPTIONAL
                iv_begda      TYPE datum         OPTIONAL
                iv_endda      TYPE datum         OPTIONAL
      EXPORTING et_struc      TYPE struc_t
                et_objec      TYPE objec_t
                et_actor      TYPE tswhactor.

    METHODS read_description
      IMPORTING iv_subty        TYPE subtyp   DEFAULT '0001'
                iv_langu        TYPE sy-langu DEFAULT sy-langu
                iv_with_1002    TYPE flag     DEFAULT abap_true
                iv_check_auth   TYPE flag     DEFAULT abap_true
                iv_skip_1000    TYPE flag     OPTIONAL
                iv_line_spl     TYPE flag     OPTIONAL
      RETURNING VALUE(rv_descr) TYPE string.

    METHODS read_rh_tab_infotype
      IMPORTING iv_infty      TYPE infty
                iv_subty      TYPE subty OPTIONAL
                iv_check_auth TYPE flag  DEFAULT 'X'
      EXPORTING et_pnnnn      TYPE STANDARD TABLE
                et_hrtnnnn    TYPE STANDARD TABLE.

    METHODS get_head_mamanger
      IMPORTING iv_direct     TYPE abap_bool OPTIONAL
                iv_check_auth TYPE flag      DEFAULT abap_true
                iv_lang       TYPE spras     DEFAULT sy-langu
      EXPORTING ev_plans      TYPE plans
                ev_pernr      TYPE persno
                ev_fio        TYPE string
                es_struc      TYPE struc.

    METHODS get_attribute
      IMPORTING iv_scenario   TYPE om_attrscn OPTIONAL
                iv_attrib     TYPE om_attrib
                iv_subty_1222 TYPE subty      OPTIONAL
                iv_buf        TYPE xsdboolean DEFAULT abap_true
                iv_check_auth TYPE flag       DEFAULT abap_true
      EXPORTING ev_high       TYPE om_attrval
      RETURNING VALUE(rv_low) TYPE om_attrval.

    METHODS get_attribute_begda
      IMPORTING iv_scenario   TYPE om_attrscn OPTIONAL
                iv_attrib     TYPE om_attrib
                iv_subty_1222 TYPE subty      OPTIONAL
                iv_buf        TYPE xsdboolean DEFAULT abap_true
                iv_check_auth TYPE flag       DEFAULT abap_true
      EXPORTING ev_high       TYPE om_attrval
      RETURNING VALUE(rv_low) TYPE om_attrval.

    METHODS read_orgstruc
      IMPORTING iv_more_255          TYPE flag      DEFAULT abap_true
                iv_separator         TYPE string    DEFAULT '-'
                iv_chk_abtel         TYPE boolean   DEFAULT abap_true
                iv_chk_stabs         TYPE boolean   DEFAULT abap_true
                iv_chk_1003          TYPE flag      DEFAULT abap_true
                iv_no_text           TYPE flag      DEFAULT abap_false
                iv_langu             TYPE sy-langu  DEFAULT sy-langu
                iv_hide_top_n_levels TYPE int4      DEFAULT 0
                iv_authority         TYPE abap_bool DEFAULT abap_false
      EXPORTING et_struc             TYPE ty_orgstr_tab
                et_orgeh_struc       TYPE ty_orgeh_tab
      RETURNING VALUE(rv_struc)      TYPE string.

    METHODS read_enh_attribute
      IMPORTING iv_attrib        TYPE om_attrib
                iv_scenario      TYPE om_attrscn OPTIONAL
                iv_wegid         TYPE wegid      DEFAULT 'P-S-O-O'
                iv_check_auth    TYPE flag       DEFAULT abap_true
      RETURNING VALUE(rv_attrib) TYPE om_attrval.

    METHODS get_signer_new
      IMPORTING iv_progname           TYPE comp_programm
                iv_requ_otype         TYPE otype DEFAULT cl_hrtmc_const=>otype_orgunit
      EXPORTING ev_pernr              TYPE pernr_d
                et_pernr              TYPE pernr_tab
                et_actor              TYPE tswhactor
      RETURNING VALUE(ro_person_podp) TYPE REF TO zcl_hcm_pa_obj.

    METHODS get_t7ru9a
      IMPORTING iv_check_auth    TYPE flag      DEFAULT abap_true
                iv_authority     TYPE abap_bool DEFAULT abap_false
      RETURNING VALUE(rs_t7ru9a) TYPE t7ru9a.

    METHODS is_orgeh_member
      IMPORTING iv_objid       TYPE orgeh
                iv_wegid       TYPE wegid DEFAULT 'P-S-O-O'
      RETURNING VALUE(rv_flag) TYPE flag.

    METHODS read_orgstruc_orders
      RETURNING VALUE(rv_struc) TYPE string.

    METHODS read_greyd
      IMPORTING iv_begda      TYPE begda OPTIONAL
                iv_endda      TYPE endda OPTIONAL
                iv_check_auth TYPE flag  DEFAULT abap_true
      EXPORTING ev_trfgb      TYPE p_cpreg.

    METHODS get_easy_account_assignment
      EXPORTING ev_werks TYPE persa
                ev_btrtl TYPE btrtl_001p
                ev_bukrs TYPE bukrs.

    METHODS get_easy_attribute
      IMPORTING iv_inher     TYPE abap_bool DEFAULT abap_true
                iv_attrib    TYPE om_attrib
      EXPORTING ev_value     TYPE om_attrval
                ev_text      TYPE string
                ev_fullvalue TYPE om_attrval
                ev_attrid    TYPE zeatr_id.

    METHODS get_easy_orgstruc
      IMPORTING iv_separator    TYPE string    DEFAULT ` - `
                iv_updown       TYPE abap_bool DEFAULT abap_true
                iv_langu        TYPE sy-langu  DEFAULT sy-langu
      RETURNING VALUE(rv_struc) TYPE string.

    METHODS get_zash
      IMPORTING iv_date         TYPE begda OPTIONAL
      RETURNING VALUE(rv_solst) TYPE dec9_2.

    METHODS get_cpind
      IMPORTING iv_date         TYPE begda OPTIONAL
      RETURNING VALUE(rv_cpind) TYPE p_cpind.

    METHODS get_easy_orgstruc_table
      RETURNING VALUE(rt_struct) TYPE ty_t_struct.

    METHODS get_easy_orgstrdown
      IMPORTING iv_langu         TYPE sy-langu DEFAULT sy-langu
      RETURNING VALUE(rt_result) TYPE ty_t_orgstr.

    METHODS read_easy_relation
      IMPORTING iv_subty       TYPE subty OPTIONAL
                iv_requ_otype  TYPE otype OPTIONAL
                iv_check_auth  TYPE flag  DEFAULT abap_true
                iv_with_adata  TYPE flag  DEFAULT abap_true
                iv_using_dates TYPE flag  OPTIONAL
      EXPORTING et_p1001       TYPE p1001_t
                ev_objid       TYPE hrobjid
      RETURNING VALUE(ro_obj)  TYPE REF TO zcl_hcm_om_obj.

    METHODS get_begda
      RETURNING VALUE(rv_val) TYPE begda.

    METHODS get_endda
      RETURNING VALUE(rv_val) TYPE endda.

    METHODS get_easy_pernr_by_s
      EXPORTING et_pernr_struc TYPE ty_t_pernr_struc.

    METHODS get_easy_pernr_by_o
      EXPORTING et_pernr_struc TYPE ty_t_pernr_struc.

    METHODS get_rh_infotype
      IMPORTING iv_check_auth TYPE flag      DEFAULT 'X'
                iv_infty      TYPE infty
                iv_subty      TYPE subty     OPTIONAL
                iv_begda      TYPE begda     OPTIONAL
                iv_endda      TYPE endda     OPTIONAL
                iv_authority  TYPE abap_bool DEFAULT abap_false
      EXPORTING es_pnnnn      TYPE any
                et_pnnnn      TYPE STANDARD TABLE.

    METHODS get_rh_tab_infotype
      IMPORTING iv_infty      TYPE infty
                iv_subty      TYPE subty OPTIONAL
                iv_check_auth TYPE flag  DEFAULT 'X'
      EXPORTING et_pnnnn      TYPE STANDARD TABLE
                et_hrtnnnn    TYPE STANDARD TABLE.

    METHODS get_org_full_text
      RETURNING VALUE(rv_org_str) TYPE string.

  PROTECTED SECTION.

    DATA mv_begda TYPE begda .
    DATA mv_endda TYPE endda .
    DATA mo_lcl_easy_obj TYPE REF TO object .
  PRIVATE SECTION.
*{"AnisimovSV cache
  CLASS-DATA mt_cache_instance TYPE HASHED TABLE OF zif_type_om_obj=>ty_cache_entry_instance
    WITH UNIQUE KEY key.
  CLASS-DATA mt_cache_wegid TYPE HASHED TABLE OF zif_type_om_obj=>ty_cache_entry_wegid
    WITH UNIQUE KEY key.
  CLASS-DATA mt_cache_relation TYPE HASHED TABLE OF zif_type_om_obj=>ty_cache_entry_relation
    WITH UNIQUE KEY key.
   CLASS-DATA mt_cache_easy_relation TYPE HASHED TABLE OF zif_type_om_obj=>ty_cache_entry_easy_relation
    WITH UNIQUE KEY key.
  CLASS-DATA mt_cache_object TYPE HASHED TABLE OF zif_type_om_obj=>ty_cache_entry_object
    WITH UNIQUE KEY key.
  CLASS-DATA mt_cache_description TYPE HASHED TABLE OF zif_type_om_obj=>ty_cache_entry_description
    WITH UNIQUE KEY key.
  CLASS-DATA mt_cache_attribute TYPE HASHED TABLE OF zif_type_om_obj=>ty_cache_entry_attribute
    WITH UNIQUE KEY key.
  CLASS-DATA mt_cache_rh_infotype TYPE HASHED TABLE OF zif_type_om_obj=>ty_cache_entry_rh_infotype
    WITH UNIQUE KEY key.
  CLASS-DATA mt_cache_rh_tab_infotype TYPE HASHED TABLE OF zif_type_om_obj=>ty_cache_entry_rh_tab_infotype
    WITH UNIQUE KEY key.
  CLASS-DATA mt_cache_orgstruc TYPE HASHED TABLE OF zif_type_om_obj=>ty_cache_entry_orgstruc
    WITH UNIQUE KEY key.
  CLASS-DATA mt_cache_orgstruc_orders TYPE HASHED TABLE OF zif_type_om_obj=>ty_cache_entry_orgstruc_orders
    WITH UNIQUE KEY key.
  CLASS-DATA mt_cache_enh_attribute TYPE HASHED TABLE OF zif_type_om_obj=>ty_cache_entry_enh_attribute
    WITH UNIQUE KEY key.
  CLASS-DATA mt_cache_head_manager TYPE HASHED TABLE OF zif_type_om_obj=>ty_cache_entry_head_manager
    WITH UNIQUE KEY key.
  CLASS-DATA mt_cache_signer_new TYPE HASHED TABLE OF zif_type_om_obj=>ty_cache_entry_signer_new
    WITH UNIQUE KEY key.
  CLASS-DATA mt_cache_t7ru9a TYPE HASHED TABLE OF zif_type_om_obj=>ty_cache_entry_t7ru9a
    WITH UNIQUE KEY key.
  CLASS-DATA mt_cache_orgeh_member TYPE HASHED TABLE OF zif_type_om_obj=>ty_cache_entry_orgeh_member
    WITH UNIQUE KEY key.
  CLASS-DATA mt_cache_greyd TYPE HASHED TABLE OF zif_type_om_obj=>ty_cache_entry_greyd
    WITH UNIQUE KEY key.
  CLASS-DATA mt_cache_easy_acc TYPE HASHED TABLE OF zif_type_om_obj=>ty_cache_entry_easy_acc
    WITH UNIQUE KEY key.
  CLASS-DATA mt_cache_easy_attribute TYPE HASHED TABLE OF zif_type_om_obj=>ty_cache_entry_easy_attribute
    WITH UNIQUE KEY key.
  CLASS-DATA mt_cache_easy_orgstruc TYPE HASHED TABLE OF zif_type_om_obj=>ty_cache_entry_easy_orgstruc
    WITH UNIQUE KEY key.
  CLASS-DATA mt_cache_zash TYPE HASHED TABLE OF zif_type_om_obj=>ty_cache_entry_zash
    WITH UNIQUE KEY key.
  CLASS-DATA mt_cache_cpind TYPE HASHED TABLE OF zif_type_om_obj=>ty_cache_entry_cpind
    WITH UNIQUE KEY key.
  CLASS-DATA mt_cache_easy_orgstruc_table TYPE HASHED TABLE OF zif_type_om_obj=>ty_cache_entry_easy_orgstr_tbl
    WITH UNIQUE KEY key.
  CLASS-DATA mt_cache_easy_orgstrdown TYPE HASHED TABLE OF zif_type_om_obj=>ty_cache_entry_easy_orgstrdown
    WITH UNIQUE KEY key.
  CLASS-DATA mt_cache_easy_pernr_by_s TYPE HASHED TABLE OF zif_type_om_obj=>ty_cache_entry_easy_pernr_by_s
    WITH UNIQUE KEY key.
  CLASS-DATA mt_cache_easy_pernr_by_o TYPE HASHED TABLE OF zif_type_om_obj=>ty_cache_entry_easy_pernr_by_o
    WITH UNIQUE KEY key.
  CLASS-DATA mt_cache_org_full_text TYPE HASHED TABLE OF zif_type_om_obj=>ty_cache_entry_org_full_text
    WITH UNIQUE KEY key.


ENDCLASS.



CLASS ZCL_HCM_OM_OBJ IMPLEMENTATION.


  METHOD class_constructor.
    mv_cache_enabled = is_cache_enabled( ).
  ENDMETHOD.


  METHOD clear_cache.
    CLEAR:
*{"AnisimovSV cache
      mt_cache_instance,
      mt_cache_wegid,
      mt_cache_relation,
      mt_cache_easy_relation,
      mt_cache_object,
      mt_cache_description,
      mt_cache_attribute,
      mt_cache_rh_infotype,
      mt_cache_rh_tab_infotype,
      mt_cache_orgstruc,
      mt_cache_orgstruc_orders,
      mt_cache_enh_attribute,
      mt_cache_head_manager,
      mt_cache_signer_new,
      mt_cache_t7ru9a,
      mt_cache_orgeh_member,
      mt_cache_greyd,
      mt_cache_easy_acc,
      mt_cache_easy_attribute,
      mt_cache_easy_orgstruc,
      mt_cache_zash,
      mt_cache_cpind,
      mt_cache_easy_orgstruc_table,
      mt_cache_easy_orgstrdown,
      mt_cache_easy_pernr_by_s,
      mt_cache_easy_pernr_by_o,
      mt_cache_org_full_text.
  ENDMETHOD.


  METHOD constructor.
    ms_object-otype = iv_otype.
    ms_object-objid = iv_objid.
    mv_begda = iv_begda.
    mv_endda = iv_endda.

    ms_object-plvar = get_normalized_plvar( iv_plvar ).
    " { 3000013189 AnisimovSV 20220606
    IF iv_is_easy_run = abap_true.
      mo_lcl_easy_obj = lcl_easy_obj=>get_instance( iv_objid = CONV objid( iv_objid )
                                                    iv_otype = iv_otype
                                                    iv_begda = iv_begda
                                                    iv_endda = iv_endda
                                                    iv_plvar = ms_object-plvar ).

    ENDIF.
    " } 3000013189 AnisimovSV 20220606
  ENDMETHOD.


  METHOD dequeue.

    CALL FUNCTION 'HR_DEQUEUE_OBJECT'
      EXPORTING
        plvar            = me->ms_object-plvar
        otype            = me->ms_object-otype
        objid            = me->ms_object-objid
      EXCEPTIONS
        illegal_otype    = 1
        objid_is_initial = 2
        internal_error   = 3
        OTHERS           = 4.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

  ENDMETHOD.


  METHOD enqueue.

    ev_ok = abap_true.
    CLEAR: ev_lock_user.

    CALL FUNCTION 'HR_ENQUEUE_OBJECT'
      EXPORTING
        plvar            = me->ms_object-plvar
        otype            = me->ms_object-otype
        objid            = me->ms_object-objid
        enqueue_once     = abap_true
      IMPORTING
        lock_user        = ev_lock_user
      EXCEPTIONS
        enqueue_failed   = 1
        objid_is_initial = 2
        illegal_otype    = 3
        internal_error   = 4
        OTHERS           = 5.
    IF sy-subrc <> 0.
      ev_ok = abap_false.
    ENDIF.

  ENDMETHOD.


  METHOD get_attribute.

    DATA: lt_attrib  TYPE TABLE OF pt1222,
          ls_attrib  TYPE pt1222,
          lt_hrt1222 TYPE TABLE OF hrt1222.

    IF iv_buf = abap_true.

      CALL FUNCTION 'RH_OM_ATTRIBUTES_READ'
        EXPORTING
          plvar    = ms_object-plvar
          otype    = ms_object-otype
          objid    = ms_object-objid
          scenario = iv_scenario
          seldate  = mv_endda
        TABLES
          attrib   = lt_attrib
        EXCEPTIONS
          OTHERS   = 0.

      TRY .
          MOVE-CORRESPONDING lt_attrib[ attrib = iv_attrib  ] TO ls_attrib. "#EC CI_STDSEQ
        CATCH cx_sy_itab_line_not_found.
          RETURN.
      ENDTRY.

    ELSE.

      me->read_rh_tab_infotype(
        EXPORTING
          iv_subty      = iv_subty_1222
          iv_infty      = '1222'
          iv_check_auth = iv_check_auth
        IMPORTING
          et_hrtnnnn    = lt_hrt1222
      ).

      TRY .
          MOVE-CORRESPONDING lt_hrt1222[ attrib = iv_attrib  ] TO ls_attrib. "#EC CI_STDSEQ
        CATCH cx_sy_itab_line_not_found.
          RETURN.
      ENDTRY.

    ENDIF.

    rv_low = ls_attrib-low.
    ev_high = ls_attrib-high.

  ENDMETHOD.


  METHOD get_attribute_begda.
*Считывается доп. атрибут на дату начала mv_begda, а не на дату окончания mv_endda
    DATA: lt_attrib  TYPE TABLE OF pt1222,
          ls_attrib  TYPE pt1222,
          lt_hrt1222 TYPE TABLE OF hrt1222.

    IF iv_buf = abap_true.

      CALL FUNCTION 'RH_OM_ATTRIBUTES_READ'
        EXPORTING
          plvar    = ms_object-plvar
          otype    = ms_object-otype
          objid    = ms_object-objid
          scenario = iv_scenario
          seldate  = mv_begda
        TABLES
          attrib   = lt_attrib
        EXCEPTIONS
          OTHERS   = 0.

      TRY .
          MOVE-CORRESPONDING lt_attrib[ attrib = iv_attrib  ] TO ls_attrib. "#EC CI_STDSEQ
        CATCH cx_sy_itab_line_not_found.
          RETURN.
      ENDTRY.

    ELSE.

      me->read_rh_tab_infotype(
        EXPORTING
          iv_subty      = iv_subty_1222
          iv_infty      = '1222'
          iv_check_auth = iv_check_auth
        IMPORTING
          et_hrtnnnn    = lt_hrt1222
      ).

      TRY .
          MOVE-CORRESPONDING lt_hrt1222[ attrib = iv_attrib  ] TO ls_attrib. "#EC CI_STDSEQ
        CATCH cx_sy_itab_line_not_found.
          RETURN.
      ENDTRY.

    ENDIF.

    rv_low = ls_attrib-low.
    ev_high = ls_attrib-high.

  ENDMETHOD.


  METHOD get_begda.
    rv_val = mv_begda.
  ENDMETHOD.


  METHOD get_cpind.
    DATA lv_dt TYPE begda.
    DATA lt_1005 TYPE TABLE OF p1005.
    IF iv_date IS INITIAL.
      lv_dt = me->mv_begda.
    ELSE.
      lv_dt = iv_date.
    ENDIF.

    me->read_rh_infotype(
      EXPORTING
        iv_infty      = '1005'
        iv_begda      = lv_dt
        iv_endda      = lv_dt
      IMPORTING
        et_pnnnn      = lt_1005 ).
    LOOP AT lt_1005 INTO DATA(ls_1005)
      WHERE objid = ms_object-objid                      "#EC CI_STDSEQ
        AND begda <= lv_dt
        AND endda >= lv_dt.
    ENDLOOP.

    rv_cpind = COND p_cpind( WHEN ls_1005-cpind IS INITIAL OR ls_1005 IS INITIAL
                             THEN 'S'
                             ELSE ls_1005-cpind ).

  ENDMETHOD.


  METHOD get_easy_account_assignment.

    DATA: lo_obj TYPE REF TO lcl_easy_obj.
    CHECK mo_lcl_easy_obj IS BOUND.
    lo_obj ?= mo_lcl_easy_obj.

    DATA: lv_werks TYPE persa,
          lv_btrtl TYPE btrtl_001p,
          lv_bukrs TYPE bukrs.

    CLEAR: ev_werks,
           ev_btrtl,
           ev_bukrs.

    lo_obj->select_1008( ).

    CHECK lo_obj->mt_1008 IS NOT INITIAL.

    SORT lo_obj->mt_1008 DESCENDING BY objid begda.
    LOOP AT lo_obj->mt_structs ASSIGNING FIELD-SYMBOL(<ls_structs>).

      IF lv_werks IS INITIAL.
        lv_werks = VALUE #( lo_obj->mt_1008[ objid = <ls_structs>-objid ]-persa  OPTIONAL ). "#EC CI_STDSEQ
      ENDIF.
      IF lv_btrtl IS INITIAL.
        lv_btrtl = VALUE #( lo_obj->mt_1008[ objid = <ls_structs>-objid ]-btrtl  OPTIONAL ). "#EC CI_STDSEQ
      ENDIF.
      IF lv_bukrs IS INITIAL.
        lv_bukrs = VALUE #( lo_obj->mt_1008[ objid = <ls_structs>-objid ]-bukrs  OPTIONAL ). "#EC CI_STDSEQ
      ENDIF.
      IF lv_werks IS NOT INITIAL AND
         lv_btrtl IS NOT INITIAL AND
         lv_bukrs IS NOT INITIAL.
        EXIT.
      ENDIF.
    ENDLOOP.

    ev_werks = lv_werks.
    ev_btrtl = lv_btrtl.
    ev_bukrs = lv_bukrs.

  ENDMETHOD.


  METHOD get_easy_attribute.

    TYPES: ty_tabnr TYPE RANGE OF hrp1222-tabnr,
           ty_low   TYPE RANGE OF hrt1222-low.
    DATA: lv_value          TYPE om_attrval,
          lv_tabnr          TYPE  hrtabnr,
          lv_low            TYPE hrt1222-low,
          lv_zznamef        TYPE ztattribut-zznamef,
          lt_ztattribut_tmp TYPE TABLE OF ztattribut,
          lo_obj            TYPE REF TO lcl_easy_obj.

    CLEAR: ev_value,
           ev_text,
           ev_fullvalue,
           ev_attrid.

    CHECK mo_lcl_easy_obj IS BOUND.
    lo_obj ?= mo_lcl_easy_obj.
    CHECK iv_attrib IS NOT INITIAL.
    SELECT SINGLE
      FROM t77omattus
      FIELDS scenario
        WHERE attrib = @iv_attrib
          INTO @DATA(lv_scenario).
    CHECK lv_scenario IS NOT INITIAL.
    SELECT SINGLE
      FROM t77omattsc
      FIELDS subty
        WHERE scenario = @lv_scenario
          INTO @DATA(lv_subty).

    lo_obj->select_1222( iv_subty = lv_subty ).
    CHECK lo_obj->mt_1222 IS NOT INITIAL.

    DATA(lr_tabnr) = VALUE ty_tabnr( FOR <ls_struct> IN lo_obj->mt_1222
                                      LET lv_s = 'I'
                                            lv_o = 'EQ'
                                      IN sign = lv_s
                                           option = lv_o
                                      ( low = <ls_struct>-tabnr ) ).

    SELECT
      FROM hrt1222
        FIELDS tabnr,
               low
          WHERE attrib = @iv_attrib AND
                tabnr IN @lr_tabnr
    INTO TABLE @DATA(lt_hrt1222).

    DATA(lr_low) = VALUE ty_low( FOR <ls_hrt1222> IN lt_hrt1222
                                      LET lv_s = 'I'
                                            lv_o = 'EQ'
                                      IN sign = lv_s
                                           option = lv_o
                                      ( low = <ls_hrt1222>-low ) ).

    SELECT
     FROM ztattribut
       FIELDS *
         WHERE zzattrib = @iv_attrib AND
               zztext IN @lr_low
     ORDER BY zzendda, zzbegda DESCENDING
   INTO TABLE @DATA(lt_ztattribut).

    LOOP AT lo_obj->mt_structs ASSIGNING FIELD-SYMBOL(<ls_structs>).
      lv_low = VALUE #( lt_hrt1222[ tabnr = VALUE #( lo_obj->mt_1222[ objid = <ls_structs>-objid ]-tabnr OPTIONAL ) ]-low OPTIONAL ). "#EC CI_STDSEQ
      IF lv_low IS NOT INITIAL OR
         iv_inher = abap_false. " если abap_false, то без наследования, выходим
        EXIT.
      ENDIF.
    ENDLOOP.

    lt_ztattribut_tmp = VALUE #( FOR <ls_ztattribut> IN lt_ztattribut
                                 WHERE  ( zzbegda <= mv_endda AND "#EC CI_STDSEQ
                                          zzendda >= mv_begda AND
                                          zztext = lv_low )
                                        ( <ls_ztattribut> ) ).

    SORT lt_ztattribut_tmp DESCENDING BY zzbegda.
    lv_zznamef = VALUE #( lt_ztattribut_tmp[ 1 ]-zznamef DEFAULT VALUE #( lt_ztattribut[ zztext = lv_low ]-zznamef  OPTIONAL ) ). "#EC CI_STDSEQ

    ev_value = lv_low.
    ev_text = lv_zznamef.
    ev_attrid = VALUE #( lt_ztattribut_tmp[ 1 ]-zzid OPTIONAL ).
    ev_fullvalue = |{ lv_low } { lv_zznamef }|.

  ENDMETHOD.


  METHOD get_easy_orgstrdown.
    SELECT DISTINCT CAST( hrp1001~sobid AS NUMC( 8 ) ) AS objid, hrp1000~stext
      FROM hrp1001
      LEFT JOIN hrp1000 ON
           hrp1000~plvar EQ hrp1001~plvar
       AND hrp1000~otype EQ hrp1001~otype
       AND hrp1000~objid EQ hrp1001~sobid
       AND hrp1000~begda LE @mv_endda
       AND hrp1000~endda GE @mv_begda
       AND hrp1000~langu EQ @iv_langu
     WHERE hrp1001~otype EQ @lcl_easy_obj=>cs_name-o
       AND hrp1001~objid EQ @ms_object-objid
       AND hrp1001~plvar EQ @ms_object-plvar
       AND hrp1001~rsign EQ @lcl_easy_obj=>cs_name-rsign_b
       AND hrp1001~relat EQ @lcl_easy_obj=>cs_name-relat_o
       AND hrp1001~begda LE @mv_endda
       AND hrp1001~endda GE @mv_begda
     ORDER BY objid
      INTO CORRESPONDING FIELDS OF TABLE @rt_result.
  ENDMETHOD.


  METHOD get_easy_orgstruc.
    TYPES: ty_struct TYPE RANGE OF objid.
    DATA: lo_obj TYPE REF TO lcl_easy_obj.
    CHECK mo_lcl_easy_obj IS BOUND.
    lo_obj ?= mo_lcl_easy_obj.

    DATA lt_struct TYPE TABLE OF lo_obj->ty_struct.

    lt_struct = lo_obj->mt_structs.
    DELETE lt_struct WHERE otype <> lo_obj->cs_name-o.   "#EC CI_STDSEQ

    DATA(lr_struct) = VALUE ty_struct( FOR <ls_struct> IN lt_struct
                                        LET lv_s = 'I'
                                            lv_o = 'EQ'
                                        IN sign = lv_s
                                           option = lv_o
                                        ( low = <ls_struct>-objid ) ).

    SELECT
      FROM hrp1000
        FIELDS objid,
               stext
          WHERE
            plvar = @me->ms_object-plvar AND
            objid IN @lr_struct AND
            otype = @lo_obj->cs_name-o AND
            begda <= @mv_endda AND
            endda >= @mv_begda AND
            langu = @iv_langu
    INTO TABLE @DATA(lt_1000).

    IF iv_updown = abap_true.
      SORT lt_struct DESCENDING BY lvl.
    ELSE.
      SORT lt_struct ASCENDING BY lvl.
    ENDIF.

    rv_struc = REDUCE string( INIT lv_struct_name = ``
                              FOR <ls_struct> IN lt_struct INDEX INTO lv_i
                              FOR <ls_1000> IN lt_1000
                              WHERE ( objid = <ls_struct>-objid ) "#EC CI_STDSEQ
                              LET lv_cnt = lines( lt_struct ) IN
                              NEXT lv_struct_name = |{ lv_struct_name }{ COND #( WHEN lv_struct_name IS INITIAL
                                                                                 THEN ``
                                                                                 ELSE iv_separator ) }{ <ls_1000>-stext }| ).

  ENDMETHOD.


  METHOD get_easy_orgstruc_table.

    DATA: lo_obj TYPE REF TO lcl_easy_obj.

    CHECK mo_lcl_easy_obj IS BOUND.

    lo_obj ?= mo_lcl_easy_obj.

    rt_struct = lo_obj->mt_structs.
    DELETE rt_struct WHERE otype <> lo_obj->cs_name-o.  "#EC CI_SORTSEQ

  ENDMETHOD.


  METHOD get_easy_pernr_by_o.

    TYPES: BEGIN OF ty_s_plans_text_where,
             plans TYPE hrp1000-objid,
           END OF ty_s_plans_text_where.

    CONSTANTS: lc_subty_a008 TYPE t778u-subty VALUE 'A008'.

    DATA:
      lt_struc            TYPE STANDARD TABLE OF ty_s_pernr_struc
                          WITH NON-UNIQUE SORTED KEY person_boss
                          COMPONENTS orgeh plans pernr subty,
      lt_pernr_struc_del  TYPE ty_t_pernr_struc,
      lt_plans_text_where TYPE TABLE OF ty_s_plans_text_where.

    CLEAR:
      et_pernr_struc.

    IF   ms_object-objid IS INITIAL
      OR ms_object-otype <> cl_hrtmc_const=>otype_orgunit
      OR mv_begda IS INITIAL
      OR mv_endda IS INITIAL.
      RETURN.
    ENDIF.

    " Выборка данных к ОЕ
    SELECT orgeh~objid      AS orgeh,
           orgeh_info~stext AS orgeh_name,
           orgeh_info~langu AS orgeh_langu,
           orgeh~sobid      AS plans,
           plans_info~stext AS plans_name,
           plans_info~langu AS plans_langu,
           pernr~sobid      AS pernr,
           orgeh~subty
      INTO CORRESPONDING FIELDS OF TABLE @lt_struc
      FROM hrp1001 AS orgeh " От ОЕ к ШД
      LEFT JOIN hrp1000 AS orgeh_info ON orgeh_info~plvar  = @ms_object-plvar " Тексты к ОЕ
                                     AND orgeh_info~otype  = orgeh~otype
                                     AND orgeh_info~objid  = orgeh~objid
                                     AND orgeh_info~begda <= @mv_endda
                                     AND orgeh_info~endda >= @mv_begda
                                     AND orgeh_info~langu = @sy-langu
      LEFT JOIN hrp1000 AS plans_info ON plans_info~plvar  = @ms_object-plvar " Тексты к ШД
                                     AND plans_info~otype  = orgeh~sclas
                                     AND plans_info~objid  = orgeh~sobid
                                     AND plans_info~begda <= @mv_endda
                                     AND plans_info~endda >= @mv_begda
                                     AND plans_info~langu = @sy-langu
      LEFT JOIN hrp1001 AS pernr ON pernr~otype  = orgeh~sclas " От ШД к ТН
                                AND pernr~objid  = orgeh~sobid
                                AND pernr~plvar  = @ms_object-plvar
                                AND pernr~begda <= @mv_endda
                                AND pernr~endda >= @mv_begda
                                AND pernr~subty = @lc_subty_a008
                                AND pernr~sclas  = @cl_hrtmc_const=>otype_person
      WHERE orgeh~plvar  = @ms_object-plvar
        AND orgeh~otype  = @ms_object-otype
        AND orgeh~objid  = @ms_object-objid
        AND orgeh~sclas  = @cl_hrtmc_const=>otype_position " ШД
        AND orgeh~begda <= @mv_endda
        AND orgeh~endda >= @mv_begda
        AND (   orgeh~subty  = 'B003'    " Сотрудник
             OR orgeh~subty  = 'B012' ). " Руководитель
    IF sy-subrc = 0.

      IF sy-langu <> 'R'.

        lt_plans_text_where = VALUE #( FOR ls_struc IN lt_struc
                                       WHERE ( plans_name IS INITIAL ) "#EC CI_STDSEQ
                                       ( plans = ls_struc-plans ) ).

        SELECT objid AS orgeh,
               stext AS orgeh_name
          FROM hrp1000
          WHERE plvar = @ms_object-plvar
          AND objid = @ms_object-objid
          AND otype = @ms_object-otype
          AND begda <= @mv_endda
          AND endda >= @mv_begda
          AND langu = 'R'
          INTO TABLE @DATA(lt_orgeh_text).

        IF lt_plans_text_where IS NOT INITIAL.
          SELECT objid AS plans,
                 stext AS plans_name
            FROM hrp1000
            FOR ALL ENTRIES IN @lt_plans_text_where
            WHERE plvar = @ms_object-plvar
            AND objid = @lt_plans_text_where-plans
            AND otype = @zif_ats_const=>cs_otype-s
            AND begda <= @mv_endda
            AND endda >= @mv_begda
            AND langu = 'R'
            INTO TABLE @DATA(lt_plans_text).
        ENDIF.

      ENDIF.
    ENDIF.

    LOOP AT lt_struc ASSIGNING FIELD-SYMBOL(<ls_struc>).

      IF <ls_struc>-orgeh_langu = sy-langu AND
         <ls_struc>-orgeh_name IS NOT INITIAL.

      ENDIF.

      " Записываем данные только со связью B003
      CHECK <ls_struc>-subty = 'B003'. " Сотрудник

      APPEND CORRESPONDING #( <ls_struc> ) TO et_pernr_struc
                                           ASSIGNING FIELD-SYMBOL(<ls_pernr_struc>).

      " Проверяем нашлась ли запись со связью B012 - Руководитель
      READ TABLE lt_struc ASSIGNING FIELD-SYMBOL(<ls_struc_boss>)
                          WITH KEY person_boss
                          COMPONENTS orgeh = <ls_struc>-orgeh
                                     plans = <ls_struc>-plans
                                     pernr = <ls_struc>-pernr
                                     subty = 'B012'. " Руководитель
      IF sy-subrc = 0.
        " Если ТН руководитель - ставим флаг
        <ls_pernr_struc>-boss = abap_true.
      ENDIF.

    ENDLOOP.

    IF sy-langu <> 'R'.

      LOOP AT et_pernr_struc ASSIGNING <ls_pernr_struc>.

        IF <ls_pernr_struc>-orgeh_name IS INITIAL.
          ASSIGN lt_orgeh_text[ orgeh = <ls_pernr_struc>-orgeh ] TO FIELD-SYMBOL(<ls_orgeh_text>). "#EC CI_STDSEQ
          IF sy-subrc = 0.
            <ls_pernr_struc>-orgeh_name = <ls_orgeh_text>-orgeh_name.
          ENDIF.
        ENDIF.

        IF <ls_pernr_struc>-plans_name IS INITIAL.
          ASSIGN lt_plans_text[ plans = <ls_pernr_struc>-plans ] TO FIELD-SYMBOL(<ls_plans_text>). "#EC CI_STDSEQ
          IF sy-subrc = 0.
            <ls_pernr_struc>-plans_name = <ls_plans_text>-plans_name.
          ENDIF.
        ENDIF.

      ENDLOOP.

    ENDIF.

  ENDMETHOD.


  METHOD get_easy_pernr_by_s.

    TYPES:
      BEGIN OF ty_s_orgeh,
        orgeh TYPE hrp1001-sobid,
      END OF ty_s_orgeh,

      BEGIN OF ty_s_plans,
        plans TYPE hrp1000-objid,
      END OF ty_s_plans.

    DATA:
      lv_level         TYPE i,
      lv_orgeh_exists  TYPE flag,
      lt_orgstruc      TYPE zcl_hcm_om_obj=>ty_t_struct,
      lt_orgeh         TYPE SORTED TABLE OF hrp1000-objid WITH UNIQUE KEY table_line,
      lt_orgeh_all     TYPE SORTED TABLE OF hrp1000-objid WITH UNIQUE KEY table_line,
      lt_orgeh_manager TYPE SORTED TABLE OF hrp1000-objid WITH UNIQUE KEY table_line,
      lt_plans         TYPE SORTED TABLE OF hrp1000-objid WITH UNIQUE KEY table_line,
      lt_plans_manager TYPE SORTED TABLE OF hrp1000-objid WITH UNIQUE KEY table_line,
      lt_orgeh_search  TYPE STANDARD TABLE OF ty_s_orgeh,
      lt_struc         TYPE STANDARD TABLE OF ty_s_pernr_struc
                         WITH NON-UNIQUE SORTED KEY person_boss
                              COMPONENTS orgeh
                                         plans
                                         pernr
                                         subty,
      lt_struc_down    TYPE STANDARD TABLE OF ty_s_pernr_struc
                         WITH NON-UNIQUE SORTED KEY manager
                         COMPONENTS orgeh subty
                         WITH NON-UNIQUE SORTED KEY person_boss
                              COMPONENTS orgeh
                                         plans
                                         pernr
                                         subty,
      lv_bukrs_orgeh   TYPE bukrs.

    CLEAR:
      et_pernr_struc.

    IF   ms_object-objid IS INITIAL
      OR ms_object-otype <> cl_hrtmc_const=>otype_position
      OR mv_begda IS INITIAL
      OR mv_endda IS INITIAL.
      RETURN.
    ENDIF.

    DATA(lo_obj) = NEW zcl_hcm_om_obj(
                         iv_objid = ms_object-objid
                         iv_otype = ms_object-otype
                         iv_begda = mv_begda
                         iv_endda = mv_endda
                         iv_plvar = ms_object-plvar
                         iv_is_easy_run = abap_true ).

    " БЕ к ШД
    lo_obj->get_easy_account_assignment(
              IMPORTING
                ev_bukrs = DATA(lv_bukrs) ).

    " Ищем орг.единицы, которыми руководит переданная ШД
    SELECT DISTINCT orgeh~sobid AS orgeh
      INTO CORRESPONDING FIELDS OF TABLE @lt_orgeh_search
      FROM hrp1001 AS orgeh " Выборка от ШД к ОЕ
      WHERE orgeh~plvar  = @ms_object-plvar
        AND orgeh~otype  = @ms_object-otype
        AND orgeh~objid  = @ms_object-objid
        AND orgeh~istat  = '1'
        AND orgeh~sclas  = @cl_hrtmc_const=>otype_orgunit " Орг.единица
        AND orgeh~begda <= @mv_endda
        AND orgeh~endda >= @mv_begda
        AND orgeh~subty  = 'A012'. " Руководитель

    " Записываем найденные ОЕ в общий список всех ОЕ,
    " и в список ОЕ, по которым будет поиск данных и нижестоящих ОЕ
    LOOP AT lt_orgeh_search ASSIGNING FIELD-SYMBOL(<ls_orgeh_search>).

      " Инстанция класса для поиска БЕ к ОЕ
      lo_obj = NEW zcl_hcm_om_obj(
                     iv_objid = CONV #( <ls_orgeh_search>-orgeh )
                     iv_otype = cl_hrtmc_const=>otype_orgunit
                     iv_begda = mv_begda
                     iv_endda = mv_endda
                     iv_plvar = ms_object-plvar
                     iv_is_easy_run = abap_true ).

      CHECK lo_obj IS BOUND.

      " Ищем БЕ к ОЕ
      lo_obj->get_easy_account_assignment(
                IMPORTING
                  ev_bukrs = lv_bukrs_orgeh ).

      CHECK lv_bukrs_orgeh = lv_bukrs.

      INSERT CONV #( <ls_orgeh_search>-orgeh ) INTO TABLE lt_orgeh.
      INSERT CONV #( <ls_orgeh_search>-orgeh ) INTO TABLE lt_orgeh_all.
    ENDLOOP.

    " Поиск данных по нижестоящим ОЕ
    DO 100 TIMES.
      CLEAR:
        lt_struc_down,
        lt_orgeh_search.

      lv_level = lv_level + 1.

      " Проверяем есть ли ОЕ для поиска данных
      IF lt_orgeh IS NOT INITIAL.
        " Ищем ШД и ТН от ОЕ
        SELECT org_plans~objid AS orgeh,
               org_plans~sobid AS plans,
               pernr~sobid     AS pernr,
               org_plans~subty
          INTO CORRESPONDING FIELDS OF TABLE @lt_struc_down
          FROM hrp1001 AS org_plans " Ищем ШД к ОЕ
          LEFT JOIN hrp1001 AS pernr ON pernr~otype  = org_plans~sclas " От ШД к ТН
                                    AND pernr~objid  = org_plans~sobid
                                    AND pernr~plvar  = @ms_object-plvar
                                    AND pernr~begda <= @mv_endda
                                    AND pernr~endda >= @mv_begda
                                    AND pernr~subty  = 'A008'
                                    AND pernr~sclas  = @cl_hrtmc_const=>otype_person " ТН
          FOR ALL ENTRIES IN @lt_orgeh
          WHERE org_plans~otype  = @cl_hrtmc_const=>otype_orgunit " От ОЕ
            AND org_plans~objid  = @lt_orgeh-table_line
            AND org_plans~plvar  = @ms_object-plvar
            AND (  org_plans~subty  = 'B003'   " Сотрудник
                OR org_plans~subty  = 'B012' ) " Руководитель
            AND org_plans~istat  = '1'
            AND org_plans~sclas  = @cl_hrtmc_const=>otype_position " К ШД
            AND org_plans~begda <= @mv_endda
            AND org_plans~endda >= @mv_begda.
      ELSE.
        " Нет ОЕ для поиска - выход из цикла
        EXIT. " Из DO
      ENDIF.

      " Записываем найденные данные
      LOOP AT lt_struc_down ASSIGNING FIELD-SYMBOL(<ls_struc_down>)
                            GROUP BY ( orgeh = <ls_struc_down>-orgeh )
                            REFERENCE INTO DATA(lr_orgeh).

        " Удаляем ОЕ если она нашлась
        " Если к ОЕ данных не нашлось, то здесь мы её не удалим,
        " и тогда будет поиск нижестоящих ОЕ к ней
        READ TABLE lt_orgeh TRANSPORTING NO FIELDS
                            WITH TABLE KEY table_line = lr_orgeh->orgeh.
        IF sy-subrc = 0.
          DELETE lt_orgeh INDEX sy-tabix.
        ENDIF.

        " Проверяем есть ли руководитель к ШД
        LOOP AT lt_struc_down TRANSPORTING NO FIELDS     "#EC CI_NESTED
                              USING KEY manager
                              WHERE orgeh = lr_orgeh->orgeh
                                AND subty = 'B012'
                                AND pernr IS NOT INITIAL.
          EXIT.
        ENDLOOP.

        " Если руководителя нет, или это первая иттерация(ОЕ к переданной ШД),
        " то записываем данные
        IF   sy-subrc <> 0 " Не нашли руководителя
          OR lv_level = 1. " Первую иттерацию (по переданной ШД) пропускаем

          LOOP AT GROUP lr_orgeh ASSIGNING <ls_struc_down>.

            " Записываем только данные по сотрудникам
            " Запись B012 без ТН, которая будет в списке, пропускаем
            IF <ls_struc_down>-subty = 'B003'.

              " Записываем данные в выходную таблицу
              APPEND CORRESPONDING #( <ls_struc_down> ) TO et_pernr_struc.

              " Записываем ШД для поиска текстов
              INSERT CONV #( <ls_struc_down>-plans ) INTO TABLE lt_plans.
            ENDIF.

            " Записываем ОЕ для поиска нижестоящих ОЕ
            " Записываем независимо от связи,
            " т.к. на ОЕ может числиться только руководитель

            INSERT CONV #( <ls_struc_down>-orgeh ) INTO TABLE lt_orgeh.
            " Записываем ОЕ в общий список
            INSERT CONV #( <ls_struc_down>-orgeh ) INTO TABLE lt_orgeh_all.
          ENDLOOP.

        ELSE.
          " Если нашлись руководители, то записываем их, а не сотрудников
          " После сбора всех данных проверим, что по связи 003 руководители
          " относятся к структуре переданной ШД,
          " и, если не относятся, удалим из выходных данных
          LOOP AT lt_struc_down ASSIGNING FIELD-SYMBOL(<ls_org_manager>) "#EC CI_NESTED
                                USING KEY manager
                                WHERE orgeh = lr_orgeh->orgeh
                                  AND subty = 'B012'.
            APPEND CORRESPONDING #( <ls_org_manager> ) TO et_pernr_struc.
            " ШД для поиска текстов
            INSERT CONV #( <ls_org_manager>-plans ) INTO TABLE lt_plans.
            " ШД для поиска к каким ОЕ присвоены ШД по связи A003
            INSERT CONV #( <ls_org_manager>-plans ) INTO TABLE lt_plans_manager.
          ENDLOOP.

        ENDIF.

      ENDLOOP.

      IF lt_orgeh IS NOT INITIAL.
        " Ищем нижестоящие ОЕ к найденным ОЕ
        SELECT DISTINCT org_down~sobid AS orgeh
          INTO CORRESPONDING FIELDS OF TABLE @lt_orgeh_search
          FROM hrp1001 AS org_down " Ищем нижестоящие ОЕ к ОЕ
          FOR ALL ENTRIES IN @lt_orgeh
          WHERE org_down~otype  = @cl_hrtmc_const=>otype_orgunit " От ОЕ
            AND org_down~objid  = @lt_orgeh-table_line
            AND org_down~plvar  = @ms_object-plvar
            AND org_down~rsign  = @lcl_easy_obj=>cs_name-rsign_b
            AND org_down~relat  = @lcl_easy_obj=>cs_name-relat_o
            AND org_down~istat  = '1'
            AND org_down~sclas  = @cl_hrtmc_const=>otype_orgunit " К ОЕ
            AND org_down~begda <= @mv_endda
            AND org_down~endda >= @mv_begda.
        IF sy-subrc <> 0.
          EXIT. " Из DO
        ENDIF.
      ENDIF.

      " Очищаем таблицу ОЕ для сбора новых ОЕ
      CLEAR:
        lt_orgeh.

      " Записываем нижестоящие ОЕ в ключевую таблицу для поиска данных
      LOOP AT lt_orgeh_search ASSIGNING <ls_orgeh_search>.
        " Инстанция класса для поиска БЕ к ОЕ
        lo_obj = NEW zcl_hcm_om_obj(
                       iv_objid = CONV #( <ls_orgeh_search>-orgeh )
                       iv_otype = cl_hrtmc_const=>otype_orgunit
                       iv_begda = mv_begda
                       iv_endda = mv_endda
                       iv_plvar = ms_object-plvar
                       iv_is_easy_run = abap_true ).

        CHECK lo_obj IS BOUND.

        " Ищем БЕ к ОЕ
        lo_obj->get_easy_account_assignment(
                  IMPORTING
                    ev_bukrs = lv_bukrs_orgeh ).

        " Пропускаем ОЕ, если к ней не нашлась ОЕ,
        " или если БЕ ОЕ отличается от ОЕ ШД
        CHECK lv_bukrs_orgeh IS NOT INITIAL
          AND lv_bukrs_orgeh = lv_bukrs.

        INSERT CONV #( <ls_orgeh_search>-orgeh ) INTO TABLE lt_orgeh.
      ENDLOOP.

    ENDDO.

    " Удаляем данные по переданной ШД
    DELETE et_pernr_struc WHERE plans = ms_object-objid. "#EC CI_STDSEQ

    " Ищем к каким ОЕ присвоены найденные руководители
    IF lt_plans_manager IS NOT INITIAL.
      SELECT hrp1001~objid AS plans,
             hrp1000~objid,
             hrp1000~stext,
             hrp1000~langu
        INTO TABLE @DATA(lt_orgeh_manager_text)
        FROM hrp1001 " От ШД к ОЕ
        LEFT JOIN hrp1000 ON hrp1000~otype = hrp1001~sclas
                         AND hrp1000~objid = hrp1001~sobid
                         AND hrp1000~plvar = @ms_object-plvar
                         AND hrp1000~istat = '1'
                         AND hrp1000~begda <= @mv_endda
                         AND hrp1000~endda >= @mv_begda
                         AND ( hrp1000~langu = @sy-langu OR
                               hrp1000~langu = 'R' )
        FOR ALL ENTRIES IN @lt_plans_manager
        WHERE hrp1001~otype = 'S'
          AND hrp1001~objid = @lt_plans_manager-table_line
          AND hrp1001~plvar = @ms_object-plvar
          AND hrp1001~rsign = 'A'
          AND hrp1001~relat = '003'
          AND hrp1001~istat  = '1'
          AND hrp1001~begda <= @mv_endda
          AND hrp1001~endda >= @mv_begda
          AND hrp1001~sclas  = @cl_hrtmc_const=>otype_orgunit.
    ENDIF.

    SORT lt_orgeh_manager_text BY plans langu.

    " Проверяем какие менеджеры присвоены структуре основной ШД по связи 003
    LOOP AT et_pernr_struc ASSIGNING FIELD-SYMBOL(<ls_pernr_struc>)
                           WHERE subty = 'B012'.         "#EC CI_STDSEQ
      CLEAR:
        lt_orgstruc,
        lv_orgeh_exists,
        <ls_pernr_struc>-orgeh_name.

      " Класс для сбора орг.структуры ШД
      DATA(lo_om_obj) = NEW zcl_hcm_om_obj(
        iv_objid       = CONV #( <ls_pernr_struc>-plans )
        iv_otype       = cl_hrtmc_const=>otype_position
        iv_begda       = mv_begda
        iv_endda       = mv_endda
        iv_is_easy_run = abap_true
    ).
      IF lo_om_obj IS BOUND.
        " Записываем орг.структуру
        lt_orgstruc = lo_om_obj->get_easy_orgstruc_table( ).
      ENDIF.

      " Проверяем, что хотя бы одна ОЕ в структуре руководителя
      " находится под руководством у переданной ШД
      LOOP AT lt_orgstruc ASSIGNING FIELD-SYMBOL(<ls_orgstruc>). "#EC CI_NESTED
        READ TABLE lt_orgeh_all TRANSPORTING NO FIELDS
                                WITH TABLE KEY table_line = <ls_orgstruc>-objid.
        CHECK sy-subrc = 0.
        lv_orgeh_exists = abap_true.
        EXIT.
      ENDLOOP.

      " Если ни одна ОЕ не под руководством переданной ШД,
      " то удаляем запись руководителя
      IF lv_orgeh_exists = abap_false.
        DELETE et_pernr_struc.
        CONTINUE.
      ENDIF.

      " Определяем к какой ОЕ присвоена ШД руководителя по связи A003
      READ TABLE lt_orgeh_manager_text ASSIGNING FIELD-SYMBOL(<ls_orgeh_manager_text>)
                                       WITH KEY plans = <ls_pernr_struc>-plans
                                                langu = sy-langu
                                       BINARY SEARCH.
      IF sy-subrc = 0.
        <ls_pernr_struc>-orgeh      = <ls_orgeh_manager_text>-objid.
        <ls_pernr_struc>-orgeh_name = <ls_orgeh_manager_text>-stext.
      ENDIF.

      IF sy-langu <> 'R' AND
         <ls_pernr_struc>-orgeh_name IS INITIAL.
        READ TABLE lt_orgeh_manager_text ASSIGNING <ls_orgeh_manager_text>
                                       WITH KEY plans = <ls_pernr_struc>-plans
                                                langu = 'R'
                                       BINARY SEARCH.
        IF sy-subrc = 0.
          <ls_pernr_struc>-orgeh      = <ls_orgeh_manager_text>-objid.
          <ls_pernr_struc>-orgeh_name = <ls_orgeh_manager_text>-stext.
        ENDIF.
      ENDIF.

      " Записываем ОЕ руководителя для поиска текстов
      INSERT CONV #( <ls_pernr_struc>-orgeh ) INTO TABLE lt_orgeh_manager.

    ENDLOOP.

    SORT et_pernr_struc BY orgeh plans pernr.
    DELETE ADJACENT DUPLICATES FROM et_pernr_struc COMPARING orgeh plans pernr.

    LOOP AT lt_orgeh_manager ASSIGNING FIELD-SYMBOL(<lv_orgeh_manager>).
      INSERT <lv_orgeh_manager> INTO TABLE lt_orgeh_all.
    ENDLOOP.

    " Тексты к ОЕ
    IF lt_orgeh_all IS NOT INITIAL.
      SELECT objid,
             stext,
             langu
        INTO TABLE @DATA(lt_orgeh_text)
        FROM hrp1000
        FOR ALL ENTRIES IN @lt_orgeh_all
        WHERE plvar  = @ms_object-plvar
          AND otype  = @cl_hrtmc_const=>otype_orgunit
          AND objid  = @lt_orgeh_all-table_line
          AND istat  = '1'
          AND begda <= @mv_endda
          AND endda >= @mv_begda
          AND ( langu = @sy-langu OR
                langu = 'R' ).
    ENDIF.

    " Тексты к ШД
    IF lt_plans IS NOT INITIAL.
      SELECT objid,
             stext,
             langu
        INTO TABLE @DATA(lt_plans_text)
        FROM hrp1000
        FOR ALL ENTRIES IN @lt_plans
        WHERE plvar  = @ms_object-plvar
          AND otype  = @cl_hrtmc_const=>otype_position
          AND objid  = @lt_plans-table_line
          AND istat  = '1'
          AND begda <= @mv_endda
          AND endda >= @mv_begda
          AND ( langu = @sy-langu OR
                langu = 'R' ).
    ENDIF.

    SORT lt_orgeh_text BY objid langu.
    SORT lt_plans_text BY objid langu.

    " Запись текстов ОЕ и ШД
    LOOP AT et_pernr_struc ASSIGNING <ls_pernr_struc>.

      READ TABLE lt_orgeh_text ASSIGNING FIELD-SYMBOL(<ls_orgeh_text>)
                               WITH KEY objid = <ls_pernr_struc>-orgeh
                                        langu = sy-langu
                               BINARY SEARCH.
      IF sy-subrc = 0.
        <ls_pernr_struc>-orgeh_name = <ls_orgeh_text>-stext.
      ENDIF.

      IF sy-langu <> 'R' AND
         <ls_pernr_struc>-orgeh_name IS INITIAL.
        READ TABLE lt_orgeh_text ASSIGNING <ls_orgeh_text>
                               WITH KEY objid = <ls_pernr_struc>-orgeh
                                        langu = 'R'
                               BINARY SEARCH.
        IF sy-subrc = 0.
          <ls_pernr_struc>-orgeh_name = <ls_orgeh_text>-stext.
        ENDIF.
      ENDIF.

      READ TABLE lt_plans_text ASSIGNING FIELD-SYMBOL(<ls_plans_text>)
                               WITH KEY objid = <ls_pernr_struc>-plans
                                        langu = sy-langu
                               BINARY SEARCH.
      IF sy-subrc = 0.
        <ls_pernr_struc>-plans_name = <ls_plans_text>-stext.
      ENDIF.

      IF sy-langu <> 'R' AND
         <ls_pernr_struc>-plans_name IS INITIAL.
        READ TABLE lt_plans_text ASSIGNING <ls_plans_text>
                               WITH KEY objid = <ls_pernr_struc>-plans
                                        langu = 'R'
                               BINARY SEARCH.
        IF sy-subrc = 0.
          <ls_pernr_struc>-plans_name = <ls_plans_text>-stext.
        ENDIF.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.


  METHOD get_effective_begda.
    rv_begda = COND datum(
                 WHEN iv_begda IS INITIAL
                 THEN mv_begda
                 ELSE iv_begda ).
  ENDMETHOD.


  METHOD get_effective_endda.
    rv_endda = COND datum(
                 WHEN iv_endda IS INITIAL
                 THEN mv_endda
                 ELSE iv_endda ).
  ENDMETHOD.


  METHOD get_endda.
    rv_val = mv_endda.
  ENDMETHOD.


  METHOD get_head_mamanger.

    DATA: lt_object    TYPE TABLE OF hrobject,
          lt_res_objec TYPE TABLE OF objec,
          lt_struc     TYPE STANDARD TABLE OF struc
          .

    IF iv_direct IS INITIAL.
      CALL FUNCTION 'RH_GET_LEADING_POSITION'
        EXPORTING
          plvar            = ms_object-plvar
          otype            = ms_object-otype
          sobid            = CONV sobid( ms_object-objid )
          date             = mv_endda
          auth             = ''
          consider_vac_pos = ' '
        TABLES
          leading_pos      = lt_object
        EXCEPTIONS
          OTHERS           = 0.

      ASSIGN lt_object[ otype = 'S' ] TO FIELD-SYMBOL(<ls_object>). "#EC CI_STDSEQ
      IF sy-subrc = 0.
        ev_plans = <ls_object>-objid.
      ENDIF.

      IF ev_pernr IS SUPPLIED OR ev_fio IS SUPPLIED AND ev_plans IS NOT INITIAL.
        SELECT sobid UP TO 1 ROWS " HANA LapshovIA 01.09.2021
          INTO @DATA(lv_sobid) FROM hrp1001
          WHERE otype = 'S'
            AND objid = @ev_plans
            AND plvar = @ms_object-plvar
            AND rsign = 'A'
            AND relat = '008'
            AND begda <= @mv_endda
            AND endda >= @mv_begda
          ORDER BY PRIMARY KEY. " HANA LapshovIA 01.09.2021
        ENDSELECT.
        ev_pernr = lv_sobid.
      ENDIF.

    ELSE.
      CLEAR es_struc.
      CALL FUNCTION 'RH_STRUC_GET'
        EXPORTING
          act_otype       = ms_object-otype
          act_objid       = ms_object-objid
          act_wegid       = 'BOSSONLY'
          act_plvar       = ms_object-plvar
          act_begda       = mv_endda
          act_endda       = mv_endda
          authority_check = iv_check_auth
        TABLES
          result_objec    = lt_res_objec
          result_struc    = lt_struc
        EXCEPTIONS
          OTHERS          = 3.

      LOOP AT lt_struc ASSIGNING FIELD-SYMBOL(<ls_struc>) WHERE vprozt > 0 AND otype = 'P'. "#EC CI_STDSEQ
        es_struc = <ls_struc>.
      ENDLOOP.

      ASSIGN lt_res_objec[ otype = 'S' ] TO FIELD-SYMBOL(<ls_res_objec>). "#EC CI_STDSEQ
      IF sy-subrc = 0.
        ev_plans = <ls_res_objec>-objid.
      ENDIF.

      IF ev_pernr IS SUPPLIED OR ev_fio IS SUPPLIED.
        LOOP AT lt_struc ASSIGNING <ls_struc>
          WHERE otype = cl_hrtmc_const=>otype_person     "#EC CI_STDSEQ
            AND vprozt > 0.
          ev_pernr = <ls_struc>-objid.
          EXIT.
        ENDLOOP.
        IF ev_pernr IS INITIAL.
          ev_pernr = VALUE #( lt_res_objec[              "#EC CI_STDSEQ
            otype = cl_hrtmc_const=>otype_person ]-objid OPTIONAL ).
        ENDIF.
      ENDIF.

    ENDIF.

    IF ev_fio IS SUPPLIED AND ev_pernr IS NOT INITIAL.
      DATA(lo_pernr) = zcl_hcm_pa_obj=>get_instance( iv_pernr = ev_pernr
                                                     iv_begda = mv_begda
                                                     iv_endda = mv_endda ).

      lo_pernr->mv_no_auth = COND #( WHEN iv_check_auth = abap_true THEN abap_false ELSE abap_true ).

      ev_fio = lo_pernr->get_fio( iv_lang = iv_lang ).

    ENDIF.



  ENDMETHOD.


  METHOD get_instance.
    DATA ls_key TYPE zif_type_om_obj=>ty_key_instance.

    DATA(lv_plvar) = get_normalized_plvar( iv_plvar ).

    IF mv_cache_enabled = abap_true.
      ls_key = VALUE #( objid = iv_objid
                        otype = iv_otype
                        begda = iv_begda
                        endda = iv_endda
                        plvar = lv_plvar
                        valid = iv_valid ).

      READ TABLE mt_cache_instance
           WITH TABLE KEY key = ls_key
           INTO DATA(ls_cache_instance).
      IF sy-subrc = 0.
        ro_object = ls_cache_instance-ref.
        ev_exist  = abap_true.
        RETURN.
      ENDIF.
    ENDIF.

    IF iv_valid IS NOT INITIAL.

      CASE iv_otype.
        WHEN 'P'.
          DATA lv_pernr TYPE pernr_d.

          lv_pernr = iv_objid.

          CALL FUNCTION 'P_EMPLOYEE_CHECKEXISTENCE'
            EXPORTING  object_id          = lv_pernr
                       date               = iv_begda
            EXCEPTIONS employee_not_found = 1
                       OTHERS             = 2.
          IF sy-subrc <> 0.
            RETURN.
          ENDIF.

        WHEN OTHERS.
          SELECT SINGLE @abap_true
          FROM plogi
          INTO  @DATA(lv_exists)
          WHERE plvar = @lv_plvar
            AND objid = @iv_objid
            AND otype = @iv_otype.

          IF lv_exists = abap_true.
            RETURN.
          ENDIF.
      ENDCASE.
    ENDIF.

    ro_object = NEW #( iv_objid = iv_objid
                       iv_otype = iv_otype
                       iv_begda = iv_begda
                       iv_endda = iv_endda
                       iv_plvar = iv_plvar ).

    ev_exist = abap_true.

    IF mv_cache_enabled = abap_true.
      INSERT VALUE zif_type_om_obj=>ty_cache_entry_instance( key = ls_key
                                                             ref = ro_object )
             INTO TABLE mt_cache_instance.
    ENDIF.
  ENDMETHOD.


  METHOD get_normalized_plvar.
    rv_plvar = COND plvar(
                 WHEN iv_plvar IS INITIAL
                 THEN cl_hrtmc_const=>plvar
                 ELSE iv_plvar ).
  ENDMETHOD.


  METHOD get_org_full_text.
    DATA lt_struct TYPE zcl_hcm_om_obj=>ty_orgstr_tab.
    read_orgstruc(
      IMPORTING
        et_struc             = lt_struct
    ).
    SORT lt_struct BY ind DESCENDING.
    IF lt_struct IS NOT INITIAL.
      rv_org_str = REDUCE #( INIT lv_item =  `` FOR ls_struct IN lt_struct NEXT lv_item = |{ lv_item }{ COND #( WHEN lv_item IS INITIAL THEN `` ELSE '->' ) }{ ls_struct-orgtext }| ).
    ENDIF.
  ENDMETHOD.


  METHOD get_rh_infotype.

    DATA: lr_tab TYPE REF TO data.

    FIELD-SYMBOLS: <lt_tab> TYPE STANDARD TABLE.

    CLEAR: et_pnnnn.

    IF iv_check_auth = abap_false.
      CALL FUNCTION 'RH_AUTHORITY_CHECK_OFF'.
    ENDIF.

    IF iv_begda IS INITIAL
   AND iv_endda IS INITIAL.
      DATA(lv_begda) = me->mv_begda.
      DATA(lv_endda) = me->mv_endda.
    ELSEIF iv_begda IS NOT INITIAL
       AND iv_endda IS INITIAL.
      lv_begda = iv_begda.
      lv_endda = iv_begda.
    ELSE.
      lv_begda = iv_begda.
      lv_endda = iv_endda.
    ENDIF.

    DATA(lv_strty) = `P` && iv_infty .

    CREATE DATA lr_tab TYPE TABLE OF (lv_strty).
    ASSIGN lr_tab->* TO <lt_tab>.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.
*{ 3000013189 AnisimovSV 20220426
    IF iv_authority = abap_true.
      CALL FUNCTION 'RH_READ_INFTY'
        EXPORTING
          with_stru_auth       = iv_check_auth
          plvar                = me->ms_object-plvar
          otype                = me->ms_object-otype
          objid                = me->ms_object-objid
          infty                = iv_infty
          subty                = iv_subty
          begda                = lv_begda
          endda                = lv_endda
          authority            = ''
        TABLES
          innnn                = <lt_tab>
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
    ELSE.
      CALL FUNCTION 'RH_READ_INFTY'
        EXPORTING
          with_stru_auth       = iv_check_auth
          plvar                = me->ms_object-plvar
          otype                = me->ms_object-otype
          objid                = me->ms_object-objid
          infty                = iv_infty
          subty                = iv_subty
          begda                = lv_begda
          endda                = lv_endda
        TABLES
          innnn                = <lt_tab>
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
    ENDIF.
*} 3000013189 AnisimovSV 20220426

    et_pnnnn = <lt_tab>.

    IF es_pnnnn IS REQUESTED.
      TRY.
          es_pnnnn = <lt_tab>[ 1 ].
        CATCH cx_sy_itab_line_not_found.
      ENDTRY.
    ENDIF.

    IF iv_infty = '1002'.
      FIELD-SYMBOLS: <ls_record> TYPE any,
                     <lv_fld>    TYPE any.

      LOOP AT et_pnnnn ASSIGNING <ls_record>.
        UNASSIGN <lv_fld>.
        ASSIGN COMPONENT 'LANGU' OF STRUCTURE <ls_record> TO <lv_fld>.
        IF sy-subrc = 0.
          DATA(lv_field) = CONV langu( <lv_fld> ).
          IF ( <lv_fld> <> sy-langu ).
            DELETE et_pnnnn INDEX syst-tabix.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDIF.

    IF iv_check_auth = abap_false.
      CALL FUNCTION 'RH_AUTHORITY_CHECK_ON'.
    ENDIF.

  ENDMETHOD.


  METHOD get_rh_tab_infotype.

    DATA: lo_pnnnn    TYPE REF TO data,
          lv_tab_name TYPE text30.
    FIELD-SYMBOLS: <lt_pnnnn> TYPE table.

    CLEAR: et_hrtnnnn, et_pnnnn.

    lv_tab_name = |{ 'P' }{ iv_infty }| .

    CREATE DATA lo_pnnnn TYPE TABLE OF (lv_tab_name).
    ASSIGN lo_pnnnn->* TO <lt_pnnnn>.
    IF <lt_pnnnn> IS NOT ASSIGNED.
      RETURN.
    ENDIF.

    me->get_rh_infotype( EXPORTING iv_check_auth = iv_check_auth
                                   iv_infty = iv_infty
                                   iv_subty = iv_subty
                         IMPORTING et_pnnnn = <lt_pnnnn> ).

    IF iv_check_auth = abap_false.
      CALL FUNCTION 'RH_AUTHORITY_CHECK_OFF'.
    ENDIF.

    CALL FUNCTION 'RH_READ_INFTY_TABDATA'
      EXPORTING
        infty          = iv_infty
      TABLES
        innnn          = <lt_pnnnn>
        hrtnnnn        = et_hrtnnnn
      EXCEPTIONS
        no_table_infty = 1
        innnn_empty    = 2
        nothing_found  = 3
        OTHERS         = 4.
    IF sy-subrc <> 0.
      CLEAR: et_hrtnnnn, et_pnnnn.
    ENDIF.
    et_pnnnn = <lt_pnnnn>.

    IF iv_check_auth = abap_false.
      CALL FUNCTION 'RH_AUTHORITY_CHECK_ON'.
    ENDIF.

  ENDMETHOD.


  METHOD get_signer_new.

    DATA:
      lt_p1008 TYPE STANDARD TABLE OF p1008,
      ls_zzstc TYPE zzstc,
      lv_btrtl TYPE btrtl,
      lv_werks TYPE persa,
      lv_bukrs TYPE bukrs.

    CLEAR: ev_pernr, et_pernr.

    read_wegid( EXPORTING iv_wegid = 'P-S-O-O'
                          iv_requ_otype = iv_requ_otype
                IMPORTING et_objec = DATA(lt_res) ).

    LOOP AT lt_res ASSIGNING FIELD-SYMBOL(<ls_res>).

      DATA(lo_om_objid) = zcl_hcm_om_obj=>get_instance(
                           iv_plvar = cl_hrtmc_const=>plvar
                           iv_otype = <ls_res>-otype
                           iv_objid = <ls_res>-objid ).

      lo_om_objid->read_rh_infotype( EXPORTING iv_infty      = '1008'
                                     IMPORTING et_pnnnn      = lt_p1008 ).

      TRY.
          DATA(ls_p1008) = lt_p1008[ 1 ].

          IF ls_zzstc-bukrs IS INITIAL.
            ls_zzstc-bukrs = ls_p1008-bukrs.
          ENDIF.
          IF ls_zzstc-werks IS INITIAL.
            ls_zzstc-werks = ls_p1008-persa.
          ENDIF.
          IF ls_zzstc-btrtl IS INITIAL.
            ls_zzstc-btrtl = ls_p1008-btrtl.
          ENDIF.

          IF ls_zzstc-bukrs IS NOT INITIAL AND
             ls_zzstc-werks IS NOT INITIAL AND
             ls_zzstc-btrtl IS NOT INITIAL.
            EXIT.
          ENDIF.

        CATCH cx_sy_itab_line_not_found.
          CONTINUE.
      ENDTRY.
    ENDLOOP.

    IF iv_progname IS NOT INITIAL.
      DATA(lt_res_tvarv) = zcl_tvarvc=>get_const_range_long( iv_name = zcl_hcm_values=>mc_tvarvc-feature ).

      TRY.
          ls_zzstc-zzprog_id = lt_res_tvarv[ low = CONV #( iv_progname ) ]-high. "#EC CI_STDSEQ
        CATCH cx_sy_itab_line_not_found.
      ENDTRY.
    ENDIF.

    zcl_hcm_utils=>read_feature_table( EXPORTING iv_feature  = zcl_hcm_values=>mc_feature-_zzsdr
                                                 is_struct   = ls_zzstc
                                       IMPORTING et_value    = et_actor ).

    LOOP AT et_actor ASSIGNING FIELD-SYMBOL(<ls_actor>).
      IF <ls_actor>-otype = zcl_hcm_pa_obj=>mc_actor_ruk.
        ev_pernr = <ls_actor>-objid.
      ENDIF.
      APPEND <ls_actor>-objid TO et_pernr.
    ENDLOOP.

    IF ev_pernr IS NOT INITIAL.
      ro_person_podp = zcl_hcm_pa_obj=>get_instance( iv_pernr = ev_pernr
                                                     iv_begda = me->mv_begda
                                                     iv_endda = me->mv_endda ).
    ENDIF.
  ENDMETHOD.


  METHOD get_t7ru9a.
    DATA: lt_p1008  TYPE STANDARD TABLE OF p1008,
          ls_w001p  TYPE  t001p,
          ls_struc  TYPE prumy,
          lv_temp   TYPE text30,
          lv_back   TYPE text30,
          ls_key    TYPE t7ru9a,
          lt_t7ru9a TYPE STANDARD TABLE OF t7ru9a,
          lt_struc  TYPE struc_t,
          ls_p1008  TYPE p1008.

**    <<< add ShibkovaEA - учитываем наследование
    me->read_wegid(
      EXPORTING iv_wegid = 'P-S-O-O'
                iv_check_auth = iv_check_auth
      IMPORTING et_struc = lt_struc ).
**    >>>

    LOOP AT lt_struc ASSIGNING FIELD-SYMBOL(<ls_struc>)
        WHERE otype <> cl_hrtmc_const=>otype_person.     "#EC CI_STDSEQ
      CLEAR: lt_p1008.
*{ 3000013189 AnisimovSV 20220426
      IF iv_authority = abap_true.
        CALL FUNCTION 'RH_READ_INFTY'
          EXPORTING
            plvar                = ms_object-plvar
            otype                = <ls_struc>-otype
            objid                = CONV hrobjid( <ls_struc>-objid )
            infty                = '1008'
            begda                = mv_begda
            endda                = mv_endda
            with_stru_auth       = iv_check_auth
            authority            = ''
          TABLES
            innnn                = lt_p1008
          EXCEPTIONS
            all_infty_with_subty = 1
            nothing_found        = 2
            no_objects           = 3
            wrong_condition      = 4
            wrong_parameters     = 5
            OTHERS               = 6.
        IF sy-subrc <> 0.
          CONTINUE.
        ENDIF.
      ELSE.
        CALL FUNCTION 'RH_READ_INFTY'
          EXPORTING
            plvar                = ms_object-plvar
            otype                = <ls_struc>-otype
            objid                = CONV hrobjid( <ls_struc>-objid )
            infty                = '1008'
            begda                = mv_begda
            endda                = mv_endda
            with_stru_auth       = iv_check_auth
          TABLES
            innnn                = lt_p1008
          EXCEPTIONS
            all_infty_with_subty = 1
            nothing_found        = 2
            no_objects           = 3
            wrong_condition      = 4
            wrong_parameters     = 5
            OTHERS               = 6.
        IF sy-subrc <> 0.
          CONTINUE.
        ENDIF.
      ENDIF.
*} 3000013189 AnisimovSV 20220426

      READ TABLE lt_p1008 ASSIGNING FIELD-SYMBOL(<ls_p1008>) INDEX 1.
      IF sy-subrc = 0.
        IF ls_p1008-bukrs IS INITIAL.
          ls_p1008-bukrs = <ls_p1008>-bukrs.
        ENDIF.
        IF ls_p1008-btrtl IS INITIAL.
          ls_p1008-btrtl = <ls_p1008>-btrtl.
        ENDIF.
        IF ls_p1008-persa IS INITIAL.
          ls_p1008-persa = <ls_p1008>-persa.
        ENDIF.
      ENDIF.
      IF ls_p1008-persa IS NOT INITIAL AND
         ls_p1008-btrtl IS NOT INITIAL AND
         ls_p1008-bukrs IS NOT INITIAL.
        EXIT.
      ENDIF.
    ENDLOOP.

    CALL FUNCTION 'HR_TMW_READ_T001P'
      EXPORTING
        persa          = ls_p1008-persa
        btrtl          = ls_p1008-btrtl
      IMPORTING
        w001p          = ls_w001p
      EXCEPTIONS
        no_entry_found = 1
        OTHERS         = 2.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    MOVE-CORRESPONDING ls_w001p TO ls_struc.
    ls_struc-werks = ls_p1008-persa.
    ls_struc-btrtl = ls_p1008-btrtl.
    IF ls_p1008-bukrs IS NOT INITIAL.
      ls_struc-bukrs = ls_p1008-bukrs.
    ELSE.
      ls_struc-bukrs = ls_w001p-juper.
    ENDIF.

    CALL FUNCTION 'HR_FEATURE_BACKFIELD'
      EXPORTING
        feature                     = '33OKT'
        struc_content               = ls_struc
      IMPORTING
        back                        = lv_back
      EXCEPTIONS
        dummy                       = 1
        error_operation             = 2
        no_backvalue                = 3
        feature_not_generated       = 4
        invalid_sign_in_funid       = 5
        field_in_report_tab_in_pe03 = 6
        OTHERS                      = 7.
    IF sy-subrc = 0.
      "RETURN.
      SPLIT lv_back AT '/' INTO lv_temp lv_back.
    ENDIF.

    ls_key-instl  = '000'.
    ls_key-soort = '01'.
    ls_key-juper = ls_w001p-juper.
    IF lv_back CO '0123456789 '.
      ls_key-objid = lv_back.
    ENDIF.
    ls_key-begda = mv_begda.
    ls_key-endda = mv_endda.

    CALL FUNCTION 'HR_RU_READ_T7RU9A'
      EXPORTING
        key       = ls_key
      TABLES
        result    = lt_t7ru9a
      EXCEPTIONS
        not_found = 1
        OTHERS    = 2.
    IF sy-subrc <> 0.
      CLEAR lt_t7ru9a[].
    ENDIF.

    READ TABLE lt_t7ru9a INTO  rs_t7ru9a INDEX 1.
    IF sy-subrc <> 0.
      CLEAR rs_t7ru9a.
      RETURN.
    ENDIF.
    IF rs_t7ru9a-fsscc IS INITIAL.
      rs_t7ru9a-fsscc = ls_struc-bukrs .
    ENDIF.
  ENDMETHOD.


  METHOD get_zash.
    CLEAR rv_solst.
    CHECK ms_object-otype = cl_hrpiq00const=>c_otype_s.
    DATA lv_dt TYPE begda.
    DATA lt_1013 TYPE TABLE OF p1013.
    IF iv_date IS INITIAL.
      lv_dt = me->mv_begda.
    ELSE.
      lv_dt = iv_date.
    ENDIF.

    me->read_rh_infotype(
      EXPORTING
        iv_infty      = '1013'
        iv_begda      = lv_dt
        iv_endda      = lv_dt
      IMPORTING
        et_pnnnn      = lt_1013 ).
    LOOP AT lt_1013 REFERENCE INTO DATA(lr_1013)
      WHERE objid = ms_object-objid                      "#EC CI_STDSEQ
        AND begda <= lv_dt
        AND endda >= lv_dt.
    ENDLOOP.

    mo_lcl_easy_obj = NEW lcl_easy_obj( iv_objid = CONV objid( ms_object-objid )
                                        iv_otype = ms_object-otype
                                        iv_begda = lv_dt
                                        iv_endda = lv_dt
                                        iv_plvar = ms_object-plvar ).
    get_easy_account_assignment(
      IMPORTING
        ev_werks = DATA(lv_werks)
        ev_btrtl = DATA(lv_btrtl) ).

    DATA(lv_work_schedule) = get_attribute(
                                    EXPORTING
                                       iv_attrib     = 'Z_GRAFRABV'
                                       iv_buf        = abap_true ).
    DATA(lv_exists) = find( val   = lv_work_schedule
                            regex = `[ ]` ).
    CHECK lv_exists <> 1.
    CHECK lr_1013 IS BOUND.
    SELECT SINGLE
      FROM t503
        FIELDS zeity
          WHERE
            persg = @lr_1013->persg AND
            persk = @lr_1013->persk
   INTO @DATA(lv_zeity).
    CHECK lv_zeity IS NOT INITIAL.
    SELECT SINGLE
      FROM t001p
        FIELDS  mofid,
                mosid
          WHERE werks = @lv_werks AND
                btrtl = @lv_btrtl
      INTO @DATA(ls_t001p).
    CHECK ls_t001p IS NOT INITIAL.
    SELECT SINGLE
      FROM t508a
        FIELDS  zeity,
                mofid,
                mosid,
                wostd,
                wkwdy
          WHERE
            zeity = @lv_zeity AND
            mofid = @ls_t001p-mofid AND
            mosid = @ls_t001p-mosid AND
            schkz = @lv_work_schedule
   INTO @DATA(ls_t508a).
    CHECK ls_t508a IS NOT INITIAL.
    SELECT SINGLE
      FROM t7ru80s
        FIELDS  zeity,
                mofid,
                mosid,
                schkz
          WHERE
            zeity = @ls_t508a-zeity AND
            mofid = @ls_t508a-mofid AND
            mosid = @ls_t508a-mosid AND
            nhour = @( trunc( ls_t508a-wostd ) )  AND
            atype = @( trunc( ls_t508a-wkwdy ) )
      INTO @DATA(ls_t7ru80s).
    CHECK ls_t7ru80s IS NOT INITIAL.
    cl_reca_date=>get_date_info( EXPORTING id_date = lv_dt
                                 IMPORTING ed_year = DATA(lv_year) ).
    SELECT
        FROM t552a
            FIELDS  solst
                WHERE
                    zeity = @ls_t7ru80s-zeity AND
                    mofid = @ls_t7ru80s-mofid AND
                    mosid = @ls_t7ru80s-mosid AND
                    schkz = @ls_t7ru80s-schkz AND
                    kjahr = @lv_year
    INTO TABLE @DATA(lt_solst).
    CHECK lt_solst IS NOT INITIAL.
    DATA(lv_sum) = REDUCE dec9_2(  INIT sum TYPE dec9_2
                                   FOR wa IN lt_solst
                                   NEXT sum = sum + wa-solst ).

    rv_solst = lv_sum / 12.

  ENDMETHOD.


  METHOD is_cache_enabled.
    rv_enabled = zcl_tvarvc=>get_const( 'Z_CACHE_ENABLED_OM' ).
  ENDMETHOD.


  METHOD is_orgeh_member.

    read_wegid( EXPORTING iv_wegid = iv_wegid
                          iv_requ_otype = zcl_hcm_values=>mc_otype-orgeh
                IMPORTING et_actor = DATA(lt_actor) ).

    READ TABLE lt_actor TRANSPORTING NO FIELDS           "#EC CI_STDSEQ
      WITH KEY objid = iv_objid.
    IF sy-subrc = 0.
      rv_flag = abap_true.
    ENDIF.

  ENDMETHOD.


  METHOD read_description.

    DATA: lt_pt1002    TYPE TABLE OF pt1002,
          lt_p1000     TYPE TABLE OF p1000,
          lt_langu_tab TYPE TABLE OF t002t,
          lv_langu     TYPE sy-langu.

    DATA: lt_objects TYPE TABLE OF hrobject,
          lt_p1002   TYPE TABLE OF p1002,
          lt_hrt1002 TYPE TABLE OF hrt1002.

    IF iv_with_1002 = abap_true.

      APPEND ms_object TO lt_objects.

      CALL FUNCTION 'HRIQ_READ_DESCRIPT_FOR_OBJECTS'
        EXPORTING
          language  = iv_langu
          subty     = iv_subty
          begda     = mv_endda
          endda     = mv_endda
          stru_auth = iv_check_auth
        TABLES
          objects   = lt_objects
          p1002     = lt_p1002
          hrt1002   = lt_hrt1002
        EXCEPTIONS
          OTHERS    = 0.
      IF sy-subrc <> 0.
      ENDIF.

      IF lv_langu IS NOT INITIAL AND
         lt_p1002 IS NOT INITIAL AND
         lt_p1002[ 1 ]-langu <> lv_langu.
        CLEAR lt_hrt1002.
      ENDIF.

    ENDIF.

    LOOP AT lt_hrt1002 ASSIGNING FIELD-SYMBOL(<ls_hrt1002>).
      IF rv_descr IS INITIAL.
        rv_descr = <ls_hrt1002>-tline.
      ELSE.
        IF iv_line_spl = abap_true.
          rv_descr = rv_descr && cl_abap_char_utilities=>cr_lf && <ls_hrt1002>-tline.
        ELSE.
          rv_descr = rv_descr && ` ` && <ls_hrt1002>-tline.
        ENDIF.
      ENDIF.
    ENDLOOP.

    IF rv_descr IS INITIAL AND iv_skip_1000 IS INITIAL.
      CALL FUNCTION 'RH_READ_INFTY_1000'
        EXPORTING
          plvar          = ms_object-plvar
          otype          = ms_object-otype
          objid          = ms_object-objid
          begda          = mv_begda
          endda          = mv_endda
          with_stru_auth = iv_check_auth
        TABLES
          i1000          = lt_p1000
        EXCEPTIONS
          OTHERS         = 0.

      SORT lt_p1000 BY endda DESCENDING.
      " берем значение актуальное на mv_endda
      rv_descr = VALUE #( lt_p1000[ langu = iv_langu ]-stext OPTIONAL ). "#EC CI_STDSEQ

    ENDIF.

  ENDMETHOD.


  METHOD read_easy_relation.

    CLEAR: et_p1001, ev_objid.
    IF iv_using_dates = abap_false. " PopovAS 12.04.2024 В некоторых случая нужно учитывать даты
      SELECT *
        FROM hrp1001
        WHERE plvar = @me->ms_object-plvar
        AND otype = @me->ms_object-otype
        AND objid = @me->ms_object-objid
        AND subty = @iv_subty
        INTO CORRESPONDING FIELDS OF TABLE @et_p1001.
    ELSE.
      SELECT *
        FROM hrp1001
        WHERE plvar = @me->ms_object-plvar
        AND otype = @me->ms_object-otype
        AND objid = @me->ms_object-objid
        AND subty = @iv_subty
        AND begda <= @me->mv_endda
        AND endda >= @me->mv_begda
        INTO CORRESPONDING FIELDS OF TABLE @et_p1001.
    ENDIF.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    IF iv_requ_otype IS NOT INITIAL.
      DELETE et_p1001 WHERE sclas <> iv_requ_otype.      "#EC CI_STDSEQ
      READ TABLE et_p1001 ASSIGNING FIELD-SYMBOL(<ls_p1001>) WITH KEY sclas = iv_requ_otype. "#EC CI_STDSEQ
      IF sy-subrc IS INITIAL.
        ev_objid = <ls_p1001>-sobid.
      ENDIF.
    ELSE.
      SORT et_p1001 BY endda DESCENDING.
      READ TABLE et_p1001 ASSIGNING <ls_p1001> INDEX 1.
      IF sy-subrc IS INITIAL.
        ev_objid = <ls_p1001>-sobid.
      ENDIF.
    ENDIF.

    IF ev_objid IS NOT INITIAL AND iv_requ_otype IS NOT INITIAL.
      ro_obj = get_instance(
                 iv_objid = ev_objid
                 iv_otype = iv_requ_otype
                 iv_begda = me->mv_begda
                 iv_endda = me->mv_endda
                 iv_plvar = me->ms_object-plvar
               ).
    ENDIF.

  ENDMETHOD.


  METHOD read_enh_attribute.

    me->read_wegid( EXPORTING iv_wegid = iv_wegid
                              iv_include_me = abap_true
                    IMPORTING et_actor = DATA(lt_obj) ).

    LOOP AT lt_obj ASSIGNING FIELD-SYMBOL(<fs_obj>).
      rv_attrib = zcl_hcm_om_obj=>get_instance( iv_objid = CONV #( <fs_obj>-objid )
                                                iv_otype = <fs_obj>-otype
                                                iv_begda = me->mv_begda
                                                iv_endda = me->mv_endda  )->get_attribute( iv_attrib = iv_attrib
                                                                                           iv_scenario = iv_scenario
                                                                                           iv_check_auth = iv_check_auth ).
      IF rv_attrib IS NOT INITIAL.
        EXIT.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.


  METHOD read_greyd.
    DATA: ls_p1005 TYPE p1005.

    CLEAR: ev_trfgb.

    CHECK ms_object-otype = zcl_hcm_values=>mc_otype-plans.

    DATA(lv_begda) = COND begda( WHEN iv_begda IS NOT INITIAL
                                 THEN iv_begda
                                 ELSE mv_begda ).
    DATA(lv_endda) = COND endda( WHEN iv_endda IS NOT INITIAL
                                 THEN iv_endda
                                 ELSE mv_endda ).

    me->read_rh_infotype( EXPORTING iv_check_auth = iv_check_auth
                                    iv_infty      = '1005'
                                    iv_begda      = lv_begda
                                    iv_endda      = lv_endda
                          IMPORTING es_pnnnn      = ls_p1005 ).

    ev_trfgb = ls_p1005-trfgb.

  ENDMETHOD.


  METHOD read_object.

    DATA: lv_stext TYPE p1000-stext,
          lv_short TYPE p1000-short.

    CLEAR: ev_begda, ev_endda, ev_short, ev_stext.

    IF iv_check_auth = abap_false.
      CALL FUNCTION 'RH_AUTHORITY_CHECK_OFF'.
    ENDIF.

    CALL FUNCTION 'RH_READ_OBJECT'
      EXPORTING
        plvar           = me->ms_object-plvar
        otype           = me->ms_object-otype
        objid           = me->ms_object-objid
        begda           = me->mv_begda
        endda           = me->mv_endda
        check_stru_auth = iv_check_auth
        langu           = sy-langu
      IMPORTING
        obeg            = ev_begda
        oend            = ev_endda
        short           = lv_short
        stext           = lv_stext
      EXCEPTIONS
        not_found       = 1
        OTHERS          = 2.
    IF sy-subrc <> 0.
      CLEAR: ev_begda, ev_endda, ev_short, ev_stext.
    ENDIF.

    IF iv_check_auth = abap_false.
      CALL FUNCTION 'RH_AUTHORITY_CHECK_ON'.
    ENDIF.

    ev_short = lv_short.
    ev_stext = lv_stext.

  ENDMETHOD.


  METHOD read_orgstruc.
    DATA lt_p1003 TYPE TABLE OF p1003.
    DATA lt_orgst TYPE ty_orgstr_tab.
    DATA lt_struc TYPE TABLE OF char255.

    read_wegid( EXPORTING iv_wegid      = 'P-S-O-O'
                          iv_requ_otype = 'O'
*        (SavinovaEA 27.05.2022
                          iv_check_auth = COND #( WHEN iv_authority = abap_true
                                                  THEN abap_false
                                                  ELSE abap_true )
*        )SavinovaEA 27.05.2022
                IMPORTING et_objec      = DATA(lt_res) ).

    LOOP AT lt_res ASSIGNING FIELD-SYMBOL(<fs_res>).

      DATA(lo_obj) = zcl_hcm_om_obj=>get_instance( iv_objid = <fs_res>-objid
                                                   iv_otype = <fs_res>-otype
                                                   iv_begda = mv_begda
                                                   iv_endda = mv_endda   ).

      IF iv_chk_abtel = abap_true OR iv_chk_stabs = abap_true.
        lo_obj->read_rh_infotype( EXPORTING iv_infty     = '1003'
*{ 3000013189 AnisimovSV 20220426
                                            iv_authority = iv_authority
*} 3000013189 AnisimovSV 20220426
                                  IMPORTING et_pnnnn     = lt_p1003 ).

        TRY.
            DATA(ls_p1003) = lt_p1003[ 1 ].
          CATCH cx_sy_itab_line_not_found.
            IF iv_chk_1003 = abap_true.
              CONTINUE.
              " 3000020761 Vaschenkoia 20250930
            ELSE.
              CLEAR ls_p1003.
            ENDIF.
            " 3000020761
        ENDTRY.
      ENDIF.

      IF    ls_p1003-abtel IS NOT INITIAL
         OR iv_chk_abtel    = abap_false.

        IF iv_no_text = abap_false.
          DATA(lv_text) = lo_obj->read_description(
*        (SavinovaEA 27.05.2022
            iv_check_auth = COND #( WHEN iv_authority = abap_true
                                    THEN abap_false
                                    ELSE abap_true )
*        )SavinovaEA 27.05.2022
            iv_langu      = iv_langu ).
          " (SavinovaEA 13.07.2022
        ENDIF.
        APPEND INITIAL LINE TO et_orgeh_struc ASSIGNING FIELD-SYMBOL(<fs_orgeh>).

        " )SavinovaEA 13.07.2022
        APPEND INITIAL LINE TO lt_orgst ASSIGNING FIELD-SYMBOL(<fs_orgst>).
        <fs_orgeh>-ind = lines( lt_orgst ).
        <fs_orgst>-ind = <fs_orgeh>-ind.
        <fs_orgeh>-orgtext = lv_text.
        <fs_orgst>-orgtext = <fs_orgeh>-orgtext.
        <fs_orgeh>-abtel = ls_p1003-abtel.
        <fs_orgst>-abtel = <fs_orgeh>-abtel.
        <fs_orgeh>-stabs = ls_p1003-stabs.
        <fs_orgst>-stabs = <fs_orgeh>-stabs.
        <fs_orgeh>-orgeh = <fs_res>-objid.
        CLEAR lv_text.
      ELSEIF ls_p1003-abtel IS INITIAL. " Если HRP1003-ABTEL ≠ X Krasovsliy
        " TODO: глянуть в чем фишка
        " Что тут за авторская задумка с циклом в никуда
        lo_obj->read_relation( EXPORTING iv_subty      = 'A002'
                                         iv_requ_otype = 'O'
                               IMPORTING et_p1001      = DATA(lt_1001) ).
        " TODO: variable is assigned but never used (ABAP cleaner)
        LOOP AT lt_1001 INTO DATA(ls_1001).

        ENDLOOP.
      ENDIF.

      IF iv_chk_stabs = abap_true.
        IF ls_p1003-stabs = abap_true.
          EXIT.
        ENDIF.
      ENDIF.

    ENDLOOP.

    et_struc = lt_orgst.

    SORT lt_orgst BY ind DESCENDING.

    IF iv_hide_top_n_levels IS SUPPLIED AND iv_hide_top_n_levels > 0.
      DELETE lt_orgst TO iv_hide_top_n_levels.
    ENDIF.

    LOOP AT lt_orgst ASSIGNING <fs_orgst>.
      IF rv_struc IS INITIAL.
        rv_struc = <fs_orgst>-orgtext.
      ELSE.
        rv_struc = rv_struc && iv_separator && <fs_orgst>-orgtext.
      ENDIF.
    ENDLOOP.

    IF iv_more_255 = abap_false.

      IF strlen( rv_struc ) > 255.
        zcl_hcm_utils=>string_to_table( EXPORTING iv_content  = rv_struc
                                                  iv_size     = '255'
                                        IMPORTING et_table_st = lt_struc ).
        TRY.
            rv_struc = lt_struc[ 1 ].
          CATCH cx_sy_itab_line_not_found.
            CLEAR et_struc.
        ENDTRY.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD read_orgstruc_orders.
    CONSTANTS: lc_separator TYPE text1 VALUE '-'.
    read_orgstruc( EXPORTING iv_more_255 = abap_true
                   IMPORTING et_struc = DATA(lt_struc) ).

*    SORT lt_struc BY ind DESCENDING.

    LOOP AT lt_struc ASSIGNING FIELD-SYMBOL(<ls_struc>).
      IF <ls_struc>-stabs = abap_true.
        EXIT.
      ENDIF.

      IF rv_struc IS INITIAL.
        rv_struc = <ls_struc>-orgtext.
      ELSE.
        rv_struc = <ls_struc>-orgtext && lc_separator && rv_struc.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD read_relation.

    CLEAR: et_p1001, ev_objid.

    DATA(lv_begda) = COND begda( WHEN iv_begda IS NOT INITIAL THEN iv_begda ELSE me->mv_begda ).
    DATA(lv_endda) = COND endda( WHEN iv_endda IS NOT INITIAL THEN iv_endda ELSE me->mv_endda ).

    CALL FUNCTION 'RH_READ_INFTY_1001'
      EXPORTING
        with_stru_auth   = iv_check_auth
        plvar            = me->ms_object-plvar
        otype            = me->ms_object-otype
        objid            = me->ms_object-objid
        subty            = iv_subty
        begda            = lv_begda
        endda            = lv_endda
        adata            = iv_with_adata
      TABLES
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
      DELETE et_p1001 WHERE sclas <> iv_requ_otype.      "#EC CI_STDSEQ
      READ TABLE et_p1001 ASSIGNING FIELD-SYMBOL(<ls_p1001>) WITH KEY sclas = iv_requ_otype. "#EC CI_STDSEQ
      IF sy-subrc IS INITIAL.
        ev_objid = <ls_p1001>-sobid.
      ENDIF.
    ELSE.
      SORT et_p1001 BY endda DESCENDING.
      READ TABLE et_p1001 ASSIGNING <ls_p1001> INDEX 1.
      IF sy-subrc IS INITIAL.
        ev_objid = <ls_p1001>-sobid.
      ENDIF.
    ENDIF.

    IF ev_objid IS NOT INITIAL AND iv_requ_otype IS NOT INITIAL.
      ro_obj = get_instance(
                 iv_objid = ev_objid
                 iv_otype = iv_requ_otype
                 iv_begda = lv_begda
                 iv_endda = lv_endda
                 iv_plvar = me->ms_object-plvar
               ).
    ENDIF.

  ENDMETHOD.


  METHOD read_rh_infotype.

    DATA: lr_tab TYPE REF TO data.

    FIELD-SYMBOLS: <lt_tab> TYPE STANDARD TABLE.

    CLEAR: et_pnnnn.

    IF iv_check_auth = abap_false.
      CALL FUNCTION 'RH_AUTHORITY_CHECK_OFF'.
    ENDIF.

    IF iv_begda IS INITIAL
   AND iv_endda IS INITIAL.
      DATA(lv_begda) = me->mv_begda.
      DATA(lv_endda) = me->mv_endda.
    ELSEIF iv_begda IS NOT INITIAL
       AND iv_endda IS INITIAL.
      lv_begda = iv_begda.
      lv_endda = iv_begda.
    ELSE.
      lv_begda = iv_begda.
      lv_endda = iv_endda.
    ENDIF.

    DATA(lv_strty) = `P` && iv_infty .

    CREATE DATA lr_tab TYPE TABLE OF (lv_strty).
    ASSIGN lr_tab->* TO <lt_tab>.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.
*{ 3000013189 AnisimovSV 20220426
    IF iv_authority = abap_true.
      CALL FUNCTION 'RH_READ_INFTY'
        EXPORTING
          with_stru_auth       = iv_check_auth
          plvar                = me->ms_object-plvar
          otype                = me->ms_object-otype
          objid                = me->ms_object-objid
          infty                = iv_infty
          subty                = iv_subty
          begda                = lv_begda
          endda                = lv_endda
          authority            = ''
        TABLES
          innnn                = <lt_tab>
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
    ELSE.
      CALL FUNCTION 'RH_READ_INFTY'
        EXPORTING
          with_stru_auth       = iv_check_auth
          plvar                = me->ms_object-plvar
          otype                = me->ms_object-otype
          objid                = me->ms_object-objid
          infty                = iv_infty
          subty                = iv_subty
          begda                = lv_begda
          endda                = lv_endda
        TABLES
          innnn                = <lt_tab>
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
    ENDIF.
*} 3000013189 AnisimovSV 20220426

    et_pnnnn = <lt_tab>.

    IF es_pnnnn IS REQUESTED.
      TRY.
          es_pnnnn = <lt_tab>[ 1 ].
        CATCH cx_sy_itab_line_not_found.
      ENDTRY.
    ENDIF.

    IF iv_infty = '1002'.
      FIELD-SYMBOLS: <ls_record> TYPE any,
                     <ld_fld>    TYPE any.

      LOOP AT et_pnnnn ASSIGNING <ls_record>.
        UNASSIGN <ld_fld>.
        ASSIGN COMPONENT 'LANGU' OF STRUCTURE <ls_record> TO <ld_fld>.
        IF sy-subrc = 0.
          DATA(lv) = CONV langu( <ld_fld> ).
          IF ( <ld_fld> <> sy-langu ).
            DELETE et_pnnnn INDEX syst-tabix.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDIF.

    IF iv_check_auth = abap_false.
      CALL FUNCTION 'RH_AUTHORITY_CHECK_OFF'.
    ENDIF.

  ENDMETHOD.


  METHOD read_rh_tab_infotype.

    DATA: ld_pnnnn    TYPE REF TO data,
          lv_tab_name TYPE text30.
    FIELD-SYMBOLS: <lt_pnnnn> TYPE table.

    CLEAR: et_hrtnnnn, et_pnnnn.

    lv_tab_name = |{ 'P' }{ iv_infty }| .

    CREATE DATA ld_pnnnn TYPE TABLE OF (lv_tab_name).
    ASSIGN ld_pnnnn->* TO <lt_pnnnn>.
    IF <lt_pnnnn> IS NOT ASSIGNED.
      RETURN.
    ENDIF.

    me->read_rh_infotype( EXPORTING iv_check_auth = iv_check_auth
                                    iv_infty = iv_infty
                                    iv_subty = iv_subty
                          IMPORTING et_pnnnn = <lt_pnnnn> ).

    CALL FUNCTION 'RH_READ_INFTY_TABDATA'
      EXPORTING
        infty          = iv_infty
      TABLES
        innnn          = <lt_pnnnn>
        hrtnnnn        = et_hrtnnnn
      EXCEPTIONS
        no_table_infty = 1
        innnn_empty    = 2
        nothing_found  = 3
        OTHERS         = 4.
    IF sy-subrc <> 0.
      CLEAR: et_hrtnnnn, et_pnnnn.
    ENDIF.
    et_pnnnn = <lt_pnnnn>.

  ENDMETHOD.


  METHOD read_wegid.
    DATA ls_key TYPE zif_type_om_obj=>ty_key_wegid.

    DATA(lv_begda) = get_effective_begda( iv_begda ).
    DATA(lv_endda) = get_effective_endda( iv_endda ).
    DATA lt_struc_all TYPE struc_t.
    DATA lt_objec_all TYPE objec_t.
    DATA lt_actor_all TYPE tswhactor.

    IF mv_cache_enabled = abap_true.
      ls_key = VALUE #( objid         = ms_object-objid
                        otype         = ms_object-otype
                        begda         = mv_begda
                        endda         = mv_endda
                        plvar         = ms_object-plvar
                        iv_wegid      = iv_wegid
                        iv_depth      = iv_depth
                        iv_requ_otype = iv_requ_otype
                        iv_check_auth = iv_check_auth
                        iv_with_adata = iv_with_adata
                        iv_include_me = iv_include_me
                        iv_begda      = lv_begda
                        iv_endda      = lv_endda ).

      READ TABLE mt_cache_wegid
           WITH TABLE KEY key = ls_key
           INTO DATA(ls_cache_wegid).
      IF sy-subrc = 0.
        et_struc = ls_cache_wegid-struc_t.
        et_objec = ls_cache_wegid-objec_t.
        et_actor = ls_cache_wegid-tswhactor.
        RETURN.
      ENDIF.
    ENDIF.

    IF iv_check_auth = abap_false.
      CALL FUNCTION 'RH_AUTHORITY_CHECK_OFF'.
    ENDIF.

    CALL FUNCTION 'RH_STRUC_GET'
      EXPORTING
        act_otype       = ms_object-otype
        act_objid       = ms_object-objid
        act_wegid       = iv_wegid
        act_plvar       = ms_object-plvar
        act_begda       = lv_begda
        act_endda       = lv_endda
        act_tdepth      = iv_depth
        authority_check = iv_check_auth
        act_tflag       = abap_true
        act_vflag       = COND flag(
                          WHEN iv_with_adata = abap_true
                          THEN abap_true
                          ELSE abap_false )
      TABLES
        result_struc    = lt_struc_all
        result_tab      = lt_actor_all
        result_objec    = lt_objec_all
      EXCEPTIONS
        no_plvar_found  = 1
        no_entry_found  = 2
        OTHERS          = 3.

    IF sy-subrc <> 0 AND sy-subrc <> 2.
      CLEAR:
        lt_struc_all,
        lt_actor_all,
        lt_objec_all.
    ENDIF.

    IF iv_check_auth = abap_false.
      CALL FUNCTION 'RH_AUTHORITY_CHECK_ON'.
    ENDIF.

    IF iv_include_me = abap_true.
      INSERT VALUE #( otype = ms_object-otype
                      objid = ms_object-objid ) INTO lt_actor_all INDEX 1.
    ENDIF.

    IF iv_requ_otype IS NOT INITIAL.
*      DELETE et_struc WHERE otype <> iv_requ_otype.      "#EC CI_STDSEQ
*      DELETE et_actor WHERE otype <> iv_requ_otype.      "#EC CI_STDSEQ
*      DELETE et_objec WHERE otype <> iv_requ_otype.      "#EC CI_STDSEQ

      DELETE lt_struc_all WHERE otype <> iv_requ_otype.      "#EC CI_STDSEQ
      DELETE lt_objec_all WHERE otype <> iv_requ_otype.      "#EC CI_STDSEQ
      DELETE lt_actor_all WHERE otype <> iv_requ_otype.      "#EC CI_STDSEQ
    ENDIF.

    et_struc = lt_struc_all.
    et_objec = lt_objec_all.
    et_actor = lt_actor_all.
    IF mv_cache_enabled = abap_true.
      INSERT VALUE zif_type_om_obj=>ty_cache_entry_wegid( key       = ls_key
                                                          struc_t   = lt_struc_all
                                                          objec_t   = lt_objec_all
                                                          tswhactor = lt_actor_all )
             INTO TABLE mt_cache_wegid.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
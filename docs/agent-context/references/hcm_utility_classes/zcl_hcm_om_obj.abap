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
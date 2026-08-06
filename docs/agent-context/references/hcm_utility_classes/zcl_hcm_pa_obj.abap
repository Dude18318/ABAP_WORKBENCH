CLASS zcl_hcm_pa_obj DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES:
      BEGIN OF ty_0006_ext,
        table  TYPE p0006,
        screen TYPE pru_kladr_screen,
      END OF ty_0006_ext.
    TYPES ty_2001 TYPE TABLE OF p2001.
    TYPES ty_2002 TYPE TABLE OF p2002.
    TYPES:
      BEGIN OF ty_szv,
        pernr    TYPE pernr_d,
        begda    TYPE begda,
        endda    TYPE endda,
        a_objid  TYPE hrobjid,
        ch_objid TYPE hrobjid,
        ch_short TYPE short_d,
        ch_stext TYPE stext,
        cl_objid TYPE hrobjid,
        cl_short TYPE short_d,
        cl_stext TYPE stext,
        stdaz    TYPE p2002-stdaz,
      END OF ty_szv.
    TYPES ty_t_szv TYPE STANDARD TABLE OF ty_szv WITH DEFAULT KEY.
    TYPES:
      BEGIN OF ty_betrg,
        betrg TYPE betrg,
        anzhl TYPE anzhl,
      END OF ty_betrg.

    DATA mv_pernr TYPE pernr_d.

    CONSTANTS mc_actor_ruk TYPE swhactor-otype VALUE 'RK' ##NO_TEXT.
    CONSTANTS mc_actor_buh TYPE swhactor-otype VALUE 'BH' ##NO_TEXT.

    DATA mv_no_auth TYPE flag.

    METHODS get_zlawrf
      IMPORTING is_p0861         TYPE p0861
      RETURNING VALUE(rv_zlawrf) TYPE char255.

    METHODS get_substitute
      IMPORTING iv_plans     TYPE p0001-plans OPTIONAL
                iv_date      TYPE p0001-begda
      EXPORTING ev_osn_pernr TYPE p0001-pernr
                ev_osn_inits TYPE p0002-inits
                ev_osn_nachn TYPE p0002-nachn.

    CLASS-METHODS get_instance
      IMPORTING iv_pernr         TYPE pernr_d
                iv_begda         TYPE begda DEFAULT sy-datum
                iv_endda         TYPE endda DEFAULT sy-datum
                iv_valid         TYPE flag  DEFAULT 'X'
                iv_no_auth       TYPE flag  DEFAULT abap_false
      EXPORTING ev_exist         TYPE flag
      RETURNING VALUE(ro_object) TYPE REF TO zcl_hcm_pa_obj.

    METHODS get_hire_fire_dates
      EXPORTING et_phifi TYPE p99sh_tab_phifi
                ev_hire  TYPE datum
                ev_fire  TYPE datum.

    METHODS check_auth
      IMPORTING iv_uname     TYPE sy-uname DEFAULT sy-uname
      RETURNING VALUE(rv_ok) TYPE flag.

    METHODS check_abkrs_block
      IMPORTING iv_date         TYPE datum DEFAULT sy-datum
      RETURNING VALUE(rv_block) TYPE flag.

    METHODS read_hr_infotype
      IMPORTING iv_infty      TYPE infty
                iv_subty      TYPE subty DEFAULT '*'
                iv_check_auth TYPE flag  DEFAULT 'X'
                iv_begda      TYPE begda OPTIONAL
                iv_endda      TYPE endda OPTIONAL
                iv_sprps      TYPE sprps DEFAULT ' '
                iv_buffer     TYPE flag  OPTIONAL
      EXPORTING es_pnnnn      TYPE any
                et_pnnnn      TYPE STANDARD TABLE.

    METHODS enqueue
      EXPORTING ev_ok         TYPE flag
                ev_lock_user  TYPE sy-uname
                es_return_msg TYPE bapireturn1.

    METHODS dequeue.

    METHODS get_fio
      IMPORTING iv_surname    TYPE flag  DEFAULT abap_true
                iv_name       TYPE flag  DEFAULT abap_true
                iv_patronymic TYPE flag  DEFAULT abap_true
                iv_for_www    TYPE flag  DEFAULT abap_false
                iv_is_short   TYPE flag  DEFAULT abap_false
                iv_lang       TYPE spras DEFAULT 'R'
      EXPORTING ev_nachn      TYPE pad_nachn
                ev_vorna      TYPE pad_vorna
                ev_midnm      TYPE pad_midnm
      RETURNING VALUE(ev_fio) TYPE string.

    METHODS get_orgeh_via_pa_on_date
      IMPORTING iv_check_auth   TYPE flag  DEFAULT abap_true
                iv_begda        TYPE begda OPTIONAL
                iv_endda        TYPE endda OPTIONAL
      RETURNING VALUE(ro_orgeh) TYPE REF TO zcl_hcm_om_obj.

    METHODS get_orgeh_via_pa
      IMPORTING iv_check_auth   TYPE flag  DEFAULT abap_true
                iv_begda        TYPE begda OPTIONAL
                iv_endda        TYPE endda OPTIONAL
      RETURNING VALUE(ro_orgeh) TYPE REF TO zcl_hcm_om_obj.

    METHODS get_orgeh_via_om
      IMPORTING iv_check_auth   TYPE flag  DEFAULT abap_true
                iv_begda        TYPE begda OPTIONAL
                iv_endda        TYPE endda OPTIONAL
      RETURNING VALUE(ro_orgeh) TYPE REF TO zcl_hcm_om_obj.

    METHODS get_plans_via_pa
      IMPORTING iv_check_auth   TYPE flag  DEFAULT abap_true
                iv_begda        TYPE begda OPTIONAL
                iv_endda        TYPE endda OPTIONAL
      RETURNING VALUE(ro_plans) TYPE REF TO zcl_hcm_om_obj.

    METHODS get_tarif_grade
      EXPORTING ev_trfgb        TYPE trfgb
      RETURNING VALUE(rv_grade) TYPE trfst.

    METHODS get_infty_notes
      IMPORTING iv_infty        TYPE infty
      CHANGING  it_pnnnn        TYPE STANDARD TABLE
      RETURNING VALUE(rt_notes) TYPE it_notes.

    METHODS get_address
      IMPORTING iv_lang          TYPE spras DEFAULT 'R'
                iv_obj_initial   TYPE flag  DEFAULT abap_false
                iv_juper         TYPE bukrs OPTIONAL
      EXPORTING es_t7ru9a_string TYPE string
      RETURNING VALUE(rs_t7ru9a) TYPE t7ru9a.

    METHODS get_feature
      IMPORTING iv_feature      TYPE merk1
                iv_structure    TYPE bi_structname DEFAULT 'PME04'
                is_0001         TYPE p0001         OPTIONAL
      RETURNING VALUE(rv_value) TYPE text10.

    METHODS get_birthplace
      RETURNING VALUE(rv_birthplace) TYPE text255.

    METHODS get_betrg
      IMPORTING iv_lgart        TYPE lgart
      RETURNING VALUE(rv_betrg) TYPE ty_betrg.

    METHODS get_date_of_reciept
      IMPORTING iv_date        TYPE datum DEFAULT sy-datum
      RETURNING VALUE(rv_date) TYPE char10.

    METHODS get_prozt
      IMPORTING iv_subty        TYPE subty DEFAULT 'B008'
      EXPORTING es_p1001        TYPE p1001
      RETURNING VALUE(rv_prozt) TYPE prozt.

    METHODS get_fact_address
      IMPORTING iv_lang          TYPE spras DEFAULT 'R'
      EXPORTING ev_factadd       TYPE string
      RETURNING VALUE(rs_t7ru9a) TYPE t7ru9a.

    METHODS get_address_0006
      IMPORTING iv_subty          TYPE subty DEFAULT '*'
      EXPORTING es_address_string TYPE string
      RETURNING VALUE(rs_address) TYPE ty_0006_ext.

    METHODS get_registration_address
      IMPORTING iv_subtyorder                  TYPE char3 DEFAULT '124'
      RETURNING VALUE(rv_registration_address) TYPE string.

    METHODS get_pru_education
      IMPORTING iv_subty       TYPE subty DEFAULT '*'
                is_p0022       TYPE p0022 OPTIONAL
      RETURNING VALUE(rs_educ) TYPE pru_education.

    METHODS get_approver_business_trip
      IMPORTING iv_begda           TYPE begda OPTIONAL
                iv_endda           TYPE endda OPTIONAL
                iv_check_auth      TYPE flag  DEFAULT abap_true
      RETURNING VALUE(ro_approver) TYPE REF TO zcl_hcm_pa_obj.

    "! <p class="shorttext synchronized" lang="ru">Согласующий релокацию</p>
    "! @parameter IV_BEGDA      | <p class="shorttext synchronized" lang="ru">С даты</p>
    "! @parameter IV_ENDDA      | <p class="shorttext synchronized" lang="ru">По дату</p>
    "! @parameter IV_CHECK_AUTH | <p class="shorttext synchronized" lang="ru">Проверка полномочий по умолчанию да</p>
    "! @parameter RO_APPROVER   | <p class="shorttext synchronized" lang="ru">Возвращает объект согласующий релокацию</p>
    METHODS get_approver_reloc_pack
      IMPORTING iv_begda           TYPE begda OPTIONAL
                iv_endda           TYPE endda OPTIONAL
                iv_check_auth      TYPE flag  DEFAULT abap_true
      RETURNING VALUE(ro_approver) TYPE REF TO zcl_hcm_pa_obj
      RAISING zcx_hcm_relocation_integration
              CX_SY_REF_IS_INITIAL.

    METHODS get_approver_fin_business_trip
      IMPORTING iv_begda           TYPE begda OPTIONAL
                iv_endda           TYPE endda OPTIONAL
                iv_check_auth      TYPE flag  DEFAULT abap_true
      RETURNING VALUE(ro_approver) TYPE REF TO zcl_hcm_pa_obj.

    METHODS get_boss
      IMPORTING iv_begda        TYPE begda OPTIONAL
                iv_endda        TYPE endda OPTIONAL
                iv_check_auth   TYPE flag  DEFAULT abap_true
                if_orgeh_via_om TYPE flag  DEFAULT abap_false
      RETURNING VALUE(ro_boss)  TYPE REF TO zcl_hcm_pa_obj.

    METHODS get_apr
      IMPORTING iv_priox             TYPE priox OPTIONAL
      RETURNING VALUE(ro_person_apr) TYPE REF TO zcl_hcm_pa_obj.

    METHODS get_signer
      RETURNING VALUE(ro_person_podp) TYPE REF TO zcl_hcm_pa_obj.

    METHODS get_signer_new
      IMPORTING iv_buh_flag           TYPE flag          OPTIONAL
                iv_progname           TYPE comp_programm OPTIONAL
      EXPORTING et_actor              TYPE tswhactor
                ev_pernr              TYPE pernr_d
                et_pernr              TYPE pernr_tab
      RETURNING VALUE(ro_person_podp) TYPE REF TO zcl_hcm_pa_obj.

    METHODS get_passport
      EXPORTING es_p0290          TYPE p0290
      RETURNING VALUE(rv_pasport) TYPE string.

    METHODS get_def_date
      IMPORTING iv_dar          TYPE p0041-dar01
      RETURNING VALUE(rv_value) TYPE p0041-dat01.

    METHODS get_mvz
      IMPORTING iv_kostl       TYPE kostl OPTIONAL
                iv_kokrs       TYPE kokrs OPTIONAL
                iv_check_auth  TYPE flag  OPTIONAL
      RETURNING VALUE(rs_cskt) TYPE cskt.

    METHODS get_account_assignment
      IMPORTING iv_begda TYPE begda OPTIONAL
                iv_endda TYPE endda OPTIONAL
      EXPORTING ev_kostl TYPE p0027-kst01
                ev_posnr TYPE p0027-psp01
                ev_fkber TYPE p0027-fkber01.

    METHODS get_empl_contract
      IMPORTING iv_plans        TYPE hrobjid OPTIONAL
      RETURNING VALUE(rv_ansvh) TYPE ansvh.

    METHODS get_persg
      IMPORTING iv_infty        TYPE infty     DEFAULT '0001'
                iv_check_auth   TYPE abap_bool DEFAULT abap_true
      RETURNING VALUE(rv_persg) TYPE persg.

    METHODS get_persk
      IMPORTING iv_persk        TYPE persk DEFAULT '01'
                iv_infty        TYPE infty DEFAULT '0001'
      RETURNING VALUE(rv_persk) TYPE persk.

    METHODS get_percentage_of_emp
      IMPORTING iv_begda                    TYPE begda OPTIONAL
                iv_endda                    TYPE endda OPTIONAL
                iv_check_auth               TYPE flag  DEFAULT abap_true
      RETURNING VALUE(rv_percentage_of_emp) TYPE dec_16_04_s.

    METHODS get_status
      IMPORTING iv_date          TYPE datum OPTIONAL
      RETURNING VALUE(rv_status) TYPE stat2.

    METHODS get_email
      RETURNING VALUE(rv_mail) TYPE pstring.

    METHODS get_uname
      RETURNING VALUE(rv_uname) TYPE pstring.

    METHODS get_cp_obj
      RETURNING VALUE(rv_cpobj) TYPE hrobjid.

    METHODS get_old_pernr
      RETURNING VALUE(rt_pernr_tab) TYPE pernr_tab.

    METHODS get_orgeh_head
      EXPORTING et_actor        TYPE tswhactor
      RETURNING VALUE(rv_orgeh) TYPE hrobjid.

    METHODS read_note_30it
      EXPORTING ev_text1 TYPE text100
                ev_text2 TYPE text100
                ev_text3 TYPE text100.

    METHODS get_zash
      IMPORTING iv_date         TYPE begda OPTIONAL
      RETURNING VALUE(rv_solst) TYPE dec9_2.

    METHODS get_cpind
      IMPORTING iv_date         TYPE begda OPTIONAL
      RETURNING VALUE(rv_cpind) TYPE p_cpind.

    METHODS get_address_0006_kos
      IMPORTING iv_subty          TYPE subty DEFAULT '*'
      EXPORTING es_address_string TYPE string
      RETURNING VALUE(rs_address) TYPE ty_0006_ext.

  PROTECTED SECTION.
  PRIVATE SECTION.

    DATA mo_pernr TYPE REF TO zcl_hcm_om_obj .
    DATA mv_begda TYPE begda .
    DATA mv_endda TYPE endda .
    DATA mc_mail TYPE subty VALUE '0010' ##NO_TEXT.
    DATA mc_uname TYPE subty VALUE '0001' ##NO_TEXT.

    METHODS add_no_init
      IMPORTING
        !iv_val1 TYPE any
        !iv_val2 TYPE any
      CHANGING
        !cv_val  TYPE any .
    METHODS get_passport_new
      EXPORTING
        !es_p0290         TYPE p0290
      RETURNING
        VALUE(rv_pasport) TYPE string .
    METHODS add_no_init_rev
      IMPORTING
        !iv_val1  TYPE any
        !iv_val2  TYPE any
        !iv_point TYPE flag DEFAULT 'X'
      CHANGING
        !cv_val   TYPE any .
ENDCLASS.
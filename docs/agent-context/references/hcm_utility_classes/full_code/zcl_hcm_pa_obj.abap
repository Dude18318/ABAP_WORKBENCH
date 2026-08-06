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



CLASS ZCL_HCM_PA_OBJ IMPLEMENTATION.


  METHOD add_no_init.
    DATA lv_val2 TYPE text100.
    CHECK iv_val1 IS NOT INITIAL.
    IF iv_val2 IS NOT INITIAL.
      lv_val2 = iv_val2 && '.'.
    ENDIF.

    IF cv_val IS INITIAL.
      cv_val = iv_val1.
    ELSE.
      cv_val = cv_val && `, ` && iv_val1.
    ENDIF.
    IF lv_val2 IS NOT INITIAL.
      cv_val = cv_val && ` ` && lv_val2.
    ENDIF.
  ENDMETHOD.


  METHOD add_no_init_rev.
    DATA: lv_val2 TYPE text100,
          lv_add  TYPE string.

    CHECK iv_val1 IS NOT INITIAL.
    IF iv_val2 IS NOT INITIAL.
      lv_val2 = iv_val2 && '.'.
    ENDIF.
    lv_val2 = COND #( WHEN iv_val2 IS INITIAL THEN ''
                      WHEN iv_point = abap_true THEN |{ iv_val2 }.|
                      ELSE iv_val2 ).

    lv_add = COND #( WHEN lv_val2 IS NOT INITIAL THEN |{ lv_val2 } { iv_val1 }|
                     ELSE iv_val1 ).

    cv_val = COND #( WHEN cv_val IS INITIAL THEN lv_add
                     ELSE |{ cv_val }, { lv_add }| ).

  ENDMETHOD.


  METHOD check_abkrs_block.
    TYPES: BEGIN OF lty_t569v,
             pabrj TYPE pabrj,
             pabrp TYPE pabrp,
             state TYPE vwsta,
           END OF lty_t569v.

    DATA: ls_p0001 TYPE p0001,
          ls_t569v TYPE lty_t569v.

    me->read_hr_infotype( EXPORTING iv_infty = '0001'
                                    iv_begda = iv_date
                                    iv_endda = iv_date
                          IMPORTING es_pnnnn = ls_p0001 ).

    CHECK ls_p0001 IS NOT INITIAL.

    SELECT pabrj, pabrp, state UP TO 1 ROWS " HANA LapshovIA 01.09.2021
      FROM t569v
      INTO @ls_t569v
      WHERE abkrs = @ls_p0001-abkrs
      ORDER BY PRIMARY KEY. " HANA LapshovIA 01.09.2021
    ENDSELECT.

    IF iv_date(4)       = ls_t569v-pabrj
      AND iv_date+4(2) <= ls_t569v-pabrp
      AND ( ls_t569v-state = 1 OR ls_t569v-state = 4 ).

      rv_block = abap_true.

    ENDIF.

  ENDMETHOD.


  METHOD check_auth.

    CALL FUNCTION 'HR_CHECK_AUTHORITY_PERNR'
      EXPORTING
*       TCLAS                      = 'A'
        pernr                      = me->mv_pernr
        begda                      = me->mv_begda
        endda                      = me->mv_endda
        uname                      = iv_uname
      EXCEPTIONS
        no_authorization_for_pernr = 1
        OTHERS                     = 2.
    IF sy-subrc <> 0.
      rv_ok = abap_false.
    ELSE.
      rv_ok = abap_true.
    ENDIF.

  ENDMETHOD.


  METHOD dequeue.

    me->mo_pernr->dequeue( ).

  ENDMETHOD.


  METHOD enqueue.

    me->mo_pernr->enqueue( IMPORTING
                              ev_ok = ev_ok
                              ev_lock_user = ev_lock_user ).
    IF ev_ok = abap_false.
      es_return_msg-type       = 'E'.
      es_return_msg-id         = 'ZMSG_REUSE'.
      es_return_msg-number     = '002'.
      es_return_msg-message_v1 = ev_lock_user.
    ENDIF.

  ENDMETHOD.


  METHOD get_account_assignment.

    DATA(lv_begda) = COND #( WHEN iv_begda IS INITIAL
                             THEN mv_begda
                             ELSE iv_begda ).

    DATA(lv_endda) = COND #( WHEN iv_endda IS INITIAL
                             THEN mv_endda
                             ELSE iv_endda ).


    DATA: lt_p0027 TYPE TABLE OF p0027,
          lt_p0001 TYPE TABLE OF p0001.

    CLEAR:  lt_p0027,
            lt_p0001,
            ev_fkber,
            ev_kostl,
            ev_posnr.

    CALL FUNCTION 'HR_READ_INFOTYPE'
      EXPORTING
        pernr           = me->mv_pernr
        infty           = '0001'
        begda           = lv_begda
        endda           = lv_endda
      TABLES
        infty_tab       = lt_p0001
      EXCEPTIONS
        infty_not_found = 1
        invalid_input   = 2
        OTHERS          = 3.

    IF sy-subrc = 0 AND lt_p0001 IS NOT INITIAL.

      LOOP AT lt_p0001 ASSIGNING FIELD-SYMBOL(<ls_p0001>).
        ev_kostl = COND #( WHEN <ls_p0001>-kostl IS NOT INITIAL THEN <ls_p0001>-kostl ).
        ev_fkber = COND #( WHEN <ls_p0001>-fkber IS NOT INITIAL THEN <ls_p0001>-fkber ).
      ENDLOOP.
    ENDIF.

    CALL FUNCTION 'HR_COST_DISTRIBUTION_GET'
      EXPORTING
        pernr                 = mv_pernr
        begda                 = lv_begda
        endda                 = lv_endda
      TABLES
        p0027_out             = lt_p0027
      EXCEPTIONS
        could_not_read_it0001 = 1
        could_not_read_it0027 = 2
        could_not_read_it0266 = 3
        p0027_overflow        = 4
        no_active_plvar       = 5
        p0266_inconsistent    = 6
        no_authorization      = 7
        internal_error        = 8
        no_authorization_1018 = 9
        OTHERS                = 10.

    IF sy-subrc = 0.
      LOOP AT lt_p0027 ASSIGNING FIELD-SYMBOL(<ls_p0027_out>).
        ev_kostl = COND #( WHEN <ls_p0027_out>-kst01 IS NOT INITIAL THEN <ls_p0027_out>-kst01 ).
        ev_fkber = COND #( WHEN <ls_p0027_out>-fkber01 IS NOT INITIAL THEN <ls_p0027_out>-fkber01 ).

        IF <ls_p0027_out>-psp01 IS NOT INITIAL.

          CALL FUNCTION 'CONVERSION_EXIT_ABPSP_OUTPUT'
            EXPORTING
              input  = <ls_p0027_out>-psp01
            IMPORTING
              output = ev_posnr.
        ENDIF.
      ENDLOOP.
    ENDIF.

    CALL FUNCTION 'HR_READ_INFOTYPE'
      EXPORTING
        pernr           = mv_pernr
        infty           = '0027'
        begda           = lv_begda
        endda           = lv_endda
      TABLES
        infty_tab       = lt_p0027
      EXCEPTIONS
        infty_not_found = 1
        invalid_input   = 2
        OTHERS          = 3.

    IF sy-subrc = 0 AND lt_p0027 IS NOT INITIAL.

      LOOP AT lt_p0027 ASSIGNING FIELD-SYMBOL(<ls_p0027>).
        ev_kostl = COND #( WHEN <ls_p0027>-kst01 IS NOT INITIAL THEN <ls_p0027>-kst01 ).
        ev_fkber = COND #( WHEN <ls_p0027>-fkber01 IS NOT INITIAL THEN <ls_p0027>-fkber01 ).

        IF <ls_p0027>-psp01 IS NOT INITIAL.

          CALL FUNCTION 'CONVERSION_EXIT_ABPSP_OUTPUT'
            EXPORTING
              input  = <ls_p0027>-psp01
            IMPORTING
              output = ev_posnr.

        ENDIF.
      ENDLOOP.
    ENDIF.

  ENDMETHOD.


  METHOD get_address.

    CONSTANTS:
      lc_kv TYPE text2 VALUE 'кв'.

    DATA:
      lt_t7ru9a TYPE TABLE OF t7ru9a,
      lt_p0001  TYPE STANDARD TABLE OF p0001,
      lv_soort  TYPE p33_soort VALUE '01',
      lv_juper  TYPE bukrs.

    IF iv_lang = 'E'.
      lv_soort = '99'. "Английский язык
    ENDIF.

    me->read_hr_infotype(
          EXPORTING
            iv_infty      = '0001'
          IMPORTING
            et_pnnnn      = lt_p0001 ).

    TRY.
        DATA(ls_p0001) = lt_p0001[ 1 ].
      CATCH cx_sy_itab_line_not_found.
        RETURN.
    ENDTRY.

    IF iv_juper IS NOT INITIAL.
      lv_juper = iv_juper.
    ELSE.
      lv_juper = ls_p0001-juper.
    ENDIF.


    IF iv_obj_initial = abap_true.

      SELECT *
       FROM t7ru9a INTO TABLE @lt_t7ru9a
       WHERE juper = @lv_juper
         AND soort = @lv_soort
         AND instl = '000'
         AND objid = '000'
         AND begda <= @mv_begda
         AND endda >= @mv_begda.

      IF sy-subrc <> 0.
        RETURN.
      ENDIF.

    ELSE.

      SELECT *
          FROM t7ru9a INTO TABLE @lt_t7ru9a
          WHERE juper = @lv_juper
            AND soort = @lv_soort
            AND instl = '000'
            AND tosp = @ls_p0001-btrtl
            AND begda <= @mv_begda
            AND endda >= @mv_begda.

      IF sy-subrc <> 0.
        RETURN.
      ENDIF.
    ENDIF.

    TRY .
        DATA(ls_t7ru9a) = lt_t7ru9a[ 1 ].
      CATCH cx_sy_itab_line_not_found.
        RETURN.
    ENDTRY.

    MOVE-CORRESPONDING ls_t7ru9a TO rs_t7ru9a.

    IF es_t7ru9a_string IS REQUESTED.
      es_t7ru9a_string =  ls_t7ru9a-pstlz.

      SELECT SINGLE bezei FROM  t005u INTO @DATA(lv_state)
          WHERE land1 = 'RU' AND bland = @ls_t7ru9a-state AND spras = 'R'.

      IF lv_state IS NOT INITIAL.
        add_no_init(
          EXPORTING
            iv_val1 = lv_state
            iv_val2 = ' '
          CHANGING
            cv_val  = es_t7ru9a_string
        ).
      ELSE.
        add_no_init(
          EXPORTING
            iv_val1 = ls_t7ru9a-regionname
            iv_val2 = ls_t7ru9a-regionsocr
          CHANGING
            cv_val  = es_t7ru9a_string
        ).
      ENDIF.

      add_no_init(
        EXPORTING
          iv_val1 = ls_t7ru9a-ort01
          iv_val2 = ' '
        CHANGING
          cv_val  = es_t7ru9a_string
      ).
      add_no_init(
        EXPORTING
          iv_val1 = ls_t7ru9a-stras
          iv_val2 = ' '
        CHANGING
          cv_val  = es_t7ru9a_string
      ).
      add_no_init(
        EXPORTING
          iv_val1 = ls_t7ru9a-hsnmr
          iv_val2 = ' '
        CHANGING
          cv_val  = es_t7ru9a_string
      ).

      add_no_init(
       EXPORTING
         iv_val1 = ls_t7ru9a-bldng
         iv_val2 = ' '
       CHANGING
         cv_val  = es_t7ru9a_string
     ).

    ENDIF.

  ENDMETHOD.


  METHOD get_address_0006.

    DATA: lt_p0006 TYPE TABLE OF p0006,
          lt_p3433 TYPE TABLE OF p3433.
    CONSTANTS: lc_kv  TYPE text2 VALUE 'кв',
               lc_bld TYPE text6 VALUE 'корпус'.


    me->read_hr_infotype( EXPORTING iv_infty = '0006'
                                    iv_subty = iv_subty
                          IMPORTING et_pnnnn = lt_p0006 ).

    me->read_hr_infotype( EXPORTING iv_infty = '3433'
                                    iv_subty = iv_subty
                          IMPORTING et_pnnnn = lt_p3433 ).

    TRY .
        rs_address-table = lt_p0006[ 1 ].
      CATCH cx_sy_itab_line_not_found.
        CLEAR rs_address-table.
    ENDTRY.

    TRY .
        DATA(ls_3433) = lt_p3433[ 1 ].
      CATCH cx_sy_itab_line_not_found.
        CLEAR ls_3433.
    ENDTRY.

    DATA(lo_p0006_screen) = cl_hrpadru_infty_0006_screen=>get_instance( ).
    lo_p0006_screen->output_conversion(
      EXPORTING
        is_p0006  = rs_address-table
        is_p3433  = ls_3433
      CHANGING
        cs_screen = rs_address-screen ).

    DATA(ls_address_0006) = rs_address-table.
    DATA(ls_address_3433) = rs_address-screen.



    es_address_string = ls_address_0006-pstlz.

    add_no_init(
        EXPORTING
          iv_val1 = ls_address_3433-regionname
          iv_val2 = ls_address_3433-ksocr_region
        CHANGING
          cv_val  = es_address_string
      ).
    add_no_init(
      EXPORTING
        iv_val1 = ls_address_3433-areaname
        iv_val2 = ls_address_3433-ksocr_counc
      CHANGING
        cv_val  = es_address_string
    ).
    add_no_init(
      EXPORTING
        iv_val1 = ls_address_3433-kname_city
        iv_val2 = ls_address_3433-ksocr_city
      CHANGING
        cv_val  = es_address_string
    ).
    add_no_init(
      EXPORTING
        iv_val1 = ls_address_3433-kname_np
        iv_val2 = ls_address_3433-ksocr_np
      CHANGING
        cv_val  = es_address_string
        ).

    add_no_init(
      EXPORTING
        iv_val1 = ls_address_3433-planname
        iv_val2 = ls_address_3433-plansocr
      CHANGING
        cv_val  = es_address_string
    ).


    add_no_init(
      EXPORTING
        iv_val1 = ls_address_3433-kname_street
        iv_val2 = ls_address_3433-ksocr_street
      CHANGING
        cv_val  = es_address_string
    ).
    add_no_init(
      EXPORTING
        iv_val1 = ls_address_3433-kname_house
        iv_val2 = ls_address_3433-eststatname

      CHANGING
        cv_val  = es_address_string
    ).

    add_no_init(
      EXPORTING
        iv_val1 = ls_address_3433-kname_bldng
        iv_val2 = lc_bld

      CHANGING
        cv_val  = es_address_string
    ).

    add_no_init(
      EXPORTING
        iv_val1 = ls_address_3433-strucnum
        iv_val2 = ls_address_3433-strstatname
      CHANGING
        cv_val  = es_address_string
    ).

    add_no_init(
      EXPORTING
      iv_val1 = ls_address_0006-posta
      iv_val2 = lc_kv
      CHANGING
      cv_val  = es_address_string
      ).



  ENDMETHOD.


  METHOD get_address_0006_kos.
    TYPES: ty_rt_regionname TYPE RANGE OF hrpadru_fias_regionname.

    DATA: lt_p0006 TYPE TABLE OF p0006,
          lt_p3433 TYPE TABLE OF p3433.
    CONSTANTS: lc_kv        TYPE text2 VALUE 'кв',
               lc_bld       TYPE text6 VALUE 'корпус',
               lc_city      TYPE text6 VALUE 'г.',
               lc_tatarstan TYPE text50 VALUE 'Татарстан Респ.',
               lc_rt(2)     TYPE c VALUE 'РТ'.

    DATA(lr_regions) = VALUE ty_rt_regionname( ( sign = 'I' option = 'EQ' low = 'Байконур' )
                                               ( sign = 'I' option = 'EQ' low = 'Москва' )
                                               ( sign = 'I' option = 'EQ' low = 'Санкт-Петербург' )
                                               ( sign = 'I' option = 'EQ' low = 'Севастополь' ) ).

    me->read_hr_infotype( EXPORTING iv_infty = '0006'
                                    iv_subty = iv_subty
                          IMPORTING et_pnnnn = lt_p0006 ).

    me->read_hr_infotype( EXPORTING iv_infty = '3433'
                                    iv_subty = iv_subty
                          IMPORTING et_pnnnn = lt_p3433 ).

    TRY .
        rs_address-table = lt_p0006[ 1 ].
      CATCH cx_sy_itab_line_not_found.
        CLEAR rs_address-table.
    ENDTRY.

    TRY .
        DATA(ls_3433) = lt_p3433[ 1 ].
      CATCH cx_sy_itab_line_not_found.
        CLEAR ls_3433.
    ENDTRY.

    DATA(lo_p0006_screen) = cl_hrpadru_infty_0006_screen=>get_instance( ).
    lo_p0006_screen->output_conversion(
      EXPORTING
        is_p0006  = rs_address-table
        is_p3433  = ls_3433
      CHANGING
        cs_screen = rs_address-screen ).

    DATA(ls_address_0006) = rs_address-table.
    DATA(ls_address_3433) = rs_address-screen.

    es_address_string = ls_address_0006-pstlz.

    IF ls_address_3433-regionname IN lr_regions.
      es_address_string = COND #( WHEN es_address_string IS INITIAL THEN |{ lc_city } { ls_address_3433-regionname }|
                                  ELSE |{ es_address_string }, { lc_city } { ls_address_3433-regionname }| ).
    ELSE.
      add_no_init(
         EXPORTING
           iv_val1 = ls_address_3433-regionname
           iv_val2 = ls_address_3433-ksocr_region
         CHANGING
           cv_val  = es_address_string
       ).
    ENDIF.

    add_no_init(
      EXPORTING
        iv_val1 = ls_address_3433-areaname
        iv_val2 = ls_address_3433-ksocr_counc
      CHANGING
        cv_val  = es_address_string
    ).
    add_no_init_rev(
      EXPORTING
        iv_val1 = ls_address_3433-kname_city
        iv_val2 = ls_address_3433-ksocr_city
      CHANGING
        cv_val  = es_address_string
    ).
    add_no_init_rev(
      EXPORTING
        iv_val1 = ls_address_3433-kname_np
        iv_val2 = ls_address_3433-ksocr_np
      CHANGING
        cv_val  = es_address_string
        ).

    add_no_init_rev(
      EXPORTING
        iv_val1 = ls_address_3433-planname
        iv_val2 = ls_address_3433-plansocr
      CHANGING
        cv_val  = es_address_string
    ).


    add_no_init_rev(
      EXPORTING
        iv_val1 = ls_address_3433-kname_street
        iv_val2 = ls_address_3433-ksocr_street
      CHANGING
        cv_val  = es_address_string
    ).
    add_no_init_rev(
      EXPORTING
        iv_val1 = ls_address_3433-kname_house
        iv_val2 = ls_address_3433-eststatname

      CHANGING
        cv_val  = es_address_string
    ).

    add_no_init_rev(
      EXPORTING
        iv_val1 = ls_address_3433-kname_bldng
        iv_val2 = lc_bld
        iv_point = abap_false
      CHANGING
        cv_val  = es_address_string
    ).

    add_no_init_rev(
      EXPORTING
        iv_val1 = ls_address_3433-strucnum
        iv_val2 = ls_address_3433-strstatname
        iv_point = abap_false
      CHANGING
        cv_val  = es_address_string
    ).

    add_no_init_rev(
      EXPORTING
      iv_val1 = ls_address_0006-posta
      iv_val2 = lc_kv
      CHANGING
      cv_val  = es_address_string
      ).

    REPLACE FIRST OCCURRENCE OF lc_tatarstan IN es_address_string WITH lc_rt.
  ENDMETHOD.


  METHOD get_approver_business_trip.

    TYPES: BEGIN OF ty_pernr,
             pernr TYPE pernr_d,
             prozt TYPE p1001-prozt,
           END OF ty_pernr,
           tt_pernr TYPE STANDARD TABLE OF ty_pernr WITH EMPTY KEY,

           BEGIN OF ty_appr,
             lvl               TYPE i,
             objid             TYPE hrobjid,
             otype             TYPE c2,
             lvl_plans         TYPE i,
             pernr             TYPE tt_pernr,
             not_approver_bool TYPE abap_bool,
             prozt_bool        TYPE abap_bool,
             lvl_plans_bool    TYPE abap_bool,
             wegid             TYPE wegid,
           END OF ty_appr,
           tt_appr TYPE SORTED TABLE OF ty_appr WITH UNIQUE KEY lvl objid.

    CONSTANTS: lc_scenario     TYPE om_attrscn VALUE 'Z_15_SHD',
               lc_zboss_o      TYPE wegid VALUE 'ZBOSS_O',
               lc_attrib       TYPE om_attrib VALUE 'Z_NOT_APPR',
               lc_relation_s_s TYPE subtyp VALUE 'AZ12',
               lc_relation_o_s TYPE subtyp VALUE 'BZ10',
               lc_relation_s_p TYPE subtyp VALUE 'A008',    "Штат. дол-сть - Сотр
               lc_wegid        TYPE wegid  VALUE 'P-S-O-O', "Путь анализа
               lc_boss         TYPE subtyp VALUE 'A012',
               lc_by_myself    TYPE wegid  VALUE 'MYSELF'.  "Согласует сам себя, только для руководителя подразделения

    DATA: lo_plans_appr TYPE REF TO zcl_hcm_om_obj,
          lt_appr       TYPE tt_appr,
          lv_lvl_plans  TYPE p_cpreg,
          lv_om_attrval TYPE om_attrval,
          lv_lines      TYPE i,
          lv_plans      TYPE hrobjid,
          lt_p1001      TYPE p1001_t,
          lt_pernr      TYPE tt_pernr.

    DATA(lv_begda) = COND #( WHEN iv_begda IS INITIAL
                            THEN mv_begda
                            ELSE iv_begda ).

    DATA(lv_endda) = COND #( WHEN iv_endda IS INITIAL
                             THEN mv_endda
                             ELSE iv_endda ).

*{3000015579 AnisimovSV 20230720
    DATA(ls_0001) = VALUE p0001(  ).
    read_hr_infotype(
      EXPORTING
        iv_infty      = '0001'
        iv_begda      = lv_begda
        iv_endda      = lv_endda
      IMPORTING
        es_pnnnn      = ls_0001 ).

    DATA(lt_boss_sign_lv_pl_2) = zcl_tvarvc=>get_const_range( 'ZRC_PA_2384_BOSS_SIGN_LV_PL_2' ).

    DATA(lv_bukrs_lvl_3) = xsdbool( xsdbool( ls_0001-bukrs IN lt_boss_sign_lv_pl_2 )  = abap_false ).

*}3000015579 AnisimovSV 20230720
    DATA(lo_plans) = me->get_plans_via_pa( iv_check_auth = iv_check_auth
                                           iv_begda      = lv_begda
                                           iv_endda      = lv_endda ).

    lv_plans = lo_plans->ms_object.


    CLEAR: lt_p1001,
         lt_pernr,
         lo_plans_appr,
         lv_lvl_plans.

    "Определяем исключение Z12 (исключение S-S)
    TRY .
        "Для ШД сотрудника находим соединение Согл. Ком-ки Сотр-Рук
        DATA(lo_plans_appr_line) =
          lo_plans->read_relation( iv_subty      = lc_relation_s_s
                                   iv_requ_otype = zcl_hcm_values=>mc_otype-plans
                                   iv_check_auth = iv_check_auth ).
      CATCH cx_sy_ref_is_initial.
        RETURN.
    ENDTRY.

    TRY.
        lo_plans_appr_line->read_relation(
                              EXPORTING iv_subty      = lc_relation_s_p
                                        iv_requ_otype = zcl_hcm_values=>mc_otype-pernr
                                        iv_check_auth = iv_check_auth
                              IMPORTING et_p1001      = lt_p1001 ).

        IF NOT line_exists( lt_p1001[ 1 ] ).
          INSERT VALUE #( lvl   = 1
                          wegid = lc_relation_s_s ) INTO TABLE lt_appr.
        ELSE.

          lt_pernr = VALUE tt_pernr( FOR ls_p1001 IN lt_p1001
                                                        WHERE ( sclas = zcl_hcm_values=>mc_otype-pernr AND
                                                                prozt > 0 )
                                                          ( pernr = ls_p1001-sobid
                                                            prozt = ls_p1001-prozt ) ).

          INSERT VALUE #( lvl               = 1
                          objid             = lt_p1001[ 1 ]-objid
                          otype             = zcl_hcm_values=>mc_otype-plans
                          lvl_plans         = lv_lvl_plans
                          pernr             = lt_pernr
                          not_approver_bool = abap_true
                          prozt_bool        = abap_true
                          lvl_plans_bool    = abap_true
                          wegid             = lc_relation_s_s
                        ) INTO TABLE lt_appr.
        ENDIF.
      CATCH cx_sy_ref_is_initial.
        INSERT VALUE #( lvl   = 1
                        wegid = lc_relation_s_s ) INTO TABLE lt_appr.
    ENDTRY.

    "Определяем исключение Z10 (исключение S-O)
    lo_plans->read_wegid( EXPORTING iv_wegid      = lc_wegid
                                    iv_requ_otype = zcl_hcm_values=>mc_otype-orgeh
                                    iv_check_auth = iv_check_auth
                          IMPORTING et_struc      = DATA(lt_struc) ).

    SORT lt_struc BY level ASCENDING.

    LOOP AT lt_struc ASSIGNING FIELD-SYMBOL(<ls_struc>).
      CLEAR: lt_p1001,
             lt_pernr,
             lo_plans_appr,
             lv_lvl_plans.

      lv_lines = REDUCE i( INIT x = 0 FOR wa IN lt_appr NEXT x = x + 1 ).
      DATA(lo_orgeh) =
        zcl_hcm_om_obj=>get_instance( iv_objid = CONV #( <ls_struc>-objid )
                                      iv_otype = <ls_struc>-otype
                                      iv_begda = lv_begda
                                      iv_endda = lv_endda ).

      CHECK lo_orgeh IS NOT INITIAL.

      DATA(lo_plans_org) =
        lo_orgeh->read_relation( iv_subty      = lc_relation_o_s
                                 iv_requ_otype = zcl_hcm_values=>mc_otype-plans
                                 iv_check_auth = iv_check_auth ).

      CHECK lo_plans_org IS NOT INITIAL.
      lo_plans_org->read_greyd( EXPORTING iv_check_auth = iv_check_auth
                                IMPORTING ev_trfgb      = lv_lvl_plans ).

      lo_plans_appr = zcl_hcm_om_obj=>get_instance( iv_objid =  lo_plans_org->ms_object-objid
                                                    iv_otype = lo_plans_org->ms_object-otype
                                                    iv_begda = lv_begda
                                                    iv_endda = lv_endda ).

      lo_plans_appr->read_relation(
                            EXPORTING iv_subty      = lc_relation_s_p
                                      iv_requ_otype = zcl_hcm_values=>mc_otype-pernr
                                      iv_check_auth = iv_check_auth
                            IMPORTING et_p1001      = lt_p1001 ).

      IF NOT line_exists( lt_p1001[ 1 ] ).
        INSERT VALUE #( lvl   = 2
                        wegid = lc_relation_s_s ) INTO TABLE lt_appr.
      ELSE.

        lt_pernr = VALUE tt_pernr( FOR ls_p1001 IN lt_p1001
                                                      WHERE ( sclas = zcl_hcm_values=>mc_otype-pernr AND
                                                              prozt > 0 )
                                                        ( pernr = ls_p1001-sobid
                                                          prozt = ls_p1001-prozt ) ).

        INSERT VALUE #( lvl               = lv_lines + 1
                        objid             = lo_plans_org->ms_object-objid
                        otype             = lo_plans_org->ms_object-otype
                        lvl_plans         = lv_lvl_plans
                        pernr             = lt_pernr
                        not_approver_bool = abap_true
                        prozt_bool        = abap_true
                        lvl_plans_bool    = abap_true
                        wegid             = lc_relation_o_s
                      ) INTO TABLE lt_appr.
      ENDIF.
    ENDLOOP.
    IF NOT line_exists( lt_appr[ lvl = 2 ] ).
      INSERT VALUE #( lvl   = 2
                      wegid = lc_relation_o_s ) INTO TABLE lt_appr.
    ENDIF.

    "Основной алгоритм если IS INITIAL.

    lo_plans->read_wegid( EXPORTING iv_wegid = lc_zboss_o
                                 iv_requ_otype = zcl_hcm_values=>mc_otype-plans
                       IMPORTING et_struc = DATA(lt_boss) ).

    DELETE lt_boss WHERE rflag = abap_true.
    SORT lt_boss ASCENDING BY level.
    CLEAR: lv_lines.
    LOOP AT lt_boss ASSIGNING FIELD-SYMBOL(<ls_struct>)
    WHERE objid NE lv_plans.

      CLEAR: lt_p1001,
             lt_pernr,
             lo_plans_appr,
             lv_lvl_plans.

      lv_lines = REDUCE i( INIT x = 0 FOR wa IN lt_appr NEXT x = x + 1 ).

      lo_plans_appr = zcl_hcm_om_obj=>get_instance( iv_objid = CONV #( <ls_struct>-objid )
                                                          iv_otype = <ls_struct>-otype
                                                          iv_begda = lv_begda
                                                          iv_endda = lv_endda ).

      lo_plans_appr->read_greyd( EXPORTING iv_check_auth = iv_check_auth " SavinovaEA 3000010592 12.11.2020
                                 IMPORTING ev_trfgb = lv_lvl_plans ).

      lv_om_attrval = lo_plans_appr->get_attribute( EXPORTING iv_attrib     = lc_attrib
                                                              iv_scenario   = lc_scenario
                                                              iv_check_auth = iv_check_auth
                                                              iv_buf        = abap_true ).

      lo_plans_appr->read_relation(
                            EXPORTING iv_subty      = lc_relation_s_p
                                      iv_requ_otype = zcl_hcm_values=>mc_otype-pernr
                                      iv_check_auth = iv_check_auth
                            IMPORTING et_p1001      = lt_p1001 ).

      lt_pernr = VALUE tt_pernr( FOR ls_p1001 IN lt_p1001
                                                    WHERE ( sclas = zcl_hcm_values=>mc_otype-pernr AND
                                                            prozt > 0 )
                                                      ( pernr = ls_p1001-sobid
                                                        prozt = ls_p1001-prozt ) ).

      INSERT VALUE #( lvl                 = lv_lines + 1
                      objid               = <ls_struct>-objid
                      otype               = <ls_struct>-otype
                      lvl_plans           = lv_lvl_plans
                      pernr               = lt_pernr
                      not_approver_bool   = COND #( WHEN lv_om_attrval = abap_true THEN abap_false ELSE abap_true )
                      prozt_bool          = COND #( WHEN line_exists( lt_pernr[ 1 ] ) THEN abap_true )
                      lvl_plans_bool      = COND #(
*{3000015579 AnisimovSV 20230720
                                                    WHEN ( lv_lvl_plans = 1 OR
                                                           lv_lvl_plans = 2 OR
                                                           lv_lvl_plans = 3 ) AND
                                                           lv_bukrs_lvl_3 = abap_true
                                                    THEN abap_true
*}3000015579 AnisimovSV 20230720
                                                    WHEN ( lv_lvl_plans = 1 OR lv_lvl_plans = 2 )
                                                    THEN abap_true
                                                    ELSE abap_false )
                      wegid               = lc_zboss_o
                    ) INTO TABLE lt_appr.
    ENDLOOP.

    "Если ничего не нашли замыкаем сами на себя, только для руководителя подразделения ур. 1 или 2.
    IF NOT line_exists( lt_appr[ prozt_bool        = abap_true
                                 lvl_plans_bool    = abap_true
                                 not_approver_bool = abap_true ] ).
      CLEAR: lt_p1001,
             lt_pernr,
             lo_plans_appr,
             lv_lvl_plans,
             lv_lines.

      lv_lines = REDUCE i( INIT x = 0 FOR wa IN lt_appr NEXT x = x + 1 ).

      lo_plans->read_relation(
                            EXPORTING iv_subty      = lc_relation_s_p
                                      iv_requ_otype = zcl_hcm_values=>mc_otype-pernr
                                      iv_check_auth = iv_check_auth
                            IMPORTING et_p1001      = lt_p1001 ).
      CHECK line_exists( lt_p1001[ 1 ] ).

      lo_plans->read_greyd( EXPORTING iv_check_auth = iv_check_auth
                            IMPORTING ev_trfgb = lv_lvl_plans ).
      CHECK lv_lvl_plans IS NOT INITIAL.

      lo_plans->read_relation(
                            EXPORTING iv_subty      = lc_boss
                                      iv_requ_otype = zcl_hcm_values=>mc_otype-orgeh
                                      iv_check_auth = iv_check_auth
                            IMPORTING et_p1001      = DATA(lt_a012) ).

      CHECK line_exists( lt_a012[ 1 ] ).

      "не замыкаем сотрудника самого на себя, если выше есть атрибут "нельзя согласовывать"
      CHECK NOT line_exists( lt_appr[ not_approver_bool = abap_false wegid = lc_zboss_o ] ).

      lt_pernr = VALUE tt_pernr( FOR ls_p1001 IN lt_p1001
                                                    WHERE ( sclas = zcl_hcm_values=>mc_otype-pernr AND
                                                            prozt > 0 )
                                                      ( pernr = ls_p1001-sobid
                                                        prozt = ls_p1001-prozt ) ).

      INSERT VALUE #( lvl                 = lv_lines + 1
                      objid               = lt_p1001[ 1 ]-objid
                      otype               = zcl_hcm_values=>mc_otype-plans
                      lvl_plans           = lv_lvl_plans
                      pernr               = lt_pernr
                      not_approver_bool   = abap_true
                      prozt_bool          = abap_true
                      lvl_plans_bool      = COND #( WHEN ( lv_lvl_plans = 1 OR lv_lvl_plans = 2 )
                                                    THEN abap_true
                                                    ELSE abap_false )
                      wegid               = lc_by_myself
                    ) INTO TABLE lt_appr.

    ENDIF.
    TRY.
        DATA(lv_pernr) = lt_appr[ prozt_bool        = abap_true
                                  lvl_plans_bool    = abap_true
                                  not_approver_bool = abap_true ]-pernr[ 1 ]-pernr.
      CATCH cx_sy_itab_line_not_found.
        RETURN.
    ENDTRY.

    IF lv_pernr IS NOT INITIAL.
      ro_approver = me->get_instance( iv_pernr = lv_pernr
                                      iv_begda = lv_begda
                                      iv_endda = lv_endda ).
    ENDIF.

  ENDMETHOD.


  METHOD get_approver_fin_business_trip.
    CONSTANTS: lc_relation_s_s TYPE subtyp VALUE 'AZ13',
               lc_relation_o_s TYPE subtyp VALUE 'BZ11',
               lc_relation_s_p TYPE subtyp VALUE 'A008',    "Штат. дол-сть - Сотр
               lc_wegid        TYPE wegid  VALUE 'P-S-O-O'. "Путь анализа

    DATA: lt_p1001 TYPE p1001_t.

    DATA(lv_begda) = COND #( WHEN iv_begda IS INITIAL
                             THEN mv_begda
                             ELSE iv_begda ).

    DATA(lv_endda) = COND #( WHEN iv_endda IS INITIAL
                             THEN mv_endda
                             ELSE iv_endda ).

    DATA(lo_plans) = me->get_plans_via_pa( iv_check_auth = iv_check_auth
                                           iv_begda      = lv_begda
                                           iv_endda      = lv_endda ).

    TRY .
        "Для ШД сотрудника находим соединение Согл. Ком-ки Сотр-Рук
        DATA(lo_plans_appr_line) =
          lo_plans->read_relation( iv_subty      = lc_relation_s_s
                                   iv_requ_otype = zcl_hcm_values=>mc_otype-plans
                                   iv_check_auth = iv_check_auth ).
      CATCH cx_sy_ref_is_initial.
        RETURN.
    ENDTRY.

    TRY .
        lo_plans_appr_line->read_relation(
                              EXPORTING iv_subty      = lc_relation_s_p
                                        iv_requ_otype = zcl_hcm_values=>mc_otype-pernr
                                        iv_check_auth = iv_check_auth
                              IMPORTING et_p1001      = lt_p1001 ).
        SORT lt_p1001 BY prozt DESCENDING.
        DATA(ls_p1001) = VALUE p1001( lt_p1001[ 1 ] OPTIONAL ).
        DATA(lv_pernr_appr_line) =
          COND pernr_d( WHEN ls_p1001-prozt > 0 THEN ls_p1001-sobid ).
      CATCH cx_sy_ref_is_initial.
    ENDTRY.

    " Если на ШД есть принятый сотрудник, находим ТН и выходим
    IF lv_pernr_appr_line IS NOT INITIAL.
      ro_approver = me->get_instance( iv_pernr = lv_pernr_appr_line
                                      iv_begda = lv_begda
                                      iv_endda = lv_endda ).
      RETURN.
    ENDIF.

    " Если на ШД нет принятого сотрудника, ищем соединение Согл. Ком-ки Орг - Рук
    " на вышестоящих ОЕ
    lo_plans->read_wegid( EXPORTING iv_wegid      = lc_wegid
                                    iv_requ_otype = zcl_hcm_values=>mc_otype-orgeh
                                    iv_check_auth = iv_check_auth
                          IMPORTING et_struc      = DATA(lt_struc) ).

    SORT lt_struc BY level ASCENDING.
    LOOP AT lt_struc ASSIGNING FIELD-SYMBOL(<ls_struc>).
      DATA(lo_orgeh) =
        zcl_hcm_om_obj=>get_instance( iv_objid = CONV #( <ls_struc>-objid )
                                      iv_otype = <ls_struc>-otype
                                      iv_begda = lv_begda
                                      iv_endda = lv_endda ).

      TRY.
          DATA(lo_plans_appr_org) =
              lo_orgeh->read_relation( iv_subty      = lc_relation_o_s
                                       iv_requ_otype = zcl_hcm_values=>mc_otype-plans
                                       iv_check_auth = iv_check_auth ).
        CATCH cx_sy_ref_is_initial.
          CONTINUE.
      ENDTRY.

      TRY.
          lo_plans_appr_org->read_relation(
                              EXPORTING iv_subty      = lc_relation_s_p
                                        iv_requ_otype = zcl_hcm_values=>mc_otype-pernr
                                        iv_check_auth = iv_check_auth
                              IMPORTING et_p1001      = lt_p1001 ).

          IF lt_p1001[] IS NOT INITIAL.
            SORT lt_p1001 BY prozt DESCENDING.

            ASSIGN lt_p1001[ 1 ] TO FIELD-SYMBOL(<ls_p1001>).
            IF <ls_p1001>-prozt > 0.
              DATA(lv_pernr) = <ls_p1001>-sobid.
            ENDIF.
          ENDIF.

        CATCH cx_sy_ref_is_initial.
          CONTINUE.
      ENDTRY.

      IF lv_pernr IS NOT INITIAL.
        ro_approver = me->get_instance( iv_pernr = CONV #( lv_pernr )
                                        iv_begda = lv_begda
                                        iv_endda = lv_endda ).
        RETURN.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.


  METHOD get_approver_reloc_pack.
    TYPES: BEGIN OF ty_pernr,
             pernr TYPE pernr_d,
             prozt TYPE p1001-prozt,
           END OF ty_pernr,
           tt_pernr TYPE STANDARD TABLE OF ty_pernr WITH EMPTY KEY,

           BEGIN OF ty_appr,
             lvl               TYPE i,
             objid             TYPE hrobjid,
             otype             TYPE c2,
             lvl_plans         TYPE i,
             pernr             TYPE tt_pernr,
             not_approver_bool TYPE abap_bool,
             prozt_bool        TYPE abap_bool,
             lvl_plans_bool    TYPE abap_bool,
             wegid             TYPE wegid,
           END OF ty_appr,
           tt_appr TYPE SORTED TABLE OF ty_appr WITH UNIQUE KEY lvl objid.

    CONSTANTS lc_scenario     TYPE om_attrscn VALUE 'Z_15_SHD'.
    CONSTANTS lc_zboss_o      TYPE wegid      VALUE 'ZBOSS_O'.
    CONSTANTS lc_attrib       TYPE om_attrib  VALUE 'Z_NOT_APPR'.
    CONSTANTS lc_relation_s_s TYPE subtyp     VALUE 'AZ21'.
    CONSTANTS lc_relation_o_s TYPE subtyp     VALUE 'BZ20'.
    CONSTANTS lc_relation_s_p TYPE subtyp     VALUE 'A008'.       " Штат. дол-сть - Сотр
    CONSTANTS lc_wegid        TYPE wegid      VALUE 'P-S-O-O'.    " Путь анализа
    CONSTANTS lc_boss         TYPE subtyp     VALUE 'A012'.
    CONSTANTS lc_by_myself    TYPE wegid      VALUE 'MYSELF'.     " Согласует сам себя, только для руководителя подразделения

    DATA lo_plans_appr TYPE REF TO zcl_hcm_om_obj.
    DATA lt_appr       TYPE tt_appr.
    DATA lv_lvl_plans  TYPE p_cpreg.
    DATA lv_om_attrval TYPE om_attrval.
    DATA lv_lines      TYPE i.
    DATA lv_plans      TYPE hrobjid.
    DATA lt_p1001      TYPE p1001_t.
    DATA lt_pernr      TYPE tt_pernr.

    DATA(lv_begda) = COND #( WHEN iv_begda IS INITIAL
                             THEN mv_begda
                             ELSE iv_begda ).

    DATA(lv_endda) = COND #( WHEN iv_endda IS INITIAL
                             THEN mv_endda
                             ELSE iv_endda ).

    DATA(ls_0001) = VALUE p0001( ).
    read_hr_infotype( EXPORTING iv_infty = '0001'
                                iv_begda = lv_begda
                                iv_endda = lv_endda
                      IMPORTING es_pnnnn = ls_0001 ).

    DATA(lt_boss_sign_lv_pl_2) = zcl_tvarvc=>get_const_range( 'ZRC_PA_3939_BOSS_SIGN_LV_PL_2' ).

    DATA(lv_bukrs_lvl_3) = xsdbool( xsdbool( ls_0001-bukrs IN lt_boss_sign_lv_pl_2 ) = abap_false ).

    DATA(lo_plans) = get_plans_via_pa( iv_check_auth = iv_check_auth
                                       iv_begda      = lv_begda
                                       iv_endda      = lv_endda ).

    IF lo_plans IS NOT BOUND.
    " Значит нет на тек дату, надо смотреть будущий приём.
        RAISE EXCEPTION TYPE cx_sy_ref_is_initial.
    ENDIF.

    lv_plans = lo_plans->ms_object.

    CLEAR: lt_p1001,
           lt_pernr,
           lo_plans_appr,
           lv_lvl_plans.

    " Определяем исключение Z12 (исключение S-S)
    TRY.
        " Для ШД сотрудника находим соединение Согл. Ком-ки Сотр-Рук
        DATA(lo_plans_appr_line) =
          lo_plans->read_relation( iv_subty      = lc_relation_s_s
                                   iv_requ_otype = zcl_hcm_values=>mc_otype-plans
                                   iv_check_auth = iv_check_auth ).
      CATCH cx_sy_ref_is_initial.
        RETURN.
    ENDTRY.

    TRY.
        lo_plans_appr_line->read_relation( EXPORTING iv_subty      = lc_relation_s_p
                                                     iv_requ_otype = zcl_hcm_values=>mc_otype-pernr
                                                     iv_check_auth = iv_check_auth
                                           IMPORTING et_p1001      = lt_p1001 ).

        IF NOT line_exists( lt_p1001[ 1 ] ).
          INSERT VALUE #( lvl   = 1
                          wegid = lc_relation_s_s ) INTO TABLE lt_appr.
        ELSE.

          lt_pernr = VALUE tt_pernr( FOR ls_p1001 IN lt_p1001
                                     WHERE (     sclas = zcl_hcm_values=>mc_otype-pernr
                                             AND prozt > 0 )
                                     ( pernr = ls_p1001-sobid
                                       prozt = ls_p1001-prozt ) ).

          INSERT VALUE #( lvl               = 1
                          objid             = lt_p1001[ 1 ]-objid
                          otype             = zcl_hcm_values=>mc_otype-plans
                          lvl_plans         = lv_lvl_plans
                          pernr             = lt_pernr
                          not_approver_bool = abap_true
                          prozt_bool        = abap_true
                          lvl_plans_bool    = abap_true
                          wegid             = lc_relation_s_s )
                 INTO TABLE lt_appr.
        ENDIF.
      CATCH cx_sy_ref_is_initial.
        INSERT VALUE #( lvl   = 1
                        wegid = lc_relation_s_s ) INTO TABLE lt_appr.
    ENDTRY.

    " Определяем исключение Z10 (исключение S-O)
    lo_plans->read_wegid( EXPORTING iv_wegid      = lc_wegid
                                    iv_requ_otype = zcl_hcm_values=>mc_otype-orgeh
                                    iv_check_auth = iv_check_auth
                          IMPORTING et_struc      = DATA(lt_struc) ).

    SORT lt_struc BY level ASCENDING.

    LOOP AT lt_struc ASSIGNING FIELD-SYMBOL(<ls_struc>).
      CLEAR: lt_p1001,
             lt_pernr,
             lo_plans_appr,
             lv_lvl_plans.

      lv_lines = REDUCE i( INIT lv_x = 0 FOR lv_wa IN lt_appr NEXT lv_x = lv_x + 1 ).
      DATA(lo_orgeh) =
        zcl_hcm_om_obj=>get_instance( iv_objid = CONV #( <ls_struc>-objid )
                                      iv_otype = <ls_struc>-otype
                                      iv_begda = lv_begda
                                      iv_endda = lv_endda ).

      IF lo_orgeh IS INITIAL.
        CONTINUE.
      ENDIF.

      DATA(lo_plans_org) =
        lo_orgeh->read_relation( iv_subty      = lc_relation_o_s
                                 iv_requ_otype = zcl_hcm_values=>mc_otype-plans
                                 iv_check_auth = iv_check_auth ).

      IF lo_plans_org IS INITIAL.
        CONTINUE.
      ENDIF.
      lo_plans_org->read_greyd( EXPORTING iv_check_auth = iv_check_auth
                                IMPORTING ev_trfgb      = lv_lvl_plans ).

      lo_plans_appr = zcl_hcm_om_obj=>get_instance( iv_objid = lo_plans_org->ms_object-objid
                                                    iv_otype = lo_plans_org->ms_object-otype
                                                    iv_begda = lv_begda
                                                    iv_endda = lv_endda ).

      lo_plans_appr->read_relation( EXPORTING iv_subty      = lc_relation_s_p
                                              iv_requ_otype = zcl_hcm_values=>mc_otype-pernr
                                              iv_check_auth = iv_check_auth
                                    IMPORTING et_p1001      = lt_p1001 ).

      IF NOT line_exists( lt_p1001[ 1 ] ).
        INSERT VALUE #( lvl   = 2
                        wegid = lc_relation_s_s ) INTO TABLE lt_appr.
      ELSE.

        lt_pernr = VALUE tt_pernr( FOR ls_p1001 IN lt_p1001
                                   WHERE (     sclas = zcl_hcm_values=>mc_otype-pernr
                                           AND prozt > 0 )
                                   ( pernr = ls_p1001-sobid
                                     prozt = ls_p1001-prozt ) ).

        INSERT VALUE #( lvl               = lv_lines + 1
                        objid             = lo_plans_org->ms_object-objid
                        otype             = lo_plans_org->ms_object-otype
                        lvl_plans         = lv_lvl_plans
                        pernr             = lt_pernr
                        not_approver_bool = abap_true
                        prozt_bool        = abap_true
                        lvl_plans_bool    = abap_true
                        wegid             = lc_relation_o_s )
               INTO TABLE lt_appr.
      ENDIF.
    ENDLOOP.
    IF NOT line_exists( lt_appr[ lvl = 2 ] ).
      INSERT VALUE #( lvl   = 2
                      wegid = lc_relation_o_s ) INTO TABLE lt_appr.
    ENDIF.

    " Основной алгоритм если IS INITIAL.

    lo_plans->read_wegid( EXPORTING iv_wegid      = lc_zboss_o
                                    iv_requ_otype = zcl_hcm_values=>mc_otype-plans
                          IMPORTING et_struc      = DATA(lt_boss) ).

    DELETE lt_boss WHERE rflag = abap_true.
    SORT lt_boss ASCENDING BY level.
    CLEAR lv_lines.
    LOOP AT lt_boss ASSIGNING FIELD-SYMBOL(<ls_struct>)
         WHERE objid <> lv_plans.

      CLEAR: lt_p1001,
             lt_pernr,
             lo_plans_appr,
             lv_lvl_plans.

      lv_lines = REDUCE i( INIT lv_x = 0 FOR lv_wa IN lt_appr NEXT lv_x = lv_x + 1 ).

      lo_plans_appr = zcl_hcm_om_obj=>get_instance( iv_objid = CONV #( <ls_struct>-objid )
                                                    iv_otype = <ls_struct>-otype
                                                    iv_begda = lv_begda
                                                    iv_endda = lv_endda ).

      lo_plans_appr->read_greyd( EXPORTING iv_check_auth = iv_check_auth " SavinovaEA 3000010592 12.11.2020
                                 IMPORTING ev_trfgb      = lv_lvl_plans ).

      lv_om_attrval = lo_plans_appr->get_attribute( iv_attrib     = lc_attrib
                                                    iv_scenario   = lc_scenario
                                                    iv_check_auth = iv_check_auth
                                                    iv_buf        = abap_true ).

      lo_plans_appr->read_relation( EXPORTING iv_subty      = lc_relation_s_p
                                              iv_requ_otype = zcl_hcm_values=>mc_otype-pernr
                                              iv_check_auth = iv_check_auth
                                    IMPORTING et_p1001      = lt_p1001 ).

      lt_pernr = VALUE tt_pernr( FOR ls_p1001 IN lt_p1001
                                 WHERE (     sclas = zcl_hcm_values=>mc_otype-pernr
                                         AND prozt > 0 )
                                 ( pernr = ls_p1001-sobid
                                   prozt = ls_p1001-prozt ) ).

      INSERT VALUE #( lvl               = lv_lines + 1
                      objid             = <ls_struct>-objid
                      otype             = <ls_struct>-otype
                      lvl_plans         = lv_lvl_plans
                      pernr             = lt_pernr
                      not_approver_bool = COND #( WHEN lv_om_attrval = abap_true THEN abap_false ELSE abap_true )
                      prozt_bool        = COND #( WHEN line_exists( lt_pernr[ 1 ] ) THEN abap_true )
                      lvl_plans_bool    = COND #(
                                                  WHEN (    lv_lvl_plans = 1
                                                         OR lv_lvl_plans = 2
                                                         OR lv_lvl_plans = 3 )
                                                   AND lv_bukrs_lvl_3 = abap_true               THEN abap_true
                                                  WHEN ( lv_lvl_plans = 1 OR lv_lvl_plans = 2 ) THEN abap_true
                                                  ELSE                                               abap_false )
                      wegid             = lc_zboss_o )
             INTO TABLE lt_appr.
    ENDLOOP.

    " Если ничего не нашли замыкаем сами на себя, только для руководителя подразделения ур. 1 или 2.
    IF NOT line_exists( lt_appr[ prozt_bool        = abap_true  "#EC CI_SORTSEQ
                                 lvl_plans_bool    = abap_true
                                 not_approver_bool = abap_true ] ).
      CLEAR: lt_p1001,
             lt_pernr,
             lo_plans_appr,
             lv_lvl_plans,
             lv_lines.

      lv_lines = REDUCE i( INIT lv_x = 0 FOR lv_wa IN lt_appr NEXT lv_x = lv_x + 1 ).

      lo_plans->read_relation( EXPORTING iv_subty      = lc_relation_s_p
                                         iv_requ_otype = zcl_hcm_values=>mc_otype-pernr
                                         iv_check_auth = iv_check_auth
                               IMPORTING et_p1001      = lt_p1001 ).
      IF NOT line_exists( lt_p1001[ 1 ] ).
        RETURN.
      ENDIF.

      lo_plans->read_greyd( EXPORTING iv_check_auth = iv_check_auth
                            IMPORTING ev_trfgb      = lv_lvl_plans ).
      IF lv_lvl_plans IS INITIAL.
        RETURN.
      ENDIF.

      lo_plans->read_relation( EXPORTING iv_subty      = lc_boss
                                         iv_requ_otype = zcl_hcm_values=>mc_otype-orgeh
                                         iv_check_auth = iv_check_auth
                               IMPORTING et_p1001      = DATA(lt_a012) ).

      IF NOT line_exists( lt_a012[ 1 ] ).
        RETURN.
      ENDIF.

      " не замыкаем сотрудника самого на себя, если выше есть атрибут "нельзя согласовывать"
      IF line_exists( lt_appr[ not_approver_bool = abap_false wegid = lc_zboss_o ] ).  "#EC CI_SORTSEQ
        RETURN.
      ENDIF.

      lt_pernr = VALUE tt_pernr( FOR ls_p1001 IN lt_p1001
                                 WHERE (     sclas = zcl_hcm_values=>mc_otype-pernr
                                         AND prozt > 0 )
                                 ( pernr = ls_p1001-sobid
                                   prozt = ls_p1001-prozt ) ).

      INSERT VALUE #( lvl               = lv_lines + 1
                      objid             = lt_p1001[ 1 ]-objid
                      otype             = zcl_hcm_values=>mc_otype-plans
                      lvl_plans         = lv_lvl_plans
                      pernr             = lt_pernr
                      not_approver_bool = abap_true
                      prozt_bool        = abap_true
                      lvl_plans_bool    = COND #( WHEN ( lv_lvl_plans = 1 OR lv_lvl_plans = 2 )
                                                  THEN abap_true
                                                  ELSE abap_false )
                      wegid             = lc_by_myself )
             INTO TABLE lt_appr.

    ENDIF.
    TRY.
        DATA(lv_pernr) = lt_appr[ prozt_bool        = abap_true  "#EC CI_SORTSEQ
                                  lvl_plans_bool    = abap_true
                                  not_approver_bool = abap_true ]-pernr[ 1 ]-pernr.
      CATCH cx_sy_itab_line_not_found.
        RETURN.
    ENDTRY.

    IF lv_pernr IS INITIAL.
      RAISE EXCEPTION TYPE zcx_hcm_relocation_integration MESSAGE e001(zmsg_3939).
    ELSEIF lv_pernr = mv_pernr AND lv_pernr IS NOT INITIAL.
      RAISE EXCEPTION TYPE zcx_hcm_relocation_integration MESSAGE e000(zmsg_3939).
    ELSEIF lv_pernr IS NOT INITIAL AND lv_pernr <> mv_pernr.
      ro_approver = get_instance( iv_pernr = lv_pernr
                                  iv_begda = lv_begda
                                  iv_endda = lv_endda ).
    ENDIF.
  ENDMETHOD.


  METHOD get_apr.
    DATA: ls_p0001 TYPE p0001.

    me->read_hr_infotype( EXPORTING iv_infty = '0001'
                          IMPORTING es_pnnnn = ls_p0001 ).

    DATA(lo_plans) = me->get_plans_via_pa( ).

    IF lo_plans IS NOT BOUND.
      RETURN.
    ENDIF.

    lo_plans->read_relation(
      EXPORTING
       iv_subty      = 'BZ06'
       iv_requ_otype = zcl_hcm_values=>mc_otype-plans
      IMPORTING
       et_p1001      = DATA(lt_p1001) ).

    IF lt_p1001 IS INITIAL.
      RETURN.
    ENDIF.

    IF iv_priox IS INITIAL.
      DATA(lv_apr_plans) = VALUE hrobjid( lt_p1001[ 1 ]-sobid OPTIONAL ).
    ELSE.
      lv_apr_plans = VALUE hrobjid( lt_p1001[ priox = iv_priox ]-sobid OPTIONAL ).

      lv_apr_plans = COND hrobjid( WHEN lv_apr_plans IS INITIAL AND iv_priox = '1'
                                   THEN lt_p1001[ 1 ]-sobid
                                   ELSE lv_apr_plans ).
    ENDIF.

    DATA(lo_plans_apr) =
         zcl_hcm_om_obj=>get_instance( iv_objid = lv_apr_plans
                                       iv_otype = zcl_hcm_values=>mc_otype-plans
                                       iv_begda = ls_p0001-begda
                                       iv_endda = ls_p0001-endda ).

    IF lo_plans_apr IS NOT BOUND.
      RETURN.
    ENDIF.

    lo_plans_apr->read_relation(
      EXPORTING
       iv_subty      = 'A008'
       iv_requ_otype = zcl_hcm_values=>mc_otype-pernr
      IMPORTING
        et_p1001     = lt_p1001 ).

    SORT lt_p1001 BY begda DESCENDING.

    TRY.
        DATA(lv_pernr) = CONV pernr_d( lt_p1001[ 1 ]-sobid ).
      CATCH cx_sy_itab_line_not_found.
        RETURN.
    ENDTRY.

    ro_person_apr = zcl_hcm_pa_obj=>get_instance( iv_pernr = lv_pernr ).
  ENDMETHOD.


  METHOD get_betrg.
    DATA: lt_p0001 TYPE TABLE OF p0001,
          lt_p0007 TYPE TABLE OF p0007,
          lt_p0008 TYPE TABLE OF p0008,
          lt_pbwla TYPE TABLE OF pbwla.

    me->read_hr_infotype( EXPORTING iv_infty = '0001'
                          IMPORTING et_pnnnn = lt_p0001 ).

    me->read_hr_infotype( EXPORTING iv_infty = '0007'
                         IMPORTING et_pnnnn = lt_p0007 ).

    me->read_hr_infotype( EXPORTING iv_infty = '0008'
                        IMPORTING et_pnnnn = lt_p0008 ).

    CLEAR: sy-msgid, sy-msgli, sy-msgno, sy-msgty.

    CALL FUNCTION 'RP_FILL_WAGE_TYPE_TABLE_EXT'
      EXPORTING
        pernr                        = me->mv_pernr
        begda                        = me->mv_begda
        endda                        = me->mv_endda
      TABLES
        pp0001                       = lt_p0001
        pp0007                       = lt_p0007
        pp0008                       = lt_p0008
        ppbwla                       = lt_pbwla
      EXCEPTIONS
        error_at_indirect_evaluation = 1.

    IF sy-subrc <> 0 AND lines( lt_pbwla ) = 0.
      RETURN.
    ENDIF.

    LOOP AT lt_pbwla ASSIGNING FIELD-SYMBOL(<fs_pbwla>)
       WHERE begda <= me->mv_begda AND
             endda >= me->mv_begda AND
             lgart = iv_lgart.
      rv_betrg-betrg = <fs_pbwla>-betrg.
      rv_betrg-anzhl = <fs_pbwla>-anzhl.
      EXIT.
    ENDLOOP.

  ENDMETHOD.


  METHOD get_birthplace.
    CONSTANTS: lc_rubp  TYPE subty VALUE 'RUBP',
               lc_0006  TYPE infty VALUE '0006',
               lc_comma TYPE char1 VALUE ','.

    DATA: lt_p0006 TYPE STANDARD TABLE OF p0006,
          ls_p0006 TYPE p0006.

    me->read_hr_infotype(
      EXPORTING
        iv_infty      = lc_0006
        iv_subty      = lc_rubp
      IMPORTING
        et_pnnnn      = lt_p0006 ).

    TRY.
        ls_p0006 = lt_p0006[ 1 ].
      CATCH cx_sy_itab_line_not_found.
        RETURN.
    ENDTRY.

    IF ls_p0006-adr03 IS NOT INITIAL. "Страна
      rv_birthplace = rv_birthplace && ls_p0006-adr03 && lc_comma.
    ENDIF.

    IF ls_p0006-adr04 IS NOT INITIAL. "Область
      rv_birthplace = rv_birthplace && ` ` && ls_p0006-adr04 && lc_comma.
    ENDIF.

    IF ls_p0006-num04 IS NOT INITIAL. "Город
      rv_birthplace = rv_birthplace && ` ` && ls_p0006-num04 && lc_comma.
    ENDIF.

    IF ls_p0006-or2kk IS NOT INITIAL. "Район
      rv_birthplace = rv_birthplace && ` ` && ls_p0006-or2kk.
    ENDIF.

    "При надобности удаляем запятую в конце
    IF rv_birthplace IS INITIAL.
      RETURN.
    ENDIF.

    DATA(lv_last_char) = substring( val = rv_birthplace off = strlen( rv_birthplace ) - 1 len = 1 ).

    rv_birthplace = condense( rv_birthplace ).

    IF lv_last_char = lc_comma.
      rv_birthplace = substring( val = rv_birthplace off = 0 len = strlen( rv_birthplace ) - 1 ).
    ENDIF.

  ENDMETHOD.


  METHOD get_boss.
    DATA: lt_0001      TYPE STANDARD TABLE OF p0001,
          lv_prozt_max TYPE prozt,
          lt_bosses    TYPE p1001_t.
    DATA(lv_begda) = COND begda( WHEN iv_begda IS INITIAL THEN mv_begda
                                                          ELSE iv_begda ).
    DATA(lv_endda) = COND endda( WHEN iv_endda IS INITIAL THEN mv_endda
                                                          ELSE iv_endda ).

    "В зависимости от флага, определяем организацию
    IF if_orgeh_via_om IS INITIAL.
      "Либо из записи ИТ 0001 сотрудника
      DATA(lo_orgeh) = me->get_orgeh_via_pa( iv_begda      = lv_begda
                                             iv_endda      = lv_endda
                                             iv_check_auth = iv_check_auth  ).

    ELSE.
      "либо из ОМ присвоения (в этом случае непечатные Ошки берутся в расчет)
      lo_orgeh = me->get_orgeh_via_om( iv_begda      = lv_begda
                                       iv_endda      = lv_endda
                                       iv_check_auth = iv_check_auth  ).
    ENDIF.
    IF lo_orgeh IS INITIAL.
      RETURN.
    ENDIF.

    lo_orgeh->read_wegid( EXPORTING iv_wegid      = 'P-S-O-O'
                                    iv_requ_otype = zcl_hcm_values=>mc_otype-orgeh
                                    iv_include_me = abap_true
                                    iv_check_auth = iv_check_auth
                          IMPORTING et_struc      = DATA(lt_struc) ).

    LOOP AT lt_struc ASSIGNING FIELD-SYMBOL(<ls_struc>).
      DATA(lo_orgeh_up) = zcl_hcm_om_obj=>get_instance(
                              iv_objid      = CONV #( <ls_struc>-objid )
                              iv_otype      = <ls_struc>-otype
                              iv_begda      = lv_begda
                              iv_endda      = lv_endda ).

      TRY .
          DATA(lo_plans_boss) = lo_orgeh_up->read_relation(
                                         iv_subty = 'B012'
                                         iv_requ_otype = zcl_hcm_values=>mc_otype-plans
                                         iv_check_auth = iv_check_auth ).

          lo_plans_boss->read_relation( EXPORTING
                                           iv_subty = 'A008'
                                           iv_requ_otype = zcl_hcm_values=>mc_otype-pernr
                                           iv_check_auth = iv_check_auth
                                        IMPORTING
                                           et_p1001 = lt_bosses ).

          LOOP AT lt_bosses ASSIGNING FIELD-SYMBOL(<ls_boss>).
            IF lv_prozt_max < <ls_boss>-prozt.
              DATA(lo_pernr_obj_boss) = zcl_hcm_om_obj=>get_instance(
                                                            iv_objid = CONV #( <ls_boss>-sobid )
                                                            iv_otype = zcl_hcm_values=>mc_otype-pernr
                                                            iv_begda = lv_begda
                                                            iv_endda = lv_endda ).
            ENDIF.
          ENDLOOP.

          IF lo_pernr_obj_boss IS INITIAL.
            CONTINUE.
          ENDIF.

          DATA(lv_pernr_boss) = lo_pernr_obj_boss->ms_object-objid.

          ro_boss = zcl_hcm_pa_obj=>get_instance( iv_pernr = lv_pernr_boss
                                                  iv_begda = lv_begda
                                                  iv_endda = lv_endda ).

          IF ro_boss IS NOT INITIAL AND
             ro_boss->mv_pernr <> me->mv_pernr.
            EXIT.
          ENDIF.

        CATCH cx_sy_ref_is_initial.
      ENDTRY.

    ENDLOOP.
  ENDMETHOD.


  METHOD get_cpind.
    DATA lv_dt TYPE begda.
    DATA lt_p0008  TYPE STANDARD TABLE OF p0008.
    IF iv_date IS INITIAL.
      lv_dt = me->mv_begda.
    ELSE.
      lv_dt = iv_date.
    ENDIF.

    me->read_hr_infotype( EXPORTING iv_infty = '0008'
                          IMPORTING et_pnnnn = lt_p0008 ).

    LOOP AT lt_p0008 INTO DATA(ls_0008)
      WHERE pernr = mv_pernr
        AND begda <= lv_dt
        AND endda >= lv_dt.
    ENDLOOP.

    rv_cpind = COND p_cpind( WHEN ls_0008-cpind IS INITIAL OR ls_0008 IS INITIAL
                             THEN 'S'
                             ELSE ls_0008-cpind ).

  ENDMETHOD.


  METHOD get_cp_obj.

    DATA: lt_p1001_cp TYPE STANDARD TABLE OF p1001.

    " CP
    CALL FUNCTION 'RH_READ_INFTY'
      EXPORTING
        plvar  = cl_hrtmc_const=>plvar
        otype  = cl_hrtmc_const=>otype_person
        objid  = mv_pernr
        infty  = '1001'
        istat  = '1'
        subty  = 'A209'
        begda  = mv_begda
        endda  = mv_endda
      TABLES
        innnn  = lt_p1001_cp
      EXCEPTIONS
        OTHERS = 1.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    LOOP AT lt_p1001_cp ASSIGNING FIELD-SYMBOL(<ls_p1001_cp>) WHERE sclas = 'CP'.
      rv_cpobj = CONV hrobjid( <ls_p1001_cp>-sobid ).
      EXIT.
    ENDLOOP.

  ENDMETHOD.


  METHOD get_date_of_reciept.
    DATA: lt_p0000 TYPE TABLE OF p0000.

    CALL FUNCTION 'HR_READ_INFOTYPE'
      EXPORTING
        pernr           = mv_pernr
        infty           = '0000'
        begda           = zcl_hcm_values=>mc_date-min
        endda           = iv_date
      TABLES
        infty_tab       = lt_p0000
      EXCEPTIONS
        infty_not_found = 1
        invalid_input   = 2
        OTHERS          = 3.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    SORT lt_p0000 BY begda DESCENDING.

    LOOP AT lt_p0000 ASSIGNING FIELD-SYMBOL(<fs_p0000>).
      DATA(lv_massn_mask) = <fs_p0000>-massn(1).
      IF lv_massn_mask = 'A' .
        WRITE <fs_p0000>-begda TO rv_date.
        EXIT.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.


  METHOD get_def_date.

    DATA lt_0041            TYPE TABLE OF p0041.

    read_hr_infotype(
      EXPORTING
        iv_infty      = '0041'                 " Инфо-тип
*      iv_subty      = '*'              " Подтип
*      iv_check_auth = 'X'              " Общий флаг
*      iv_begda      =                  " Дата начала
*      iv_endda      =                  " Дата окончания
*      iv_sprps      = '*'              " Считать заблокированные записи
      IMPORTING
        et_pnnnn      = lt_0041
    ).

* Заполнить список ссылочных ТН
    LOOP AT lt_0041 ASSIGNING FIELD-SYMBOL(<fs_0041>).
      DO 24 TIMES.
        DATA l_num TYPE n LENGTH 2.
        DATA l_dar(30).
        DATA l_dat(30).
        l_num = sy-index.
        l_dar = 'DAR' && l_num.
        l_dat = 'DAT' && l_num.
        ASSIGN COMPONENT l_dar OF STRUCTURE <fs_0041> TO FIELD-SYMBOL(<fs_dar>).
        ASSIGN COMPONENT l_dat OF STRUCTURE <fs_0041> TO FIELD-SYMBOL(<fs_dat>).
        IF <fs_dar> IS ASSIGNED
          AND <fs_dat> IS ASSIGNED
          AND sy-subrc = 0.
          IF <fs_dar> = iv_dar.
            rv_value = <fs_dat>.
            EXIT.
          ENDIF.
        ENDIF.
      ENDDO.
    ENDLOOP.

  ENDMETHOD.


  METHOD get_email.
    DATA lt_p0105 TYPE STANDARD TABLE OF p0105.

    IF mv_no_auth = abap_true.
      DATA(lv_check_auth) = abap_false.
    ELSE.
      lv_check_auth = abap_true.
    ENDIF.

    read_hr_infotype(
      EXPORTING
        iv_infty      = '0105'
        iv_subty      = mc_mail
        iv_check_auth = lv_check_auth
      IMPORTING
        et_pnnnn      = lt_p0105 ).
    rv_mail = VALUE #( lt_p0105[ lines( lt_p0105 ) ]-usrid_long OPTIONAL ).
  ENDMETHOD.


  METHOD get_empl_contract.

    DATA: lt_attrib   TYPE TABLE OF pt1222.

    DATA(lv_scenario) = CONV om_attrscn( zcl_tvarvc=>get_const( iv_name = 'ZHCM_SCENARIO_0274' ) ).
    DATA(lv_attrib) = zcl_tvarvc=>get_const( iv_name = 'ZHCM_ATTRIB_1_0274' ).

    IF iv_plans IS INITIAL.
      DATA(lo_plans) = me->get_plans_via_pa( iv_check_auth = abap_true
                                             iv_begda      = me->mv_begda
                                             iv_endda      = me->mv_endda ).
    ELSE.
      lo_plans = zcl_hcm_om_obj=>get_instance( EXPORTING iv_objid = iv_plans
                                                         iv_otype = zcl_hcm_values=>mc_otype-plans
                                                         iv_begda = me->mv_begda
                                                         iv_endda = me->mv_endda ).
    ENDIF.

    IF lo_plans IS INITIAL.
      RETURN.
    ENDIF.

    CALL FUNCTION 'RH_OM_ATTRIBUTES_READ'
      EXPORTING
        plvar            = lo_plans->ms_object-plvar
        otype            = lo_plans->ms_object-otype
        objid            = lo_plans->ms_object-objid
        scenario         = lv_scenario
        seldate          = me->mv_begda
      TABLES
        attrib           = lt_attrib
      EXCEPTIONS
        no_active_plvar  = 1
        no_attributes    = 2
        no_values        = 3
        object_not_found = 4
        OTHERS           = 5.
    IF sy-subrc EQ 0.
      TRY.
          rv_ansvh = lt_attrib[ attrib = lv_attrib ]-low.
        CATCH cx_root.
          RETURN.
      ENDTRY.
    ENDIF.

  ENDMETHOD.


  METHOD get_fact_address.

    DATA: lt_t7ru9a TYPE STANDARD TABLE OF t7ru9a,
          lt_p0001  TYPE STANDARD TABLE OF p0001,
          ls_prumy  TYPE prumy,
          ls_key    TYPE t7ru9a,
          lv_soort  TYPE p33_soort VALUE '01',
          lv_back   TYPE text30,
          lv_text   TYPE text30.

    IF iv_lang = 'E'.
      lv_soort = '99'. "Английский язык
    ENDIF.

    me->read_hr_infotype(
          EXPORTING
            iv_infty      = '0001'
          IMPORTING
            et_pnnnn      = lt_p0001 ).

    TRY.
        DATA(ls_p0001) = lt_p0001[ 1 ].
      CATCH cx_sy_itab_line_not_found.
        RETURN.
    ENDTRY.

    MOVE-CORRESPONDING ls_p0001 TO ls_prumy.
    CALL FUNCTION 'HR_FEATURE_BACKFIELD'
      EXPORTING
        feature                     = '33OKT'
        struc_content               = ls_prumy
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

    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    SPLIT lv_back AT '/' INTO lv_text lv_back.
    ls_key-instl  = '000'.
    ls_key-soort = '01'.
    ls_key-juper = ls_p0001-juper.
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
      CLEAR lt_t7ru9a.
    ENDIF.

    TRY.
        rs_t7ru9a = lt_t7ru9a[ 1 ].
      CATCH cx_sy_itab_line_not_found.
        CLEAR rs_t7ru9a.
    ENDTRY.

    SELECT SINGLE bezei
      FROM  t005u INTO @DATA(lv_state)
      WHERE land1 = 'RU' AND bland = @rs_t7ru9a-state AND spras = 'R'.

*    ev_factadd = rs_t7ru9a-pstlz && ',' && ` ` && lv_state && ',' && ` ` &&
*    rs_t7ru9a-ort01 && ',' && ` ` && rs_t7ru9a-stras && ',' && ` ` && rs_t7ru9a-hsnmr.

    ev_factadd = rs_t7ru9a-pstlz.
    IF lv_state IS NOT INITIAL.
      ev_factadd = ev_factadd && `, ` &&  lv_state.
    ENDIF.

    IF rs_t7ru9a-ort01 IS NOT INITIAL.
      ev_factadd = ev_factadd && `, ` &&  rs_t7ru9a-ort01.
    ENDIF.

    IF rs_t7ru9a-stras IS NOT INITIAL.
      ev_factadd = ev_factadd && `, ` &&  rs_t7ru9a-stras.
    ENDIF.

    IF rs_t7ru9a-hsnmr IS NOT INITIAL.
      ev_factadd = ev_factadd && `, ` &&  rs_t7ru9a-hsnmr.
    ENDIF.

    IF rs_t7ru9a-bldng IS NOT INITIAL.
      ev_factadd = ev_factadd && `, ` &&  rs_t7ru9a-bldng.
    ENDIF.
    IF ev_factadd IS NOT INITIAL.
      IF ev_factadd(1) = ','.
        SHIFT ev_factadd BY 2 PLACES LEFT.
      ENDIF.
    ENDIF.


  ENDMETHOD.


  METHOD get_feature.
    DATA: lr_struc TYPE REF TO data,
          lt_p0001 TYPE TABLE OF p0001.

    FIELD-SYMBOLS <fs_struc> TYPE any.

    CREATE DATA lr_struc TYPE (iv_structure).
    ASSIGN lr_struc->* TO <fs_struc>.

    IF sy-subrc <> 0.
      RETURN.
    ENDIF.
    IF is_0001 IS INITIAL.
      me->read_hr_infotype(
      EXPORTING
        iv_infty      = '0001'
      IMPORTING
        et_pnnnn      =  lt_p0001 ).
      TRY.
          DATA(ls_p0001) = lt_p0001[ 1 ].
        CATCH cx_sy_itab_line_not_found.
          RETURN.
      ENDTRY.
    ELSE.
      ls_p0001 = is_0001.
    ENDIF.

    MOVE-CORRESPONDING ls_p0001 TO  <fs_struc>.

    CALL FUNCTION 'HR_FEATURE_BACKFIELD'
      EXPORTING
        feature                     = iv_feature
        struc_content               = <fs_struc>
      IMPORTING
        back                        = rv_value
      EXCEPTIONS
        dummy                       = 1
        error_operation             = 2
        no_backvalue                = 3
        feature_not_generated       = 4
        invalid_sign_in_funid       = 5
        field_in_report_tab_in_pe03 = 6
        OTHERS                      = 7.
    IF sy-subrc <> 0.
    ENDIF.

  ENDMETHOD.


  METHOD get_fio.
    DATA: lt_p0002      TYPE TABLE OF p0002,
          lt_p0290      TYPE TABLE OF p0290,
          ls_p0002      TYPE p0002,
          ls_p0290      TYPE p0290,
          lv_surname    TYPE text40,
          lv_name       TYPE text40,
          lv_patronymic TYPE text40.

    DATA: lv_check_auth TYPE flag.
    CLEAR: lv_check_auth.
    IF mv_no_auth = abap_true.
      lv_check_auth = abap_false.
    ELSE.
      lv_check_auth = abap_true.
    ENDIF.

    me->read_hr_infotype( EXPORTING
                            iv_infty  = '0002'
                            iv_check_auth = lv_check_auth
                          IMPORTING
                            et_pnnnn = lt_p0002 ).

    me->read_hr_infotype( EXPORTING
                            iv_infty  = '0290'
                            iv_subty  = '22'
                            iv_check_auth = lv_check_auth
                          IMPORTING
                            et_pnnnn = lt_p0290 ).

    SORT lt_p0002 BY begda DESCENDING. "SavinovaEA

    TRY.
        ls_p0002 = lt_p0002[ 1 ].
      CATCH cx_sy_itab_line_not_found.
        RETURN.
    ENDTRY.

    CASE iv_lang.
      WHEN 'R'.
        lv_surname    = ls_p0002-nachn.
        lv_name       = ls_p0002-vorna.
        lv_patronymic = ls_p0002-midnm.
      WHEN 'E'.
        TRY.
            ls_p0290 = lt_p0290[ 1 ].
            IF ls_p0290-zznachn_lat IS NOT INITIAL.
              lv_surname    = ls_p0290-zznachn_lat.
            ELSE.
              lv_surname    = ls_p0002-fnamr.
            ENDIF.
            IF ls_p0290-zzvorna_lat IS NOT INITIAL.
              lv_name       = ls_p0290-zzvorna_lat.
            ELSE.
              lv_name       = ls_p0002-lnamr.
            ENDIF.
          CATCH cx_sy_itab_line_not_found.
            lv_surname    = ls_p0002-fnamr.
            lv_name       = ls_p0002-lnamr.
        ENDTRY.
    ENDCASE.

    IF iv_is_short = abap_true AND iv_lang = 'R' AND lv_patronymic IS NOT INITIAL.
      ev_fio = |{ lv_surname } { lv_name(1) }. { lv_patronymic(1) }.|.
      RETURN.
    ELSEIF iv_is_short = abap_true AND iv_lang = 'R'.
      ev_fio = |{ lv_surname } { lv_name(1) }.|.
      RETURN.
    ELSEIF iv_for_www = abap_true AND iv_lang = 'R' AND lv_patronymic IS NOT INITIAL.
      ev_fio = lv_surname && lv_name(1) && lv_patronymic(1).
      RETURN.
    ELSEIF iv_for_www = abap_true AND iv_lang = 'R'.
      ev_fio = lv_surname && lv_name(1).
      RETURN.
    ELSEIF iv_for_www = abap_true AND iv_lang = 'E'.
      ev_fio = lv_surname && lv_name(1).
      RETURN.
    ENDIF.

    ev_nachn = lv_surname.
    ev_vorna = lv_name.
    ev_midnm = lv_patronymic.

    IF iv_surname = abap_true.
      ev_fio   = ev_fio && lv_surname.
    ENDIF.

    IF iv_name = abap_true.
      ev_fio   = ev_fio && ` ` && lv_name.
    ENDIF.

    IF iv_patronymic = abap_true.
      ev_fio   = ev_fio && ` ` && lv_patronymic.
    ENDIF.
    ev_fio = condense( ev_fio ).
  ENDMETHOD.


  METHOD get_hire_fire_dates.

    CLEAR: et_phifi, ev_fire, ev_hire.

    CALL FUNCTION 'HR_RU_HIRE_FIRE_DATES'
      EXPORTING
        p_pernr         = mv_pernr
        p_begda         = mv_begda
        p_endda         = mv_endda
      IMPORTING
        p_phifi         = et_phifi
      EXCEPTIONS
        no_molga        = 1
        no_infotype_reg = 2
        error           = 3
        OTHERS          = 4.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    READ TABLE et_phifi INTO DATA(ls_phifi) WITH KEY active = abap_true.
    IF sy-subrc = 0.
      ev_hire = ls_phifi-begda.
    ENDIF.

    LOOP AT et_phifi INTO ls_phifi WHERE active = abap_true.
      ev_fire = ls_phifi-endda.
    ENDLOOP.

  ENDMETHOD.


  METHOD get_infty_notes.
    DATA: ls_key TYPE pskey.

    IF it_pnnnn IS INITIAL.
      me->read_hr_infotype(
        EXPORTING
          iv_infty      = iv_infty
        IMPORTING
          et_pnnnn      = it_pnnnn ).
    ENDIF.

    LOOP AT it_pnnnn ASSIGNING FIELD-SYMBOL(<fs_pnnnn>).
      MOVE-CORRESPONDING <fs_pnnnn> TO ls_key.
      EXIT.
    ENDLOOP.

    CALL FUNCTION 'HR_READ_INFTY_NOTE'
      EXPORTING
        key            = ls_key
      TABLES
        text           = rt_notes
      EXCEPTIONS
        not_found      = 1
        not_authorized = 2
        OTHERS         = 3.
    IF sy-subrc <> 0.

    ENDIF.

  ENDMETHOD.


  METHOD get_instance.

    CLEAR ev_exist.

    IF iv_valid = abap_true.
*{ 3000016481 SereginVA
      IF NOT zcl_hcm_utils=>employee_exist_check( iv_date  = iv_begda
                                                  iv_pernr = iv_pernr ).
        RETURN.
      ENDIF.
*} 3000016481 SereginVA
*      CALL FUNCTION 'P_EMPLOYEE_CHECKEXISTENCE'
*        EXPORTING
*          object_id          = iv_pernr
*          date               = iv_begda
*        EXCEPTIONS
*          employee_not_found = 1
*          OTHERS             = 2.
*      IF sy-subrc <> 0.
*        RETURN.
*      ENDIF.
    ENDIF.

    ev_exist  = abap_true.

    ro_object = NEW #( ).

    ro_object->mv_pernr = iv_pernr.

    ro_object->mv_begda = iv_begda.
    ro_object->mv_endda = iv_endda.

    ro_object->mo_pernr = zcl_hcm_om_obj=>get_instance( iv_objid = iv_pernr
                                                        iv_otype = zcl_hcm_values=>mc_otype-pernr
                                                        iv_begda = iv_begda
                                                        iv_endda = iv_endda ).

    ro_object->mv_no_auth = COND #( WHEN iv_no_auth = abap_true
                                    THEN abap_true ).

  ENDMETHOD.


  METHOD get_mvz.

    DATA: lt_p0001 TYPE TABLE OF p0001.

    CLEAR: rs_cskt.

    IF iv_kostl IS NOT INITIAL AND iv_kokrs IS NOT INITIAL.
      DATA(lv_kokrs) = iv_kokrs.
      DATA(lv_kostl) = iv_kostl.
    ELSE.
      me->read_hr_infotype( EXPORTING iv_infty = '0001'
                                      iv_check_auth = iv_check_auth
                            IMPORTING et_pnnnn = lt_p0001 ).

      TRY.
          DATA(ls_p0001) = lt_p0001[ 1 ].
          lv_kokrs = ls_p0001-kokrs.
          lv_kostl = ls_p0001-kostl.
        CATCH cx_root.
          RETURN.
      ENDTRY.
    ENDIF.

    CALL FUNCTION 'READ_COSTCENTER_TEXT'
      EXPORTING
        datum          = me->mv_begda
        kokrs          = lv_kokrs
        kostl          = lv_kostl
        sprache        = sy-langu
      IMPORTING
        text_wa        = rs_cskt
      EXCEPTIONS
        text_not_found = 1
        OTHERS         = 2.
    IF sy-subrc <> 0.

    ENDIF.

  ENDMETHOD.


  METHOD get_old_pernr.
    DATA: lt_p1001_cp TYPE STANDARD TABLE OF p1001,
          lt_p1001_p  TYPE STANDARD TABLE OF p1001.

    " CP
    CALL FUNCTION 'RH_READ_INFTY'
      EXPORTING
        infty  = '1001'
        istat  = '1'
        subty  = 'A209'
        begda  = mv_begda
        endda  = mv_endda
      TABLES
        innnn  = lt_p1001_cp
      EXCEPTIONS
        OTHERS = 1.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    " P
    LOOP AT lt_p1001_cp ASSIGNING FIELD-SYMBOL(<ls_p1001_cp>)
      WHERE sclas = 'CP'.

      CALL FUNCTION 'RH_READ_INFTY'
        EXPORTING
          infty  = '1001'
          istat  = '1'
          subty  = 'A209'
          begda  = mv_begda
          endda  = mv_endda
        TABLES
          innnn  = lt_p1001_p
        EXCEPTIONS
          OTHERS = 1.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      LOOP AT lt_p1001_p ASSIGNING FIELD-SYMBOL(<ls_p1001_p>).
        APPEND CONV pernr_d( <ls_p1001_p>-sobid ) TO rt_pernr_tab.
      ENDLOOP.

    ENDLOOP.
    SORT rt_pernr_tab.
    DELETE ADJACENT DUPLICATES FROM rt_pernr_tab.
    DELETE rt_pernr_tab WHERE table_line = mv_pernr.

  ENDMETHOD.


  METHOD get_orgeh_head.


    DATA(lv_begda) = me->mv_begda.
    DATA(lv_endda) = me->mv_endda.


    me->mo_pernr->read_wegid( EXPORTING iv_wegid      = 'B008'
                                         iv_requ_otype = 'S'
                                         iv_begda = lv_begda
                                         iv_endda = lv_endda
                             IMPORTING et_actor = DATA(lt_actor) ).

    DATA(lv_obj_s) = VALUE hrobjid( lt_actor[ 1 ]-objid OPTIONAL ).

    LOOP AT lt_actor ASSIGNING FIELD-SYMBOL(<ls_actor>).
      DATA(lo_om_obj) = zcl_hcm_om_obj=>get_instance( iv_begda = lv_begda
                                                        iv_endda = lv_endda
                                                        iv_objid = CONV #( <ls_actor>-objid )
                                                        iv_otype = 'S' ).

      IF lo_om_obj IS NOT INITIAL.
        lo_om_obj->read_wegid( EXPORTING iv_wegid = 'A012'
                               IMPORTING et_actor = DATA(lt_actor_o) ).

        rv_orgeh = VALUE hrobjid( lt_actor_o[ 1 ]-objid OPTIONAL ).
        APPEND LINES OF lt_actor_o TO et_actor.
        CLEAR lt_actor_o.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD get_orgeh_via_om.

    IF iv_begda IS INITIAL.
      DATA(lv_begda) = me->mv_begda.
    ELSE.
      lv_begda = iv_begda.
    ENDIF.

    IF iv_endda IS INITIAL.
      DATA(lv_endda) = me->mv_endda.
    ELSE.
      lv_endda = iv_endda.
    ENDIF.

    me->mo_pernr->read_wegid( EXPORTING iv_wegid      = 'P-S-O'
*                                         iv_depth      = 2
                                         iv_requ_otype = zcl_hcm_values=>mc_otype-orgeh
                                         iv_check_auth = iv_check_auth
**                                    iv_include_me = abap_true
                                         iv_begda = lv_begda
                                         iv_endda = lv_endda
                             IMPORTING et_actor = DATA(lt_actor) ).

    DATA(lv_objid) = VALUE hrobjid( lt_actor[ 1 ]-objid OPTIONAL ).

    ro_orgeh = zcl_hcm_om_obj=>get_instance( iv_otype = 'O'
                                             iv_objid = lv_objid
                                             iv_begda = lv_begda
                                             iv_endda = lv_endda ).
  ENDMETHOD.


  METHOD get_orgeh_via_pa.
    DATA lt_0001 TYPE TABLE OF p0001.

    IF iv_begda IS INITIAL.
      DATA(lv_begda) = me->mv_begda.
    ELSE.
      lv_begda = iv_begda.
    ENDIF.

    IF iv_endda IS INITIAL.
      DATA(lv_endda) = me->mv_endda.
    ELSE.
      lv_endda = iv_endda.
    ENDIF.

    me->read_hr_infotype( EXPORTING iv_infty = '0001'
                                    iv_check_auth = iv_check_auth
                          IMPORTING et_pnnnn = lt_0001 ).

    TRY .
        DATA(lv_objid) = CONV hrobjid( lt_0001[ 1 ]-orgeh ).
      CATCH cx_sy_itab_line_not_found.
        CLEAR lv_objid.
    ENDTRY.

    ro_orgeh = zcl_hcm_om_obj=>get_instance( iv_otype = 'O'
                                             iv_objid = lv_objid
                                             iv_begda = lv_begda
                                             iv_endda = lv_endda ).
  ENDMETHOD.


  METHOD get_orgeh_via_pa_on_date.
*{ 3000011892 LapshovIA 12.08.2021
*   Считывание по входной дате
    DATA lt_0001 TYPE TABLE OF p0001.

    IF iv_begda IS INITIAL.
      DATA(lv_begda) = me->mv_begda.
    ELSE.
      lv_begda = iv_begda.
    ENDIF.

    IF iv_endda IS INITIAL.
      DATA(lv_endda) = me->mv_endda.
    ELSE.
      lv_endda = iv_endda.
    ENDIF.

    me->read_hr_infotype( EXPORTING iv_infty = '0001'
                                    iv_check_auth = iv_check_auth
                                    iv_begda = lv_begda
                                    iv_endda = lv_endda
                          IMPORTING et_pnnnn = lt_0001 ).

    TRY .
        DATA(lv_objid) = CONV hrobjid( lt_0001[ 1 ]-orgeh ).
      CATCH cx_sy_itab_line_not_found.
        CLEAR lv_objid.
    ENDTRY.

    ro_orgeh = zcl_hcm_om_obj=>get_instance( iv_otype = 'O'
                                             iv_objid = lv_objid
                                             iv_begda = lv_begda
                                             iv_endda = lv_endda ).
*} 3000011892 LapshovIA 12.08.2021
  ENDMETHOD.


  METHOD get_passport.
    CONSTANTS:
      lc_subty_21 TYPE subty VALUE '21',
      lc_subty_10 TYPE subty VALUE '10'.
    DATA:
      lt_p0290     TYPE TABLE OF p0290.

    rv_pasport = get_passport_new(
                    IMPORTING
                      es_p0290 = es_p0290 ).
    RETURN.

    me->read_hr_infotype(
      EXPORTING
        iv_infty      = '0290'
      IMPORTING
        et_pnnnn      = lt_p0290
    ).

    IF lt_p0290 IS NOT INITIAL.
      READ TABLE lt_p0290 ASSIGNING FIELD-SYMBOL(<fs_p0290>) WITH KEY subty = lc_subty_21.
      IF sy-subrc EQ 0.
        rv_pasport = 'серия' && | | && <fs_p0290>-seria && | | && <fs_p0290>-seri0 && | | && 'номер' && | | && <fs_p0290>-nomer
                                        && ', выдан' && | | && <fs_p0290>-datbg+6(2) && '.' && <fs_p0290>-datbg+4(2)
                                        && '.' && <fs_p0290>-datbg(4) && | | && 'г.' && | | && <fs_p0290>-passl && | | && <fs_p0290>-passl2
                                        && | | && <fs_p0290>-pcode.
        es_p0290 = <fs_p0290>.

      ELSE.
        READ TABLE lt_p0290 ASSIGNING <fs_p0290> WITH KEY subty = lc_subty_10.
        IF sy-subrc EQ 0.
          rv_pasport = 'серия' && | | && <fs_p0290>-seria && | | && <fs_p0290>-seri0 && | | && 'номер' && | | && <fs_p0290>-nomer
                                         && ', выдан' && | | && <fs_p0290>-datbg && | | && 'г.' && | | && <fs_p0290>-passl && | | && <fs_p0290>-passl2
                                         && | | && <fs_p0290>-pcode.
          es_p0290 = <fs_p0290>.
        ENDIF.
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD get_passport_new.
    CONSTANTS:
      BEGIN OF lc_subty,
        subty_21 TYPE subty VALUE '21',
        subty_10 TYPE subty VALUE '10',
      END   OF lc_subty,

      lc_infty_0290 TYPE infty VALUE '0290'.

    DATA:
      lt_p0290 TYPE TABLE OF p0290.

    CLEAR:
      es_p0290,
      rv_pasport.

    me->read_hr_infotype(
      EXPORTING
        iv_infty      = lc_infty_0290
      IMPORTING
        et_pnnnn      = lt_p0290
    ).

    IF lt_p0290 IS INITIAL.
      RETURN.
    ENDIF.

    DATA(lv_subty) = lc_subty-subty_21.

    TRY.
        es_p0290 = lt_p0290[ subty = lv_subty ].
      CATCH cx_sy_itab_line_not_found.
        IF lv_subty = lc_subty-subty_10.
          RETURN.
        ELSE.
          lv_subty = lc_subty-subty_10.
          RETRY.
        ENDIF.
    ENDTRY.

    rv_pasport = TEXT-ps1 && ` ` && es_p0290-seria
                                 && es_p0290-seri0      && ` ` &&
                TEXT-ps2 && ` ` && es_p0290-nomer      && ',' &&  ` ` &&
                TEXT-ps3 && ` ` && es_p0290-datbg+6(2) && '.' &&
                                   es_p0290-datbg+4(2) && '.' &&
                                   es_p0290-datbg(4)   && ` ` &&
                                   TEXT-ps6            && ',' &&  ` ` &&
                TEXT-ps4 && ` ` && es_p0290-passl && COND #( WHEN es_p0290-passl2 IS NOT INITIAL "SavinovaEA
                                     THEN` ` && es_p0290-passl2
                                     ELSE '' )   && ',' &&  ` ` &&
                TEXT-ps5 && ` ` && es_p0290-pcode.

  ENDMETHOD.

  METHOD get_percentage_of_emp.
    TYPES: BEGIN OF ty_structab,
             pernr TYPE p0001-pernr,
             prozt TYPE p1001-prozt,
             otype TYPE p1001-otype,
             plste TYPE p1001-objid,
             orgeh TYPE p1001-objid,
             kostl TYPE p0001-kostl,
             stell TYPE p1001-objid,
             begda TYPE p1001-begda,
             endda TYPE p1001-endda,
             kokrs TYPE p0001-kokrs,
             gsber TYPE p0001-gsber,
           END OF ty_structab.
    DATA lt_p1003    TYPE STANDARD TABLE OF p1003.
    DATA lt_structab TYPE TABLE OF ty_structab.

    DATA(lv_begda) = COND datum( WHEN iv_begda IS INITIAL
                                 THEN mv_begda
                                 ELSE iv_begda ).
    DATA(lv_endda) = COND datum( WHEN iv_endda IS INITIAL
                                 THEN mv_endda
                                 ELSE iv_endda ).
    " Только для штатной должности
    DATA(lo_plans) = get_plans_via_pa( iv_check_auth = iv_check_auth
                                       iv_begda      = lv_begda
                                       iv_endda      = lv_begda ).

    IF lo_plans IS INITIAL.
      RETURN.
    ENDIF.
    " Для случаев с переводом для правильного чтения рабочего расписания, если период будет больше действия штатки, то
    " в missing_periods всегда будет 100 процентов заполняться.
    lv_endda = COND datum( LET lv_d = lo_plans->get_endda( ) IN WHEN lv_endda <= lv_d THEN lv_endda ELSE lv_d ).
    CALL FUNCTION 'RH_APPROVAL_PERCENTAGE_GET'
      EXPORTING  ap_plvar              = cl_hrtmc_const=>plvar
                 ap_otype              = cl_hrtmc_const=>otype_position
                 ap_objid              = lo_plans->ms_object-objid
                 ap_begda              = lv_begda
                 ap_endda              = lv_endda
      TABLES     ap_table              = lt_p1003
      EXCEPTIONS t77s0_entry_not_found = 1
                 invalid_time_period   = 2
                 otype_not_valid       = 3
                 no_entry_found        = 4
                 OTHERS                = 5.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    TRY.
        DATA(ls_p1003) = lt_p1003[ 1 ].
      CATCH cx_sy_itab_line_not_found.
        RETURN.
    ENDTRY.

    CALL FUNCTION 'RH_READ_PERS_ORG_STRU'
      EXPORTING  begda                  = lv_begda
                 endda                  = lv_endda
                 pernr                  = mv_pernr
                 imported_plvar         = cl_hrtmc_const=>plvar
                 with_stru_auth         = iv_check_auth
      TABLES     stru_tab               = lt_structab
      EXCEPTIONS integration_not_active = 1
                 parameters_missing     = 2
                 OTHERS                 = 3.

    ASSIGN lt_structab[ plste = lo_plans->ms_object-objid ] TO FIELD-SYMBOL(<ls_stru>).  "#EC CI_STDSEQ
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    rv_percentage_of_emp = ( <ls_stru>-prozt / 100 ) * ( ls_p1003-przsa / 100 ).
  ENDMETHOD.


  METHOD get_persg.
    DATA:
     lt_p0001 TYPE STANDARD TABLE OF p0001.

    CLEAR: rv_persg.

    read_hr_infotype(
     EXPORTING
      iv_check_auth = iv_check_auth
      iv_infty = iv_infty
     IMPORTING
      et_pnnnn = lt_p0001 ).

    TRY.
        rv_persg = lt_p0001[ 1 ]-persg.
      CATCH cx_sy_itab_line_not_found.
        RETURN.
    ENDTRY.

  ENDMETHOD.


  METHOD get_persk.
    DATA:
     lt_p0001 TYPE STANDARD TABLE OF p0001.

    CLEAR: rv_persk.

    read_hr_infotype(
     EXPORTING
      iv_check_auth = abap_true
      iv_infty = iv_infty
     IMPORTING
      et_pnnnn = lt_p0001 ).

    TRY.
        rv_persk = lt_p0001[ persk = iv_persk ]-persk.
      CATCH cx_sy_itab_line_not_found.
        RETURN.
    ENDTRY.

  ENDMETHOD.


  METHOD get_plans_via_pa.

    DATA lt_0001 TYPE TABLE OF p0001.

    IF iv_begda IS INITIAL.
      DATA(lv_begda) = me->mv_begda.
    ELSE.
      lv_begda = iv_begda.
    ENDIF.

    IF iv_endda IS INITIAL.
      DATA(lv_endda) = me->mv_endda.
    ELSE.
      lv_endda = iv_endda.
    ENDIF.

    me->read_hr_infotype( EXPORTING iv_infty = '0001'
                                    iv_check_auth = iv_check_auth
                                    iv_begda = lv_begda
                                    iv_endda = lv_endda
                          IMPORTING et_pnnnn = lt_0001 ).

    TRY .
        DATA(lv_objid) = CONV hrobjid( lt_0001[ 1 ]-plans ).
      CATCH cx_sy_itab_line_not_found.
        RETURN.
    ENDTRY.

    ro_plans = zcl_hcm_om_obj=>get_instance( iv_otype = 'S'
                                             iv_objid = lv_objid
                                             iv_begda = lv_begda
                                             iv_endda = lv_endda ).

  ENDMETHOD.


  METHOD get_prozt.
    DATA lt_p1001 TYPE STANDARD TABLE OF p1001.

    mo_pernr->read_rh_infotype(
      EXPORTING
        iv_infty      = '1001'
        iv_subty      = iv_subty
      IMPORTING
        et_pnnnn      = lt_p1001
    ).

    TRY.
        rv_prozt = lt_p1001[ 1 ]-prozt.
        es_p1001 = lt_p1001[ 1 ].
      CATCH cx_sy_itab_line_not_found.
        CLEAR rv_prozt.
    ENDTRY.
  ENDMETHOD.


  METHOD get_pru_education.

    DATA: lt_p0022 TYPE TABLE OF p0022,
          lo_okso  TYPE REF TO cl_hrpadru_okso,
          lv_okso  TYPE p33_cokso,
          lv_input TYPE n VALUE 1.

    lo_okso = cl_hrpadru_okso=>get_instance( ).

    IF lo_okso IS BOUND.
      TRY.
          lv_okso = lo_okso->get_db_okso_code(
            EXPORTING
              iv_version = rs_educ-version
              iv_okso    = rs_educ-profession
              iv_begda   = rs_educ-begda
              iv_endda   = rs_educ-endda ).
        CATCH cx_hrpadru_okso.
          RETURN.
      ENDTRY.
    ENDIF.

    IF is_p0022 IS   INITIAL.
      me->read_hr_infotype( EXPORTING iv_infty = '0022'
                                     iv_subty = iv_subty
                           IMPORTING et_pnnnn = lt_p0022 ).

      TRY.
          DATA(ls_p0022) = lt_p0022[ 1 ].
        CATCH cx_sy_itab_line_not_found.
          RETURN.
      ENDTRY.
    ELSE.
      ls_p0022 = is_p0022.
    ENDIF.


    rs_educ-sprsl = sy-langu.
    rs_educ-faceteducation = '30'.
    rs_educ-facetskill = '34'.
    rs_educ-facetform = '33'.

    rs_educ-education = ls_p0022-emark.
    IF rs_educ-education IS INITIAL.
      rs_educ-education = ls_p0022-subty.
    ENDIF.
    rs_educ-skill = ls_p0022-slktr.
    rs_educ-form = ls_p0022-slpln.
    IF ls_p0022-insti IS INITIAL.
      CLEAR rs_educ-institute.
      CLEAR rs_educ-insti.
    ELSE.
      rs_educ-institute = ls_p0022-insti.
    ENDIF.

    IF ls_p0022-ausbi IS NOT INITIAL.
      lv_input = 0.
      IF lo_okso IS BOUND.

        TRY.
            lo_okso->get_okso_and_qualification(
               EXPORTING
                 iv_ausbi   = ls_p0022-ausbi
                 iv_version = ls_p0022-faccd
                 iv_tx122   = ls_p0022-tx122
               IMPORTING
                 ev_okso    = lv_okso
                 ev_qcode   = rs_educ-qcode ).

            rs_educ-version = ls_p0022-faccd.
            rs_educ-profession = lo_okso->get_formatted_okso(
                                              iv_version = ls_p0022-faccd
                                              iv_okso    = lv_okso
                                              ).
          CATCH cx_hrpadru_okso.
            RETURN.
        ENDTRY.
      ENDIF.
    ENDIF.

    rs_educ-documentype = ls_p0022-slabs.
    rs_educ-document = ls_p0022-ksbez.
    rs_educ-begda = ls_p0022-begda.
    rs_educ-endda = ls_p0022-endda.

    IF lo_okso IS BOUND.
      rs_educ-version = lo_okso->get_actual_version( ).
    ENDIF.

    rs_educ-molga = '33'.

    SELECT SINGLE landx FROM t005t
               WHERE spras = @rs_educ-sprsl AND
                     land1 = @ls_p0022-sland
    INTO @DATA(lv_landx).

    SELECT cname, facet, ccode FROM  t7ruokin
          WHERE molga = @rs_educ-molga          AND
                sprsl = @rs_educ-sprsl          AND
               ( ( facet = @rs_educ-faceteducation AND ccode EQ @rs_educ-education ) OR
                ( facet = @rs_educ-facetskill AND ccode EQ @rs_educ-skill ) OR
                ( facet EQ @rs_educ-facetform      AND
                 ccode EQ @rs_educ-form ) )
      INTO TABLE @DATA(lt_cname).

    TRY .
        rs_educ-nameeducation = lt_cname[ facet = rs_educ-faceteducation
                                          ccode = rs_educ-education ]-cname.
      CATCH cx_sy_itab_line_not_found.
        CLEAR  rs_educ-nameeducation.
    ENDTRY.

    TRY .
        rs_educ-nameskill = lt_cname[ facet = rs_educ-facetskill
                                          ccode = rs_educ-skill ]-cname.
      CATCH cx_sy_itab_line_not_found.
        CLEAR  rs_educ-nameskill.
    ENDTRY.

    TRY .
        rs_educ-nameform = lt_cname[ facet = rs_educ-facetform
                                          ccode = rs_educ-form ]-cname.
      CATCH cx_sy_itab_line_not_found.
        CLEAR  rs_educ-nameeducation.
    ENDTRY.

    SELECT SINGLE insti FROM t7ruschool
         WHERE molga EQ @rs_educ-molga          AND
               sprsl EQ @rs_educ-sprsl          AND
               abbrv EQ @rs_educ-institute
      INTO @rs_educ-insti.

    IF lo_okso IS BOUND.
      TRY.
          lo_okso->get_okso_text(
             EXPORTING
               iv_okso  = lv_okso
               iv_begda = rs_educ-begda
               iv_endda = rs_educ-endda
             IMPORTING
               ev_pname = rs_educ-nameprofession ).
        CATCH cx_hrpadru_okso.
          CLEAR: lv_okso.
      ENDTRY.

      TRY.
          rs_educ-versionname = lo_okso->get_okso_version_text( rs_educ-version ).
        CATCH cx_hrpadru_okso.
          CLEAR rs_educ-versionname.
      ENDTRY.

      IF rs_educ-qcode IS NOT INITIAL.
        TRY.
            lo_okso->get_qualification_text(
              EXPORTING
                iv_okso  = lv_okso
                iv_qcode = rs_educ-qcode
                iv_begda = rs_educ-begda
                iv_endda = rs_educ-endda
              IMPORTING
                ev_qname = rs_educ-qualification
                 ).
          CATCH cx_hrpadru_okso.
            CLEAR rs_educ-qualification.
        ENDTRY.
      ELSE.
        rs_educ-qualification = ls_p0022-tx122.
      ENDIF.

    ENDIF.

  ENDMETHOD.


  METHOD get_registration_address.
    CONSTANTS:
      lc_kv  TYPE text2  VALUE 'кв',
      lc_zd  TYPE text10 VALUE 'зд',
      lc_str TYPE text10 VALUE 'стр'.

    DATA:
      lt_p0006        TYPE TABLE OF p0006,
      ls_kladr        TYPE pru_kladr_screen,
      lt_p3433        TYPE TABLE OF p3433,
      lo_p0006_screen TYPE REF TO cl_hrpadru_infty_0006_screen.

    FIELD-SYMBOLS: <fs_p0006> LIKE LINE OF lt_p0006.

    me->read_hr_infotype(
      EXPORTING
        iv_infty      = '0006'
      IMPORTING
        et_pnnnn      = lt_p0006
    ).
    IF lt_p0006 IS INITIAL.
      RETURN.
    ENDIF.

    READ TABLE lt_p0006 ASSIGNING <fs_p0006> WITH KEY subty = iv_subtyorder(1).
    IF sy-subrc = 0.
    ELSE.
      READ TABLE lt_p0006 ASSIGNING <fs_p0006> WITH KEY subty = iv_subtyorder+1(1).
      IF sy-subrc = 0.
      ELSE.
        READ TABLE lt_p0006 ASSIGNING <fs_p0006> WITH KEY subty = iv_subtyorder+2(1).
        IF sy-subrc = 0.
          RETURN.
        ENDIF.
      ENDIF.
    ENDIF.

    IF <fs_p0006> IS NOT ASSIGNED.
      RETURN.
    ENDIF.

    me->read_hr_infotype(
      EXPORTING
        iv_infty      = '3433'
      IMPORTING
        et_pnnnn      = lt_p3433
    ).

    READ TABLE lt_p3433 INTO DATA(ls_p3433)
      WITH KEY begda = <fs_p0006>-begda
               endda  = <fs_p0006>-endda
               subty = <fs_p0006>-subty.

    IF sy-subrc <> 0.
      CLEAR ls_p3433.
    ENDIF.

    lo_p0006_screen = cl_hrpadru_infty_0006_screen=>get_instance( ).
    lo_p0006_screen->output_conversion(
      EXPORTING
        is_p0006  = <fs_p0006>
        is_p3433  = ls_p3433
      CHANGING
        cs_screen = ls_kladr ).

    rv_registration_address = <fs_p0006>-pstlz.

    add_no_init(
      EXPORTING
        iv_val1 = ls_kladr-regionname
        iv_val2 = ls_kladr-ksocr_region
      CHANGING
        cv_val  = rv_registration_address
    ).
    add_no_init(
      EXPORTING
        iv_val1 = ls_kladr-areaname
        iv_val2 = ls_kladr-ksocr_counc
      CHANGING
        cv_val  = rv_registration_address
    ).
    add_no_init(
      EXPORTING
        iv_val1 = ls_kladr-kname_city
        iv_val2 = ls_kladr-ksocr_city
      CHANGING
        cv_val  = rv_registration_address
    ).
    add_no_init(
      EXPORTING
        iv_val1 = ls_kladr-kname_np
        iv_val2 = ls_kladr-ksocr_np
      CHANGING
        cv_val  = rv_registration_address
    ).
    add_no_init(
      EXPORTING
        iv_val1 = ls_kladr-kname_street
        iv_val2 = ls_kladr-ksocr_street
      CHANGING
        cv_val  = rv_registration_address
    ).
    add_no_init(
      EXPORTING
        iv_val1 = ls_kladr-kname_house
        iv_val2 = ls_kladr-eststatname
      CHANGING
        cv_val  = rv_registration_address
    ).
    add_no_init(
      EXPORTING
      iv_val1 = ls_kladr-kname_bldng
      iv_val2 = lc_zd
      CHANGING
      cv_val  = rv_registration_address
    ).
    add_no_init(
      EXPORTING
      iv_val1 = ls_kladr-strucnum
      iv_val2 = lc_str
      CHANGING
      cv_val  = rv_registration_address
    ).
    add_no_init(
      EXPORTING
      iv_val1 = <fs_p0006>-posta
      iv_val2 = lc_kv
      CHANGING
      cv_val  = rv_registration_address
    ).
  ENDMETHOD.


  METHOD get_signer.
    CONSTANTS: lc_33chf TYPE merk1 VALUE '33CHF'.

    DATA: lt_p0001 TYPE STANDARD TABLE OF p0001,
          ls_pme04 TYPE pme04,
          lv_back  TYPE text10.

    me->read_hr_infotype(
      EXPORTING
        iv_infty      = '0001'
      IMPORTING
        et_pnnnn      = lt_p0001 ).

    TRY.
        ls_pme04-bukrs = lt_p0001[ 1 ]-bukrs.
      CATCH cx_sy_itab_line_not_found.
    ENDTRY.

    DATA(lv_podp_pernr) = CONV pernr_d( me->get_feature( lc_33chf ) ).

    ro_person_podp = zcl_hcm_pa_obj=>get_instance(
                         iv_pernr = lv_podp_pernr
                         iv_begda = mv_begda
                         iv_endda = mv_endda
                     ).

  ENDMETHOD.


  METHOD get_signer_new.
    TYPES: BEGIN OF ty_ztsdr,
             id    TYPE ztsdr-id,
             bukrs TYPE ztsdr-bukrs,
             werks TYPE ztsdr-werks,
             btrtl TYPE ztsdr-btrtl,
             posid TYPE ztsdr-posid,
             pernr TYPE ztsdr-pernr,
           END OF ty_ztsdr.


    DATA: lt_p0001 TYPE STANDARD TABLE OF p0001,
          ls_zzstc TYPE zzstc,
          lt_ztsdr TYPE STANDARD TABLE OF ty_ztsdr.

    CLEAR: et_pernr.

    me->read_hr_infotype( EXPORTING iv_infty      = '0001'
                          IMPORTING et_pnnnn      = lt_p0001 ).

*    (SavinovaEA 3000010761 17.12.2020
*    Берем только актуальную запись из 1ИТ

    SORT lt_p0001 BY begda DESCENDING.
*    )SavinovaEA 3000010761 17.12.2020


    TRY.
        ls_zzstc = CORRESPONDING #( lt_p0001[ 1 ] ).
      CATCH cx_sy_itab_line_not_found.
    ENDTRY.

    IF iv_progname IS NOT INITIAL.
      DATA(lt_res_tvarv) = zcl_tvarvc=>get_const_range_long( EXPORTING iv_name = zcl_hcm_values=>mc_tvarvc-feature ).

      TRY.
          ls_zzstc-zzprog_id = lt_res_tvarv[ low = CONV #( iv_progname ) ]-high.
        CATCH cx_sy_itab_line_not_found.
      ENDTRY.
    ELSE.
      ls_zzstc-zzprog_id = '001'.
    ENDIF.

*    zcl_hcm_utils=>read_feature_table( EXPORTING iv_feature  = zcl_hcm_values=>mc_feature-_zzsdr
*                                                 is_struct   = ls_zzstc
*                                       IMPORTING et_value    = et_actor ).

    zcl_hcm_utils=>read_feature_table( EXPORTING iv_feature  = zcl_hcm_values=>mc_feature-_zzsdr
                             is_struct   = ls_zzstc
                   IMPORTING et_value    = lt_ztsdr ).

    LOOP AT lt_ztsdr ASSIGNING FIELD-SYMBOL(<ls_ztsdr>).
      IF <ls_ztsdr>-werks = '0000'.
        CLEAR <ls_ztsdr>-werks.
      ENDIF.
      IF <ls_ztsdr>-btrtl = '0000'.
        CLEAR <ls_ztsdr>-btrtl.
      ENDIF.

      SELECT SINGLE posid, pernr INTO @DATA(es_actor)
        FROM ztsdr
          WHERE id = @<ls_ztsdr>-id
            AND bukrs = @<ls_ztsdr>-bukrs
            AND werks = @<ls_ztsdr>-werks
            AND btrtl = @<ls_ztsdr>-btrtl
            AND posid = @<ls_ztsdr>-posid.

      IF es_actor IS NOT INITIAL.
        APPEND es_actor TO et_actor.
      ENDIF.

    ENDLOOP.

*    LOOP AT et_actor ASSIGNING FIELD-SYMBOL(<ls_actor>).
*      IF <ls_actor>-otype = mc_actor_ruk.
*        ev_pernr = <ls_actor>-objid.
*      ENDIF.
*      APPEND <ls_actor>-objid TO et_pernr.
*    ENDLOOP.

    LOOP AT et_actor ASSIGNING FIELD-SYMBOL(<ls_actor>).
      IF <ls_actor>-otype = mc_actor_buh AND iv_buh_flag = abap_true.
        ev_pernr = <ls_actor>-objid.
      ELSEIF <ls_actor>-otype = mc_actor_ruk AND iv_buh_flag = abap_false.
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


  METHOD get_status.

    DATA: lt_p0000 TYPE TABLE OF p0000.

    IF iv_date IS INITIAL.
      me->read_hr_infotype( EXPORTING iv_infty = '0000'
                            IMPORTING et_pnnnn = lt_p0000 ).
    ELSE.
      me->read_hr_infotype( EXPORTING iv_infty = '0000'
                                      iv_begda = iv_date
                                      iv_endda = iv_date
                            IMPORTING et_pnnnn = lt_p0000 ).
    ENDIF.

    TRY.
        rv_status = lt_p0000[ 1 ]-stat2.
      CATCH cx_sy_itab_line_not_found.
        CLEAR rv_status.
    ENDTRY.

  ENDMETHOD.


  METHOD get_substitute.

    DATA lt_0001  TYPE TABLE OF p0001.
    DATA lt_0002  TYPE TABLE OF p0002.
    DATA lt_1001  TYPE TABLE OF p1001.
    DATA lv_plans TYPE p0001-plans.

    IF iv_plans IS NOT SUPPLIED.
      read_hr_infotype(
        EXPORTING
          iv_infty      = '0001'            " Инфо-тип
*          iv_subty      = '*'              " Подтип
*          iv_check_auth = 'X'              " Общий флаг
          iv_begda      = iv_date                 " Дата начала
          iv_endda      = iv_date                 " Дата окончания
*          iv_sprps      = '*'              " Считать заблокированные записи
        IMPORTING
          et_pnnnn      = lt_0001
      ).

      IF lt_0001[] IS INITIAL
        OR lt_0001[ 1 ]-plans IS INITIAL
        OR lt_0001[ 1 ]-plans = '99999999'.
        RETURN.
      ENDIF.
      lv_plans = lt_0001[ 1 ]-plans.
    ELSE.
      lv_plans = iv_plans.
    ENDIF.

    zcl_hcm_om_obj=>get_instance(
        iv_otype = 'S'
        iv_objid = lv_plans
        iv_begda = iv_date
        iv_endda = iv_date )->read_relation(
                EXPORTING iv_subty      = 'A008'
                          iv_requ_otype = cl_hrtmc_const=>otype_person
                IMPORTING et_p1001      = lt_1001 ).

    IF lt_1001[] IS INITIAL.
      RETURN.
    ENDIF.

    IF lines( lt_1001 ) <= 1.
* Основной ТН
    ELSE.
      DATA(lv_1001_p_exist) = abap_true.
    ENDIF.

    DELETE lt_1001 WHERE prozt NE 0.
    IF lv_1001_p_exist = abap_false.
      SORT lt_1001 BY begda.
    ELSE.
      SORT lt_1001 BY begda DESCENDING.
    ENDIF.

    LOOP AT lt_1001 ASSIGNING FIELD-SYMBOL(<ls_p1001>).
      ev_osn_pernr = <ls_p1001>-sobid.
      IF ev_osn_nachn IS SUPPLIED OR ev_osn_inits IS SUPPLIED.
        CALL FUNCTION 'HR_READ_INFOTYPE'
          EXPORTING
            pernr           = ev_osn_pernr
            infty           = '0002'
            begda           = iv_date
            endda           = iv_date
          TABLES
            infty_tab       = lt_0002
          EXCEPTIONS
            infty_not_found = 1
            invalid_input   = 2
            OTHERS          = 3.
        IF sy-subrc <> 0.
          CLEAR lt_0002[].
        ENDIF.
        READ TABLE lt_0002 ASSIGNING FIELD-SYMBOL(<ls_p0002>) INDEX 1.
        IF sy-subrc = 0.
          ev_osn_inits = <ls_p0002>-inits.
          ev_osn_nachn = <ls_p0002>-nachn.
        ENDIF.
      ENDIF.
      EXIT.
    ENDLOOP.

  ENDMETHOD.


  METHOD get_tarif_grade.
    DATA: ls_p0008 TYPE p0008.

    CLEAR: ev_trfgb.

    me->read_hr_infotype( EXPORTING iv_infty = '0008'
                          IMPORTING es_pnnnn = ls_p0008  ).

    ev_trfgb = ls_p0008-trfgb.
    rv_grade = ls_p0008-trfst.

  ENDMETHOD.


  METHOD get_uname.
*******************************************************************************
* Изменения (Последнее изменение сверху) *
* ----------------------------------------------------------------------------*
* №     Дата     Разработчик  Описание
* ----------------------------------------------------------------------------*
* 0001  20231120 LIVANSKIYRS  7200024442: ЛК -СУЭ Просмотр интерфейса другого сотр
* ----------------------------------------------------------------------------*
*******************************************************************************
    DATA lt_p0105 TYPE STANDARD TABLE OF p0105.
    "{ ins 0001
    IF mv_no_auth = abap_true.
      DATA(lv_check_auth) = abap_false.
    ELSE.
      lv_check_auth = abap_true.
    ENDIF.
    "} ins 0001
    read_hr_infotype(
      EXPORTING
        iv_infty      = '0105'
        iv_subty      = mc_uname
        iv_check_auth = lv_check_auth                       "ins 0001
      IMPORTING
        et_pnnnn      = lt_p0105 ).
    rv_uname = VALUE #( lt_p0105[ lines( lt_p0105 ) ]-usrid OPTIONAL ).
  ENDMETHOD.


  METHOD get_zash.
    DATA lv_dt TYPE begda.
    DATA lt_p0007  TYPE STANDARD TABLE OF p0007.
    DATA lt_p0001  TYPE STANDARD TABLE OF p0001.
    IF iv_date IS INITIAL.
      lv_dt = me->mv_begda.
    ELSE.
      lv_dt = iv_date.
    ENDIF.

    me->read_hr_infotype( EXPORTING iv_infty      = '0007'
                                    iv_check_auth = mv_no_auth
                          IMPORTING et_pnnnn      = lt_p0007 ).
    me->read_hr_infotype( EXPORTING iv_infty      = '0001'
                                    iv_check_auth = mv_no_auth
                          IMPORTING et_pnnnn      = lt_p0001 ).

    LOOP AT lt_p0001 REFERENCE INTO DATA(lr_0001)
      WHERE pernr = mv_pernr
        AND begda <= lv_dt
        AND endda >= lv_dt.
    ENDLOOP.
    LOOP AT lt_p0007 REFERENCE INTO DATA(lr_0007)
      WHERE pernr = mv_pernr
        AND begda <= lv_dt
        AND endda >= lv_dt.
    ENDLOOP.
    CHECK lr_0001 IS BOUND AND lr_0007 IS BOUND.
    SELECT SINGLE
        FROM t503
            FIELDS *
                WHERE
                    persg = @lr_0001->persg AND
                    persk = @lr_0001->persk
    INTO @DATA(ls_t503).
    CHECK ls_t503 IS NOT INITIAL.
    SELECT SINGLE
        FROM t001p
            FIELDS *
                WHERE werks = @lr_0001->werks AND
                      btrtl = @lr_0001->btrtl
    INTO @DATA(ls_t001p).
    CHECK ls_t001p IS NOT INITIAL.
    SELECT SINGLE
      FROM t508a
          FIELDS *
              WHERE
                  zeity = @ls_t503-zeity AND
                  mofid = @ls_t001p-mofid AND
                  mosid = @ls_t001p-mosid AND
                  schkz = @lr_0007->schkz
    INTO @DATA(ls_t508a).
    CHECK ls_t508a IS NOT INITIAL.
    SELECT SINGLE
        FROM t7ru80s
            FIELDS *
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

    DATA(lv_sum) = REDUCE dec9_2(  INIT sum TYPE dec9_2
                                   FOR wa IN lt_solst
                                   NEXT sum = sum + wa-solst ).

    rv_solst = lv_sum / 12.
  ENDMETHOD.


  METHOD get_zlawrf.
*Выводится мотив награждения.
*Для табельного номера P0861-PERNR по таблице T5F99A0 считываем значение TDNAME (ID текста) по условиям:
*T5F99A0-MOLGA=’33’
*T5F99A0-BEGDA≤P0861-BEPRO≤T5F99A0-ENDDA
*T5F99A0-AWADG=P0861-AWADG
*T5F99A0-AWADT=P0861-AWADT
*Получаем:
*TDNAME=конкатенация T5F99A0-MOLGA + T5F99A0-AWADG + T5F99A0-AWADT + T5F99A0-ENDDA
*
*с помощью ФМ READ_TEXT считывается стандартный текст по условиям:
*LANGUAGE=R
*ID=PY99
*OBJECT=HRPYXX99
*NAME=<полученный на предыдущем шаге ID текста - TDNAME>
    DATA: lt_text_data TYPE tline_t
          ,lv_obname    TYPE tdobname.

    SELECT SINGLE molga, awadg, awadt, endda
      FROM t5f99a0
      INTO @DATA(ls_t5f99a0)
      WHERE molga = '33'
        AND begda <= @is_p0861-bepro
        AND endda >= @is_p0861-bepro
        AND awadg  = @is_p0861-awadg
        AND awadt  = @is_p0861-awadt.

    CHECK sy-subrc = 0.

    lv_obname = |{ ls_t5f99a0-molga }{ ls_t5f99a0-awadg }{ ls_t5f99a0-awadt }{ ls_t5f99a0-endda }|.

    CALL FUNCTION 'READ_TEXT'
      EXPORTING
*       CLIENT   = SY-MANDT
        id       = 'PY99'
        language = sy-langu
        name     = lv_obname
        object   = 'HRPYXX99'
      TABLES
        lines    = lt_text_data[]
      EXCEPTIONS
        OTHERS   = 8.

    CHECK lt_text_data IS NOT INITIAL.

*    LOOP AT lt_text_data INTO DATA(ls_text_data).
*      rv_zlawrf = rv_zlawrf && ls_text_data-tdline.
*    ENDLOOP.

    rv_zlawrf = VALUE #( lt_text_data[ 2 ]-tdline OPTIONAL ).

  ENDMETHOD.


  METHOD read_hr_infotype.
    DATA:
      lr_tab   TYPE REF TO data,
      lv_begda TYPE begda,
      lv_endda TYPE endda.

    FIELD-SYMBOLS: <lt_tab> TYPE STANDARD TABLE.

    DATA(lv_no_auth) = COND flag( WHEN iv_check_auth = abap_true THEN abap_false ELSE abap_true ).

    CLEAR: et_pnnnn, es_pnnnn.

    DATA(lv_strty) = `P` && iv_infty .

    CREATE DATA lr_tab TYPE TABLE OF (lv_strty).
    ASSIGN lr_tab->* TO <lt_tab>.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    IF iv_begda IS INITIAL.
      lv_begda = mv_begda.
    ELSE.
      lv_begda = iv_begda.
    ENDIF.
    IF iv_endda IS INITIAL.
      lv_endda = mv_endda.
    ELSE.
      lv_endda = iv_endda.
    ENDIF.

    CALL FUNCTION 'HR_READ_SUBTYPE'
      EXPORTING
        pernr           = me->mv_pernr
        infty           = iv_infty
        subty           = iv_subty
        sprps           = iv_sprps
        begda           = lv_begda
        endda           = lv_endda
        no_auth_check   = lv_no_auth
        bypass_buffer   = iv_buffer
      TABLES
        infty_tab       = <lt_tab>
      EXCEPTIONS
        infty_not_found = 1
        invalid_input   = 2
        OTHERS          = 3.
    IF sy-subrc <> 0.
      CLEAR: et_pnnnn.
    ENDIF.

    et_pnnnn = <lt_tab>.

    IF es_pnnnn IS NOT REQUESTED.
      RETURN.
    ENDIF.

    TRY.
        es_pnnnn = <lt_tab>[ 1 ].
      CATCH cx_sy_itab_line_not_found.
    ENDTRY.

  ENDMETHOD.


  METHOD read_note_30it.
    DATA: lt_p0030 TYPE STANDARD TABLE OF p0030,
          lt_notes TYPE STANDARD TABLE OF text72,
          ls_key   TYPE pskey.

    read_hr_infotype( EXPORTING iv_infty = '0030'
                      IMPORTING et_pnnnn = lt_p0030 ).

    IF lt_p0030 IS NOT INITIAL.
      DATA(ls_p0030) = lt_p0030[ 1 ].
    ENDIF.

    ls_key = CORRESPONDING #( ls_p0030 ).

    CALL FUNCTION 'HR_READ_INFTY_NOTE'
      EXPORTING
        key            = ls_key
      TABLES
        text           = lt_notes
      EXCEPTIONS
        not_found      = 1
        not_authorized = 2
        OTHERS         = 3.

    IF sy-subrc =  0.
      TRY.
          ev_text1 = lt_notes[ 1 ].
        CATCH cx_sy_itab_line_not_found.
          CLEAR ev_text1 .
      ENDTRY.

      TRY.
          ev_text2 = lt_notes[ 2 ].
        CATCH cx_sy_itab_line_not_found.
          CLEAR ev_text2.
      ENDTRY.

      TRY.
          ev_text3 = lt_notes[ 3 ].
        CATCH cx_sy_itab_line_not_found.
          CLEAR ev_text3.
      ENDTRY.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
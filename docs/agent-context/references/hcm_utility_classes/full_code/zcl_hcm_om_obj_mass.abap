CLASS zcl_hcm_om_obj_mass DEFINITION
  PUBLIC
  CREATE PROTECTED.

  PUBLIC SECTION.
    TYPES:
      BEGIN OF ty_s_descr,
        objid       TYPE hrobjid,
        otype       TYPE otype,
        description TYPE string,
      END OF ty_s_descr.
    TYPES ty_t_descr TYPE SORTED TABLE OF ty_s_descr WITH UNIQUE KEY objid.
    TYPES: BEGIN OF ty_account_assignment,
             s_objid TYPE hrobjid,
             o_objid TYPE hrobjid,
             werks   TYPE werks_d,
             persa   TYPE persa,
             btrtl   TYPE btrtl_001p,
             bukrs   TYPE bukrs,
             gsber   TYPE gsber,
           END OF ty_account_assignment.
    TYPES ty_t_account_assignment TYPE STANDARD TABLE OF ty_account_assignment WITH NON-UNIQUE KEY s_objid o_objid.
    TYPES: BEGIN OF ty_attrib_org,
             s_objid TYPE hrobjid,
             o_objid TYPE hrobjid,
             attrib  TYPE hrt1222-attrib,
             low     TYPE hrt1222-low,
             high    TYPE hrt1222-high,
             zzname  TYPE ztattribut-zzname,
             zznamef TYPE ztattribut-zznamef,
           END OF ty_attrib_org.
    TYPES ty_t_attrib_org TYPE STANDARD TABLE OF ty_attrib_org WITH NON-UNIQUE KEY s_objid o_objid.
    TYPES ty_t_attrib     TYPE STANDARD TABLE OF om_attrib WITH EMPTY KEY.

    CLASS-METHODS get_instance
      IMPORTING it_objects       TYPE hrobject_t OPTIONAL
                iv_begda         TYPE begda      DEFAULT sy-datum
                iv_endda         TYPE endda      DEFAULT sy-datum
      RETURNING VALUE(ro_object) TYPE REF TO zcl_hcm_om_obj_mass.

    METHODS add_object
      IMPORTING iv_otype TYPE otype
                iv_objid TYPE hrobjid.

    METHODS constructor
      IMPORTING iv_begda   TYPE begda      DEFAULT sy-datum
                iv_endda   TYPE endda      DEFAULT sy-datum
                it_objects TYPE hrobject_t OPTIONAL.

    METHODS free.

    "! <p class="shorttext synchronized" lang="ru">BUKRS,BTRTL,WERKS по mt_root_objects с наслед. См abapdoc</p>
    "! В данном случае s_objid - это рут объект (не обязательно S, может быть и O), o_objid - ближайший объект для которого есть bukrs, werks или btrtl,
    "! при этом остальные объекты с данными могут быть еще выше, для получения более подробных данных
    "! можно вызывать zcl_amdp_om_org_hier_info напрямую (см. реализацию метода и abapdoc к классу zcl_amdp_om_org_hier_info)
    "! @parameter et_info       | Выходная таблица с данными
    METHODS get_mass_controlling_info
      EXPORTING et_info TYPE ty_t_account_assignment.

    "! <p class="shorttext synchronized" lang="ru">Читает заданные атрибуты с наследованием. См abapdoc</p>
    "! В данном случае s_objid - это рут объект (не обязательно S, может быть и O), o_objid - объект с которого был прочитан атрибут,
    "! при этом другие значения атрибутов могут быть выше в орг. структуре, для получения более подробных данных
    "! можно вызывать zcl_amdp_om_org_hier_info напрямую (см. реализацию метода и abapdoc к классу zcl_amdp_om_org_hier_info)
    "! @parameter et_attr_by_obj | <p class="shorttext synchronized" lang="ru">Результат</p>
    METHODS get_mass_attrib_w_inherit
      IMPORTING it_req_attrib  TYPE ty_t_attrib
      EXPORTING et_attr_by_obj TYPE ty_t_attrib_org.

    METHODS get_objects
      RETURNING VALUE(rt_objects) TYPE hrobject_t.

    METHODS objects_exists
      RETURNING VALUE(rv_esists) TYPE flag.

    METHODS read_descriptions
      IMPORTING iv_authority    TYPE okcode   DEFAULT 'DISP'
                iv_subty        TYPE subtyp   OPTIONAL
                iv_langu        TYPE sy-langu DEFAULT sy-langu
                iv_with_1002    TYPE flag     DEFAULT abap_true
                iv_check_auth   TYPE flag     DEFAULT abap_false
                iv_skip_1000    TYPE flag     DEFAULT abap_false
                iv_line_spl     TYPE flag     OPTIONAL
      RETURNING VALUE(rt_descr) TYPE ty_t_descr.

    METHODS read_infty
      IMPORTING iv_infty      TYPE infty
                iv_subty      TYPE subty  OPTIONAL
                iv_auth_check TYPE flag   DEFAULT abap_false
                iv_auth_code  TYPE okcode DEFAULT 'DISP'
      EXPORTING et_pnnnn      TYPE STANDARD TABLE.

    METHODS read_infty_tab
      IMPORTING iv_infty      TYPE infty
                iv_subty      TYPE subty OPTIONAL
                iv_auth_check TYPE flag  OPTIONAL
                iv_istat      TYPE istat_d
      EXPORTING et_pnnnn      TYPE STANDARD TABLE
                et_tnnnn      TYPE STANDARD TABLE.

    METHODS read_relation
      IMPORTING iv_subty      TYPE subty
                iv_requ_otype TYPE otype OPTIONAL
                iv_auth_check TYPE flag  DEFAULT abap_false
                iv_with_adata TYPE flag  DEFAULT abap_true
      EXPORTING et_p1001      TYPE p1001_t.

    METHODS read_wegid
      IMPORTING iv_wegid      TYPE gdstr-wegid
                iv_requ_otype TYPE otype         OPTIONAL
                iv_auth_check TYPE flag          DEFAULT abap_false
                iv_svect      TYPE svect         DEFAULT '1'
                iv_depth      TYPE hrrhas-tdepth OPTIONAL
      EXPORTING et_objec      TYPE objec_t
                et_struc      TYPE struc_t.

  PROTECTED SECTION.
    DATA mt_root_objects TYPE hrobject_t.
    DATA mv_begda        TYPE begda.
    DATA mv_endda        TYPE endda.

  PRIVATE SECTION.
    DATA mo_dao TYPE REF TO lif_dao.
ENDCLASS.



CLASS ZCL_HCM_OM_OBJ_MASS IMPLEMENTATION.


  METHOD add_object.
    IF NOT line_exists( mt_root_objects[ objid = iv_objid
                                         otype = iv_otype ] ).
      APPEND VALUE #( otype = iv_otype
                      objid = iv_objid
                      plvar = cl_hrtmc_const=>plvar ) TO mt_root_objects.
    ENDIF.
  ENDMETHOD.


  METHOD constructor.
    mo_dao = lcl_dao=>get_instance( ).
    mv_begda = iv_begda.
    mv_endda = iv_endda.

    mt_root_objects = it_objects.
    LOOP AT mt_root_objects ASSIGNING FIELD-SYMBOL(<ls_root>) WHERE plvar IS INITIAL.  "#EC CI_STDSEQ
      <ls_root>-plvar = cl_hrtmc_const=>plvar.
    ENDLOOP.

    SORT mt_root_objects BY otype
                            objid.
    DELETE ADJACENT DUPLICATES FROM mt_root_objects.
  ENDMETHOD.


  METHOD free.
    FREE mt_root_objects.
  ENDMETHOD.


  METHOD get_instance.
    ro_object = NEW #( iv_begda   = iv_begda
                       iv_endda   = iv_endda
                       it_objects = it_objects ).
  ENDMETHOD.


  METHOD get_mass_attrib_w_inherit.
    TRY.
        DATA(lv_plvar) = mt_root_objects[ 1 ]-plvar.
      CATCH cx_sy_itab_line_not_found.
        RETURN.
    ENDTRY.
    mo_dao->get_org_hierarchy_attrib( EXPORTING it_objid  = VALUE #( FOR ls_obj IN mt_root_objects
                                                                     ( objid = ls_obj-objid ) )
                                                it_otype  = VALUE #( FOR GROUPS lv_otype OF ls_obj IN mt_root_objects
                                                                     GROUP BY ls_obj-otype WITHOUT MEMBERS
                                                                     ( otype = lv_otype ) )
                                                it_attrib = VALUE #( FOR lv_attrib IN it_req_attrib
                                                                     ( attrib = lv_attrib ) )
                                                iv_plvar  = lv_plvar
                                                iv_datum  = sy-datum
                                      IMPORTING et_result = DATA(lt_hier) ).
    LOOP AT lt_hier REFERENCE INTO DATA(lr_item) GROUP BY ( init_obj = lr_item->init_obj attrib = lr_item->attrib ) INTO DATA(ls_group_item).
      APPEND INITIAL LINE TO et_attr_by_obj ASSIGNING FIELD-SYMBOL(<ls_attr>).
      <ls_attr>-s_objid = ls_group_item-init_obj.
      <ls_attr>-attrib  = ls_group_item-attrib.
      LOOP AT GROUP ls_group_item REFERENCE INTO DATA(lr_group_item).
        IF <ls_attr>-o_objid IS INITIAL AND lr_group_item->objid IS NOT INITIAL.
          <ls_attr>-o_objid = lr_group_item->objid.
        ENDIF.
        IF <ls_attr>-low IS INITIAL.
          <ls_attr>-low = lr_group_item->low.
        ENDIF.
        IF <ls_attr>-high IS INITIAL.
          <ls_attr>-high = lr_group_item->high.
        ENDIF.
        IF <ls_attr>-zzname IS INITIAL.
          <ls_attr>-zzname = lr_group_item->zzname.
        ENDIF.
        IF <ls_attr>-zznamef IS INITIAL.
          <ls_attr>-zznamef = lr_group_item->zznamef.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_mass_controlling_info.
    TRY.
        DATA(lv_plvar) = mt_root_objects[ 1 ]-plvar.
      CATCH cx_sy_itab_line_not_found.
        RETURN.
    ENDTRY.
    mo_dao->get_org_hierarchy_info( EXPORTING it_objid  = VALUE #( FOR ls_obj IN mt_root_objects
                                                                   ( objid = ls_obj-objid ) )
                                              it_otype  = VALUE #( FOR GROUPS lv_otype OF ls_obj IN mt_root_objects
                                                                   GROUP BY ls_obj-otype WITHOUT MEMBERS
                                                                   ( otype = lv_otype ) )
                                              iv_plvar  = lv_plvar
                                              iv_datum  = sy-datum
                                    IMPORTING et_result = DATA(lt_hier) ).
    LOOP AT lt_hier REFERENCE INTO DATA(lr_item) GROUP BY lr_item->init_obj INTO DATA(ls_group_item).
      APPEND INITIAL LINE TO et_info ASSIGNING FIELD-SYMBOL(<ls_info>).
      <ls_info>-s_objid = ls_group_item.
      LOOP AT GROUP ls_group_item REFERENCE INTO DATA(lr_group_item).
        IF <ls_info>-o_objid IS INITIAL AND lr_group_item->objid IS NOT INITIAL.
          <ls_info>-o_objid = lr_group_item->objid.
        ENDIF.
        IF <ls_info>-bukrs IS INITIAL AND lr_group_item->bukrs IS NOT INITIAL.
          <ls_info>-bukrs = lr_group_item->bukrs.
        ENDIF.
        IF <ls_info>-persa IS INITIAL AND lr_group_item->persa IS NOT INITIAL.
          <ls_info>-persa = lr_group_item->persa.
        ENDIF.
        IF <ls_info>-btrtl IS INITIAL AND lr_group_item->btrtl IS NOT INITIAL.
          <ls_info>-btrtl = lr_group_item->btrtl.
        ENDIF.
        IF <ls_info>-werks IS INITIAL AND lr_group_item->werks IS NOT INITIAL.
          <ls_info>-werks = lr_group_item->werks.
        ENDIF.
        IF <ls_info>-gsber IS INITIAL AND lr_group_item->gsber IS NOT INITIAL.
          <ls_info>-gsber = lr_group_item->gsber.
        ENDIF.
        IF     <ls_info>-o_objid IS NOT INITIAL AND <ls_info>-bukrs IS NOT INITIAL AND <ls_info>-persa IS NOT INITIAL
           AND <ls_info>-btrtl   IS NOT INITIAL AND <ls_info>-werks IS NOT INITIAL AND <ls_info>-gsber IS NOT INITIAL.
          RETURN.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.


  METHOD get_objects.
    rt_objects = mt_root_objects.
  ENDMETHOD.


  METHOD objects_exists.
    rv_esists = boolc( mt_root_objects IS NOT INITIAL ).
  ENDMETHOD.


  METHOD read_descriptions.
    " TODO: parameter IV_LINE_SPL is never used (ABAP cleaner)

    DATA lt_p1000   TYPE TABLE OF p1000.
    DATA lt_itf     TYPE TABLE OF tline.
    DATA lt_str     TYPE TABLE OF text100.

    DATA lv_descr   TYPE pstring.
    DATA lv_langu   TYPE sy-langu.

    DATA lt_p1002   TYPE TABLE OF p1002.

    DATA lt_hrt1002 TYPE STANDARD TABLE OF hrt1002
                      WITH NON-UNIQUE SORTED KEY second COMPONENTS tabnr.

    IF iv_with_1002 = abap_true.
      CALL FUNCTION 'HRIQ_READ_DESCRIPT_FOR_OBJECTS'
        EXPORTING
          language  = iv_langu
          subty     = iv_subty
          begda     = mv_endda
          endda     = mv_endda
          stru_auth = iv_check_auth
        TABLES
          objects   = mt_root_objects
          p1002     = lt_p1002
          hrt1002   = lt_hrt1002
        EXCEPTIONS
          OTHERS    = 0.
      IF sy-subrc <> 0.
      ENDIF.

      IF     lv_langu            IS NOT INITIAL
         AND lt_p1002            IS NOT INITIAL
         AND lt_p1002[ 1 ]-langu <> lv_langu.
        CLEAR lt_hrt1002.
      ENDIF.
    ENDIF.

    LOOP AT lt_p1002 ASSIGNING FIELD-SYMBOL(<ls_p1002>).
      CLEAR: lt_itf,
             lt_str,
             lv_descr.

      LOOP AT lt_hrt1002 ASSIGNING FIELD-SYMBOL(<ls_hrt1002>) "#EC CI_STDSEQ
        USING KEY second WHERE tabnr = <ls_p1002>-tabnr. "#EC CI_NESTED

        APPEND VALUE tline(
          tdformat = <ls_hrt1002>-tformat
          tdline   = <ls_hrt1002>-tline ) TO lt_itf.
      ENDLOOP.

      IF lt_itf IS NOT INITIAL.
        CALL FUNCTION 'CONVERT_ITF_TO_STREAM_TEXT'
          TABLES
            itf_text    = lt_itf
            text_stream = lt_str.
        LOOP AT lt_str ASSIGNING FIELD-SYMBOL(<ls_str>). "#EC CI_NESTED
          lv_descr = |{ lv_descr }{ <ls_str> }|.
        ENDLOOP.

        lv_descr = condense( lv_descr ).
      ENDIF.

      INSERT VALUE ty_s_descr( objid       = <ls_p1002>-objid
                               otype       = <ls_p1002>-otype
                               description = lv_descr ) INTO TABLE rt_descr.
    ENDLOOP.

    IF iv_skip_1000 = abap_false.
      CALL FUNCTION 'RH_READ_INFTY_1000'
        EXPORTING
          authority      = iv_authority
          begda          = mv_begda
          endda          = mv_endda
          with_stru_auth = iv_check_auth
        TABLES
          objects        = mt_root_objects
          i1000          = lt_p1000
        EXCEPTIONS
          OTHERS         = 0.

      LOOP AT lt_p1000 REFERENCE INTO DATA(lr_p1000) WHERE langu = iv_langu. "#EC CI_STDSEQ
        IF line_exists( rt_descr[ objid = lr_p1000->objid ] ).
          CONTINUE.
        ENDIF.

        INSERT VALUE ty_s_descr( objid       = lr_p1000->objid
                                 otype       = lr_p1000->otype
                                 description = lr_p1000->stext ) INTO TABLE rt_descr.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.


  METHOD read_infty.
    CLEAR et_pnnnn.

    IF mt_root_objects IS INITIAL.
      RETURN.
    ENDIF.

    CALL FUNCTION 'RH_READ_INFTY'
      EXPORTING  authority            = iv_auth_code  " Чтение инфотипа
                 with_stru_auth       = iv_auth_check " Структурные полномочия
                 infty                = iv_infty
                 subty                = iv_subty
                 begda                = mv_begda
                 endda                = mv_endda
      TABLES     innnn                = et_pnnnn
                 objects              = mt_root_objects
      EXCEPTIONS all_infty_with_subty = 1
                 nothing_found        = 2
                 no_objects           = 3
                 wrong_condition      = 4
                 wrong_parameters     = 5
                 OTHERS               = 6.

    IF sy-subrc <> 0.
      CLEAR et_pnnnn.
    ENDIF.
  ENDMETHOD.


  METHOD read_infty_tab.
    " TODO: parameter IV_ISTAT is never used (ABAP cleaner)

    DATA lo_pnnnn    TYPE REF TO data.
    DATA lv_tab_name TYPE text30.

    FIELD-SYMBOLS <lt_pnnnn> TYPE STANDARD TABLE.

    CLEAR: et_pnnnn,
           et_tnnnn.

    lv_tab_name = |P{ iv_infty }|.

    CREATE DATA lo_pnnnn TYPE TABLE OF (lv_tab_name).

    ASSIGN lo_pnnnn->* TO <lt_pnnnn>.
    IF <lt_pnnnn> IS NOT ASSIGNED.
      RETURN.
    ENDIF.

    read_infty( EXPORTING iv_infty      = iv_infty
                          iv_subty      = iv_subty
                          iv_auth_check = iv_auth_check
                IMPORTING et_pnnnn      = <lt_pnnnn> ).

    CALL FUNCTION 'RH_READ_INFTY_TABDATA'
      EXPORTING  infty          = iv_infty
      TABLES     innnn          = <lt_pnnnn>
                 hrtnnnn        = et_tnnnn
      EXCEPTIONS no_table_infty = 1
                 innnn_empty    = 2
                 nothing_found  = 3
                 OTHERS         = 4.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    et_pnnnn = <lt_pnnnn>.
  ENDMETHOD.


  METHOD read_relation.
    CLEAR et_p1001.

    IF mt_root_objects IS INITIAL.
      RETURN.
    ENDIF.

    CALL FUNCTION 'RH_READ_INFTY_1001'
      EXPORTING  with_stru_auth   = iv_auth_check
                 subty            = iv_subty
                 begda            = mv_begda
                 endda            = mv_endda
                 adata            = iv_with_adata
      TABLES     i1001            = et_p1001
                 objects          = mt_root_objects
      EXCEPTIONS nothing_found    = 1
                 wrong_condition  = 2
                 wrong_parameters = 3
                 OTHERS           = 4.

    IF sy-subrc <> 0.
      CLEAR et_p1001.
      RETURN.
    ENDIF.

    IF iv_requ_otype IS NOT INITIAL.
      DELETE et_p1001 WHERE sclas <> iv_requ_otype.  "#EC CI_STDSEQ
    ENDIF.
  ENDMETHOD.


  METHOD read_wegid.
    CLEAR: et_objec,
           et_struc.

    IF mt_root_objects IS INITIAL.
      RETURN.
    ENDIF.

    DATA(lt_hrroot) = VALUE hrrootob_t( FOR ls_object IN mt_root_objects
                                        ( objid = ls_object-objid
                                          otype = ls_object-otype ) ).
    mo_dao->rh_struc_get_multiple_roots( EXPORTING iv_act_wegid       = iv_wegid
                                                   iv_act_tdepth      = iv_depth
                                                   iv_act_begda       = mv_begda
                                                   iv_act_endda       = mv_endda
                                                   iv_authority_check = iv_auth_check
                                                   iv_act_svect       = iv_svect
                                         CHANGING  ct_root_objects    = lt_hrroot
                                                   ct_result_objec    = et_objec
                                                   ct_result_struc    = et_struc ).
    IF iv_requ_otype IS NOT INITIAL.
      DELETE et_objec WHERE otype <> iv_requ_otype.  "#EC CI_STDSEQ
      DELETE et_struc WHERE otype <> iv_requ_otype.  "#EC CI_STDSEQ
    ENDIF.
  ENDMETHOD.
ENDCLASS.
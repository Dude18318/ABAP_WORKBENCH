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
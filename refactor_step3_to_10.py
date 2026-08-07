import re

def process():
    file_path = "Spec and result/ZCL_APS_Z8_PREDICTED_DATES_I.txt"
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    new_methods = """
  METHOD check_active.
    rv_active = zcl_tvarvc=>active_check( 'YCHECK_4175_APS' ).
  ENDMETHOD.

  METHOD collect_qmnums_and_read_qmel.
    DATA: lt_qmnum_list TYPE lcl_dao=>tt_qmnum.
    LOOP AT it_dates INTO DATA(ls_qmnum_collect).
      DATA(lv_qmnum_collect) = CONV qmnum( ls_qmnum_collect-qmnum ).
      lv_qmnum_collect = |{ lv_qmnum_collect ALPHA = IN }|.
      APPEND lv_qmnum_collect TO lt_qmnum_list.
    ENDLOOP.
    SORT lt_qmnum_list.
    DELETE ADJACENT DUPLICATES FROM lt_qmnum_list.

    rt_qmel_dates = io_dao->read_qmel_dates( lt_qmnum_list ).
  ENDMETHOD.

  METHOD build_locked_qmnums_hash.
    LOOP AT it_bal_log_db_messages INTO DATA(ls_log_retry)
      WHERE msgid = 'IM' AND msgno = '416' AND msgty = 'E'.
      DATA(lv_locked_qmnum) = CONV qmnum( ls_log_retry-msgv1 ).
      INSERT lv_locked_qmnum INTO TABLE rt_locked_qmnums.
    ENDLOOP.
  ENDMETHOD.

  METHOD determine_retry_mode.
    rv_is_retry = abap_false.
    LOOP AT it_dates INTO DATA(ls_check_retry).
      READ TABLE it_locked_qmnums WITH TABLE KEY table_line = ls_check_retry-qmnum TRANSPORTING NO FIELDS.
      IF sy-subrc = 0.
        rv_is_retry = abap_true.
        EXIT.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD process_single_date.
    ev_successful_qmnum = space.
    ev_is_locked = abap_false.

    " Если это повторный запуск (были блокировки среди текущего пакета в прошлом),
    " обрабатываем только те заявки, которые были заблокированы.
    IF iv_is_retry = abap_true.
      READ TABLE it_locked_qmnums WITH TABLE KEY table_line = is_date-qmnum TRANSPORTING NO FIELDS.
      IF sy-subrc <> 0.
        RETURN.
      ENDIF.
    ENDIF.

    " Выводим номер в формат
    DATA(lv_qmnum) = conv qmnum( is_date-qmnum ).
    lv_qmnum = |{ lv_qmnum ALPHA = IN }|.

    " Проверка текущего значения QMEL
    READ TABLE it_qmel_dates WITH TABLE KEY qmnum = lv_qmnum ASSIGNING FIELD-SYMBOL(<ls_qmel_date>).
    IF sy-subrc = 0 AND <ls_qmel_date>-zzlatestenddate = is_date-latest_end_date(8).
      MESSAGE w000(zpm_aps) WITH |{ is_date-qmnum }| 'Данные идентичны' INTO DATA(lv_dummy1).
      io_logger->add_syst_msg( sy ).
      RETURN.
    ENDIF.

    DATA(lv_date) = CONV dats( is_date-latest_end_date(8) ).
    DATA(lt_messages) = io_dao->update_latest_end_date( iv_qmnum = lv_qmnum iv_date = lv_date ).

    " Проверка результатов
    DATA(lv_has_error) = abap_false.
    ev_is_locked = abap_false.

    LOOP AT lt_messages INTO DATA(ls_msg) WHERE msgtyp = 'E' OR msgtyp = 'A'.
      lv_has_error = abap_true.
      IF ls_msg-msgid = 'IM' AND ls_msg-msgnr = '416'.
        ev_is_locked = abap_true.
      ENDIF.
    ENDLOOP.

    IF lv_has_error = abap_false.
      " 1.4.3.1. Успех
      MESSAGE s000(zpm_aps) WITH |{ is_date-qmnum }. Данные записаны| INTO DATA(lv_dummy2).
      io_logger->add_syst_msg( sy ).
      ev_successful_qmnum = lv_qmnum.
    ELSEIF ev_is_locked = abap_true.
      " 1.4.3.4 Блокировка
      " Проверяем, писали ли мы уже лог о блокировке этого сообщения
      READ TABLE it_locked_qmnums WITH TABLE KEY table_line = is_date-qmnum TRANSPORTING NO FIELDS.
      IF sy-subrc <> 0.
        MESSAGE e416(im) WITH is_date-qmnum INTO DATA(lv_dummy3).
        io_logger->add_syst_msg( sy ).
      ENDIF.
    ELSE.
      " 1.4.3.3. Другая ошибка
      LOOP AT lt_messages INTO ls_msg WHERE msgtyp = 'E' OR msgtyp = 'A'.
        DATA(lv_err_txt) = zcl_bdc=>translate_message_to_text( ls_msg ).
        MESSAGE e000(zpm_aps) WITH |{ is_date-qmnum }. { lv_err_txt }| INTO DATA(lv_dummy4).
        io_logger->add_syst_msg( sy ).
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

  METHOD process_dates.
    ev_has_locks = abap_false.
    CLEAR et_successful_qmnum.

    LOOP AT it_dates INTO DATA(ls_date).
      DATA: lv_successful_qmnum TYPE qmnum,
            lv_is_locked TYPE abap_bool.

      process_single_date(
        EXPORTING
          is_date = ls_date
          iv_is_retry = iv_is_retry
          it_locked_qmnums = it_locked_qmnums
          it_qmel_dates = it_qmel_dates
          io_dao = io_dao
          io_logger = io_logger
        IMPORTING
          ev_successful_qmnum = lv_successful_qmnum
          ev_is_locked = lv_is_locked
      ).

      IF lv_successful_qmnum IS NOT INITIAL.
        APPEND lv_successful_qmnum TO et_successful_qmnum.
      ENDIF.
      IF lv_is_locked = abap_true.
        ev_has_locks = abap_true.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD send_pdm_notifications.
    LOOP AT it_successful_qmnum INTO DATA(lv_qmnum).
      io_dao->call_pdm_notification( iv_qmnum = lv_qmnum ).
    ENDLOOP.
  ENDMETHOD.

  METHOD finalize.
    io_logger->save_log( ).
    io_dao->do_commit( ).
    IF iv_has_locks = abap_true.
*      RAISE EXCEPTION TYPE zcx_proxy_fault.
    ENDIF.
  ENDMETHOD.
"""

    content = content.replace("CLASS zcl_aps_z8_predicted_dates_i IMPLEMENTATION.", "CLASS zcl_aps_z8_predicted_dates_i IMPLEMENTATION.\n" + new_methods)

    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
    print("Success: Added new method implementations.")

process()

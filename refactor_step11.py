import re

def process():
    file_path = "Spec and result/ZCL_APS_Z8_PREDICTED_DATES_I.txt"
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    new_aps_z8 = """  METHOD zpmii_aps_z8_predicted_dates_i~aps_z8_predicted_dates_in.
    " 1. Читаем TVARV
    IF check_active( ) = abap_false.
      RETURN.
    ENDIF.

    DATA(lt_dates) = input-aps_z8_predicted_dates-z8predictions-z8predicted_dates.

    " 2. Инициализация Логгера и DAO
    DATA(lo_logger) = NEW zcl_logger(
      i_log_name    = 'ZPM_APS'
      i_sublog_name = 'IN_Z8_PRED_DAT' ).

    DATA(lo_dao) = NEW lcl_dao( ).

    DATA: lt_successful_qmnum TYPE lcl_dao=>tt_qmnum.
    DATA: lv_has_locks        TYPE abap_bool VALUE abap_false.

    " Читаем историю логов за сегодня и вчера для проверки прошлых блокировок
    DATA(lv_date_from) = CONV dats( sy-datum - 1 ).
    DATA(lt_bal_log_db_messages) = lo_dao->read_bal_log_from_db(
                                     iv_subobject = 'IN_Z8_PRED_DAT'
                                     iv_object    = 'ZPM_APS'
                                     iv_begda     = lv_date_from ).

    DATA(lt_qmel_dates) = collect_qmnums_and_read_qmel(
                            it_dates = lt_dates
                            io_dao   = lo_dao ).

    DATA(lt_locked_qmnums) = build_locked_qmnums_hash( it_bal_log_db_messages = lt_bal_log_db_messages ).

    DATA(lv_is_retry) = determine_retry_mode(
                          it_dates         = lt_dates
                          it_locked_qmnums = lt_locked_qmnums ).

    process_dates(
      EXPORTING
        it_dates            = lt_dates
        iv_is_retry         = lv_is_retry
        it_locked_qmnums    = lt_locked_qmnums
        it_qmel_dates       = lt_qmel_dates
        io_dao              = lo_dao
        io_logger           = lo_logger
      IMPORTING
        et_successful_qmnum = lt_successful_qmnum
        ev_has_locks        = lv_has_locks
    ).

    send_pdm_notifications(
      it_successful_qmnum = lt_successful_qmnum
      io_dao              = lo_dao
    ).

    finalize(
      io_logger    = lo_logger
      io_dao       = lo_dao
      iv_has_locks = lv_has_locks
    ).

  ENDMETHOD."""

    # Using regex to replace the content of zpmii_aps_z8_predicted_dates_i~aps_z8_predicted_dates_in
    # We find METHOD zpmii_aps_z8_predicted_dates_i~aps_z8_predicted_dates_in. and ENDMETHOD.

    # We can just extract the method block using regex or basic string search.
    start_str = "  METHOD zpmii_aps_z8_predicted_dates_i~aps_z8_predicted_dates_in."

    # There's only one ENDMETHOD. before the newly inserted ones, or we can just find the first ENDMETHOD. after start_str

    start_idx = content.find(start_str)

    if start_idx != -1:
        end_idx = content.find("  ENDMETHOD.", start_idx) + len("  ENDMETHOD.")

        content = content[:start_idx] + new_aps_z8 + content[end_idx:]

        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)
        print("Success: Refactored aps_z8_predicted_dates_in.")
    else:
        print("Error: Could not find method start.")

process()

import re

def process():
    file_path = "Spec and result/ZCL_APS_Z8_PREDICTED_DATES_I.txt"
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    private_section_replacement = """  PRIVATE SECTION.
    TYPES: tt_locked_qmnums TYPE HASHED TABLE OF qmnum WITH UNIQUE KEY table_line.
    METHODS check_active RETURNING VALUE(rv_active) TYPE abap_bool.
    METHODS collect_qmnums_and_read_qmel IMPORTING it_dates TYPE ZPMAPS_Z8_PREDICTED_DATES__TAB io_dao TYPE REF TO lcl_dao RETURNING VALUE(rt_qmel_dates) TYPE lcl_dao=>tt_qmel_date.
    METHODS build_locked_qmnums_hash IMPORTING it_bal_log_db_messages TYPE lcl_dao=>tt_bal_msg_sorted RETURNING VALUE(rt_locked_qmnums) TYPE tt_locked_qmnums.
    METHODS determine_retry_mode IMPORTING it_dates TYPE ZPMAPS_Z8_PREDICTED_DATES__TAB it_locked_qmnums TYPE tt_locked_qmnums RETURNING VALUE(rv_is_retry) TYPE abap_bool.
    METHODS process_single_date IMPORTING is_date TYPE ZPMAPS_Z8_PREDICTED_DATES_Z8P1 iv_is_retry TYPE abap_bool it_locked_qmnums TYPE tt_locked_qmnums it_qmel_dates TYPE lcl_dao=>tt_qmel_date io_dao TYPE REF TO lcl_dao io_logger TYPE REF TO zcl_logger EXPORTING ev_successful_qmnum TYPE qmnum ev_is_locked TYPE abap_bool.
    METHODS process_dates IMPORTING it_dates TYPE ZPMAPS_Z8_PREDICTED_DATES__TAB iv_is_retry TYPE abap_bool it_locked_qmnums TYPE tt_locked_qmnums it_qmel_dates TYPE lcl_dao=>tt_qmel_date io_dao TYPE REF TO lcl_dao io_logger TYPE REF TO zcl_logger EXPORTING et_successful_qmnum TYPE lcl_dao=>tt_qmnum ev_has_locks TYPE abap_bool.
    METHODS send_pdm_notifications IMPORTING it_successful_qmnum TYPE lcl_dao=>tt_qmnum io_dao TYPE REF TO lcl_dao.
    METHODS finalize IMPORTING io_logger TYPE REF TO zcl_logger io_dao TYPE REF TO lcl_dao iv_has_locks TYPE abap_bool."""

    content = content.replace("  PRIVATE SECTION.", private_section_replacement)

    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
    print("Success: Updated PRIVATE SECTION.")

process()

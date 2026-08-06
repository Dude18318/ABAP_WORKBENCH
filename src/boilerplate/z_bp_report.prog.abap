*&---------------------------------------------------------------------*
*& Report Z_BP_REPORT
*&---------------------------------------------------------------------*
*& Архитектурный шаблон (boilerplate) отчёта ABAP 7.50
*& Паттерн: MVC с интерфейсным DAO и mock-тестированием
*& ALV: CL_GUI_ALV_GRID в CL_GUI_CUSTOM_CONTAINER
*&---------------------------------------------------------------------*
REPORT z_bp_report.

* Глобальные данные и типы
INCLUDE z_bp_report_top.

* Экраны выбора (Selection Screen)
INCLUDE z_bp_report_s01.

* Определения локальных классов и интерфейсов
INCLUDE z_bp_report_cd01.

* Реализация локальных классов
INCLUDE z_bp_report_ci01.

* Блоки событий (INITIALIZATION, START-OF-SELECTION и др.)
INCLUDE z_bp_report_evt.

* Unit-тесты (ABAP Unit)
INCLUDE z_bp_report_tst.

* --- Экранные модули (PBO / PAI) ---

* Экран 0100 — основной ALV-экран
INCLUDE z_bp_report_status_0100o01.
INCLUDE z_bp_report_user_commani01.

* Экран 0200 — диалоговый popup (пример)
INCLUDE z_bp_report_status_0200o01.
INCLUDE z_bp_report_user_commani02.

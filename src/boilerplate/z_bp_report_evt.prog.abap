*&---------------------------------------------------------------------*
*&  Include           Z_BP_REPORT_EVT
*&---------------------------------------------------------------------*
*& Блоки событий отчёта.
*& Вся логика делегируется в lcl_app (Singleton).
*& Здесь — только «проводка» вызовов.
*&---------------------------------------------------------------------*

INITIALIZATION.
  lcl_app=>get_instance( )->initialize( ).

AT SELECTION-SCREEN OUTPUT.
  lcl_app=>get_instance( )->adjust_selection_screen( ).

AT SELECTION-SCREEN.
  lcl_app=>get_instance( )->analyze_selection_screen( ).

START-OF-SELECTION.
  lcl_app=>get_instance( )->run( ).

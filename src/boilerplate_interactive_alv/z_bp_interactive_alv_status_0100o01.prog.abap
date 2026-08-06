*&---------------------------------------------------------------------*
*& Include Z_BP_INTERACTIVE_ALV_STATUS_0100O01
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  SET PF-STATUS 'MAIN100'.
  SET TITLEBAR 'T100'.
  lcl_app=>get_instance( )->pbo_0100( ).
ENDMODULE.

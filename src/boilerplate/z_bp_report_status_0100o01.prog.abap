*----------------------------------------------------------------------*
***INCLUDE Z_BP_REPORT_STATUS_0100O01.
*----------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*----------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  SET PF-STATUS 'PF_STATUS_MAIN'.
  SET TITLEBAR '0100'.
  lcl_app=>get_instance( )->pbo_0100( ).
ENDMODULE.

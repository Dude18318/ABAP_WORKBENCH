*----------------------------------------------------------------------*
***INCLUDE Z_BP_REPORT_USER_COMMANI01.
*----------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.
  CASE sy-ucomm.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      lcl_app=>get_instance( )->cleanup( ).
      LEAVE TO SCREEN 0.
    WHEN OTHERS.
      lcl_app=>get_instance( )->pai_0100( ).
  ENDCASE.
ENDMODULE.

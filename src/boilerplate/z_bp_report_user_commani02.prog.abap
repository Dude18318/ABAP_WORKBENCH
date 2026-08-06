*----------------------------------------------------------------------*
***INCLUDE Z_BP_REPORT_USER_COMMANI02.
*----------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*----------------------------------------------------------------------*
MODULE user_command_0200 INPUT.
  CASE sy-ucomm.
    WHEN 'BACK' OR 'CANCEL' OR 'EXIT'.
      LEAVE TO SCREEN 0.
    WHEN 'OK'.
      LEAVE TO SCREEN 0.
  ENDCASE.
ENDMODULE.

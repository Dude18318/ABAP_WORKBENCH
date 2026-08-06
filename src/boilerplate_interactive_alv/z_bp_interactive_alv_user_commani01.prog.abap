*&---------------------------------------------------------------------*
*& Include Z_BP_INTERACTIVE_ALV_USER_COMMANI01
*&---------------------------------------------------------------------*
MODULE user_command_0100 INPUT.
  CASE sy-ucomm.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      LEAVE TO SCREEN 0.
    WHEN OTHERS.
      lcl_app=>get_instance( )->pai_0100( ).
  ENDCASE.
ENDMODULE.

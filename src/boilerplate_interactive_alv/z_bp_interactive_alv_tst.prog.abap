*&---------------------------------------------------------------------*
*& Include Z_BP_INTERACTIVE_ALV_TST
*&---------------------------------------------------------------------*
CLASS lcl_test_app DEFINITION FINAL FOR TESTING DURATION SHORT RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS smoke_test FOR TESTING.
ENDCLASS.

CLASS lcl_test_app IMPLEMENTATION.
  METHOD smoke_test.
    cl_abap_unit_assert=>assert_true( act = abap_true ).
  ENDMETHOD.
ENDCLASS.

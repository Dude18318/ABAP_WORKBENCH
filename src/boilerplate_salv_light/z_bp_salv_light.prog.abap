*&---------------------------------------------------------------------*
*& Report Z_BP_SALV_LIGHT
*&---------------------------------------------------------------------*
*& Облегченный SALV boilerplate для read-only отчётов ABAP 7.50
*& Основа: selection-screen + lcl_app + CL_SALV_TABLE
*&---------------------------------------------------------------------*
REPORT z_bp_salv_light.

INCLUDE z_bp_salv_light_top.
INCLUDE z_bp_salv_light_s01.
INCLUDE z_bp_salv_light_cd01.
INCLUDE z_bp_salv_light_ci01.
INCLUDE z_bp_salv_light_evt.

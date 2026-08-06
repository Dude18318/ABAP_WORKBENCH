*&---------------------------------------------------------------------*
*& Report Z_TEST_LINTER_DEMO
*& Комплексный тестовый файл для проверки правил SIBUR ABAP Linter
*&---------------------------------------------------------------------*
REPORT z_test_linter_demo.

CLASS lcl_demo_test DEFINITION.
  PUBLIC SECTION.
    " ❌ Нарушение 1: Имя метода превышает 30 символов (34 символа)
    METHODS execute_very_long_method_name_test_demo.
ENDCLASS.

CLASS lcl_demo_test IMPLEMENTATION.
  METHOD execute_very_long_method_name_test_demo.
    DATA: lt_vbak TYPE TABLE OF vbak,
          lt_vbap TYPE TABLE OF vbap,
          ls_vbak TYPE vbak,
          lt_lines TYPE TABLE OF tline.

    " ⚠️ Нарушение 2: Использование SELECT *
    " ⚠️ Нарушение 3: Использование INTO CORRESPONDING FIELDS OF TABLE
    SELECT * 
      FROM vbak 
      INTO CORRESPONDING FIELDS OF TABLE lt_vbak 
      UP TO 100 ROWS.

    " ⚠️ Нарушение 4: LOOP AT ... INTO wa вместо ASSIGNING <fs>
    LOOP AT lt_vbak INTO ls_vbak.
      
      " ❌ Нарушение 5: SELECT SINGLE внутри LOOP (Критическая ошибка)
      SELECT SINGLE netwr 
        FROM vbak 
        INTO @DATA(lv_netwr) 
        WHERE vbeln = @ls_vbak-vbeln.
      
      " ❌ Нарушение 6: Вызов READ_TEXT в цикле вместо ZCL_READ_MULTIPLE_TEXTS
      CALL FUNCTION 'READ_TEXT'
        EXPORTING
          id                      = '0001'
          language                = sy-langu
          name                    = CONV tdobname( ls_vbak-vbeln )
          object                  = 'VBBK'
        TABLES
          lines                   = lt_lines
        EXCEPTIONS
          OTHERS                  = 1.

      " ⚠️ Нарушение 7: Вызов STATUS_TEXT_EDIT в цикле
      CALL FUNCTION 'STATUS_TEXT_EDIT'
        EXPORTING
          objnr                   = CONV j_objnr( ls_vbak-vbeln )
          only_active             = 'X'
          spras                   = sy-langu.

      " ⚠️ Нарушение 8: Удаление строк по одной через DELETE ... WHERE в цикле
      DELETE lt_vbap WHERE vbeln = ls_vbak-vbeln.

      " ⚠️ Нарушение 9: COMMIT WORK на каждую итерацию в цикле
      COMMIT WORK.

    ENDLOOP.

    " ❌ Нарушение 10: FOR ALL ENTRIES без предварительной проверки IF lt_vbak IS NOT INITIAL
    " ❌ Нарушение 11: Использование условия OR в запросе FOR ALL ENTRIES
    SELECT vbeln, posnr, matnr 
      FROM vbap 
      INTO TABLE @lt_vbap 
      FOR ALL ENTRIES IN @lt_vbak 
      WHERE vbeln = @lt_vbak-vbeln OR posnr = '000010'.

    " ⚠️ Нарушение 12: READ TABLE ... BINARY SEARCH без предварительного SORT
    READ TABLE lt_vbap INTO DATA(ls_vbap) WITH KEY vbeln = '0000000001' BINARY SEARCH.

  ENDMETHOD.
ENDCLASS.

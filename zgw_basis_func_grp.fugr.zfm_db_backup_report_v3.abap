FUNCTION ZFM_DB_BACKUP_REPORT_V3 .
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(DATE) TYPE  SY-DATUM
*"     VALUE(TODAY) TYPE  CHAR1 OPTIONAL
*"     VALUE(WEEKLY) TYPE  CHAR1 OPTIONAL
*"     VALUE(MONTHLY) TYPE  CHAR1 OPTIONAL
*"  EXPORTING
*"     VALUE(RESULT_TAB) TYPE  ZDB_FM_STRUC_TT
*"  EXCEPTIONS
*"      NO_ENTRIES_FOUND
*"--------------------------------------------------------------------
  DATA: lt_tab           TYPE STANDARD TABLE OF zdb_table,  "Internal Table for ZDB_TABLE.
        ls_tab           TYPE zdb_table,
        l_dext TYPE string,
        dat TYPE i,
        lv_start TYPE dats,
        lv_end   TYPE dats,
        filenam TYPE string,
        ls_itab TYPE zdb_fm_struc.

*Populating Header text of the file

  IF today = 'X'.
    IF date LE sy-datum.

      SELECT *  FROM zdb_table INTO TABLE lt_tab
                              WHERE zdate = date
                              ORDER BY ztime DESCENDING.
      IF sy-subrc NE 0.
        RAISE no_entries_found.
        EXIT.
      ENDIF.
      IF lt_tab IS NOT INITIAL.
        LOOP AT lt_tab INTO ls_tab.
          CLEAR ls_itab.
          MOVE-CORRESPONDING ls_tab TO ls_itab.
          APPEND ls_itab TO result_tab.
        ENDLOOP.
      ENDIF.
    ELSE.
      RAISE no_entries_found.
    ENDIF.

  ELSEIF weekly = 'X'.
    lv_end = date.

    dat = date+6(2).
    dat = dat - 7.
    IF dat LE 0.
      date+4(2) = date+4(2) - 1.
      IF date+4(2) MOD 2 EQ 0.
        IF date EQ 00.
          dat = dat + 31.
        ELSE.
          dat = dat + 30.
        ENDIF.
      ELSEIF date+4(2) = 2.
        IF date+0(4) MOD 4 EQ 0.
          dat = dat + 29.
        ELSE.
          dat = dat + 28.
        ENDIF.
      ELSE.
        dat = dat + 31.
      ENDIF.
      IF date+4(2) = 00.
        date+0(4) = date+0(4) - 1.
        date+4(2) = 12.
      ENDIF.
    ENDIF.
    date+6(2) = dat.

    lv_start   = date.

    SELECT * FROM zdb_table
       INTO TABLE lt_tab
       WHERE zdate GE lv_start
       AND   zdate LE lv_end
       ORDER BY zdate ztime DESCENDING.
    " perform sub.

    IF lt_tab IS NOT INITIAL.
      LOOP AT lt_tab INTO ls_tab.
        CLEAR ls_itab.
        MOVE-CORRESPONDING ls_tab TO ls_itab.
        APPEND ls_itab TO result_tab.
      ENDLOOP.
    ENDIF.
  ELSEIF monthly = 'X'.

    lv_end = date.

    date+4(2) = date+4(2) - 1.
    IF date+4(2) = 00.
      date+0(4) = date+0(4) - 1.
      date+4(2) = 12.
    ENDIF.

    lv_start   = date.

    SELECT * FROM zdb_table
       INTO TABLE lt_tab
       WHERE zdate GE lv_start
       AND   zdate LE lv_end
       ORDER BY zdate ztime DESCENDING.

    IF lt_tab IS NOT INITIAL.

      LOOP AT lt_tab INTO ls_tab.
        CLEAR ls_itab.
        MOVE-CORRESPONDING ls_tab TO ls_itab.
        APPEND ls_itab TO result_tab.
      ENDLOOP.
    ENDIF.
  ENDIF.

  IF result_tab[] IS INITIAL.
    RAISE no_entries_found.
  ENDIF.
ENDFUNCTION.

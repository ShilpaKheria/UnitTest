FUNCTION ZDUMP_OVERVIEW.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(FRMDATESTMP) TYPE  TIMESTAMP
*"     VALUE(TODATESTMP) TYPE  TIMESTAMP
*"  EXPORTING
*"     VALUE(GS_TITLE) TYPE  STRING
*"     VALUE(GS_RETURN) TYPE  BAPIRET2
*"  TABLES
*"      GT_FINAL STRUCTURE  ZDUMPOVERVIEW
*"----------------------------------------------------------------------
*  The FM pulls ABAP dump name from table SNAP and gets the category name from tables
*  SNAPTID and DD07T in-between the given timestamp passed in the format YYYYMMDDHHMMSS.

  DATA: e_line TYPE c LENGTH 200,
       d_count(7) TYPE c,
       lw_erid TYPE c,
       frm_date TYPE sy-datum,
       frm_time TYPE sy-timlo,
       to_date TYPE sy-datum,
       to_time TYPE sy-timlo,
       pointer TYPE i,
       struc_length TYPE i.

*  Structure to get required values from table SNAP
  TYPES: BEGIN OF gty_snap,
          datum TYPE sydatum,           " date
          uzeit TYPE syuzeit,           " time
          flist TYPE sychar200,         " dump name program name..
         END OF gty_snap.

*Structure to split and get the dump error alone
  DATA: BEGIN OF struc,
          id(2) TYPE c,                 " ID
          len(3) TYPE c,                " length
          text(50) TYPE c,              " name
          END OF struc.

*Final table structure
  TYPES: BEGIN OF gty_final,
          category TYPE char50,         " dump category
          dump     TYPE char30,         " dump name
          count    TYPE char200,        " no. of occurence in the given time range
         END OF gty_final.

*Internal table declarations
  DATA: gt_snap TYPE STANDARD TABLE OF gty_snap,        " to get dump details
        gs_snap TYPE gty_snap,
        gt_error TYPE STANDARD TABLE OF zdumpoverview,  " to get dump name
        gs_error TYPE zdumpoverview,
*      gt_final TYPE STANDARD TABLE OF zdumpoverview,   " final table
        gs_final TYPE zdumpoverview.

  DESCRIBE FIELD struc LENGTH struc_length IN CHARACTER MODE.

*Check if the from date is less than the to date and throw error if not.

  IF frmdatestmp GT todatestmp.
    gs_return-type = 'E'.
    gs_return-message = text-003.
    EXIT.
  ENDIF.

*Converting from Time Stamp

  CALL FUNCTION 'G_BIW_CONVERT_FROM_TIMESTAMP'
    EXPORTING
      i_timestamp       = frmdatestmp
*     I_TZONE           = SY-ZONLO
    IMPORTING
      e_datlo           = frm_date
      e_timlo           = frm_time
    EXCEPTIONS
      invalid_timestamp = 1
      OTHERS            = 2.
  IF sy-subrc <> 0.
    gs_return-type = 'E'.
    gs_return-message = text-002.
    EXIT.
  ENDIF.

*Converting to time stamp

  CALL FUNCTION 'G_BIW_CONVERT_FROM_TIMESTAMP'
    EXPORTING
      i_timestamp       = todatestmp
*     I_TZONE           = SY-ZONLO
    IMPORTING
      e_datlo           = to_date
      e_timlo           = to_time
    EXCEPTIONS
      invalid_timestamp = 1
      OTHERS            = 2.
  IF sy-subrc <> 0.
    gs_return-type = 'E'.
    gs_return-message = text-002.
    EXIT.
  ENDIF.

IF SY-SUBRC EQ 0.
CONCATENATE 'Date From 'frm_date frm_time ' TO ' to_date to_time INTO GS_TITLE
            SEPARATED BY ` `.
ENDIF.

*Get error details from snap

  SELECT datum uzeit flist FROM snap INTO TABLE gt_snap
             WHERE seqno = '000'
             AND   datum GE frm_date
             AND   datum LE to_date
             AND   uzeit GE frm_time
             AND   uzeit LE to_time
             ORDER BY datum DESCENDING uzeit DESCENDING ahost uname mandt modno.

  IF sy-subrc NE 0.

    gs_return-type = 'E'.
    gs_return-message = text-001.
    EXIT.
  ENDIF.

  SORT gt_snap BY datum.
  CLEAR: d_count,gs_final.

*Get the error name by splitting flist field.

  LOOP AT gt_snap INTO gs_snap.

    e_line(200) = gs_snap-flist.
    struc  = e_line+pointer(struc_length).

    IF ( struc-len CO '0123456789' ) AND ( struc-len <> '000' ) AND
       ( struc-len < '050' ).
         MOVE struc-text(struc-len) TO gs_error-dump.
         APPEND gs_error TO gt_error.
         SORT gt_error BY dump ASCENDING.
    ENDIF.
  ENDLOOP.

*Count the number of occurence of the dump and fill the final table
  LOOP AT gt_error INTO gs_error.

    d_count = d_count + 1.
    AT END OF dump.
      CLEAR gs_final-count.
      gs_final-count = d_count.
      gs_final-dump  = gs_error-dump.
*Get category ID for the dump
      SELECT SINGLE category FROM snaptid INTO lw_erid
                    WHERE errid = gs_final-dump.             " Error ID
        IF SY-SUBRC NE 0.
          gs_return-type = 'E'.
          gs_return-message = text-004.
          EXIT.
        ENDIF.
*Get the category name for the ID
      SELECT SINGLE ddtext FROM dd07t INTO gs_final-category
                    WHERE domname EQ 'S380CATEGORY' AND       " Domain
                          ddlanguage EQ 'EN' AND              " Language
                          as4local EQ 'A' AND                 " Activation Status
                          domvalue_l EQ lw_erid.              " Error ID
        IF SY-SUBRC NE 0.
          gs_return-type = 'E'.
          gs_return-message = text-004.
          EXIT.
        ENDIF.

      APPEND gs_final TO gt_final.                            " Filling Final table
      CLEAR d_count.
    ENDAT.
  ENDLOOP.

ENDFUNCTION.

*&---------------------------------------------------------------------*
*&  Include           ZDB_BACKUP_DATA
*&---------------------------------------------------------------------*

LOOP AT i_sdbah INTO wa_sdbah.


*Converting the RC Value as status text.
  IF wa_sdbah-rc = '0000'.
    wt_final-status = 'Finished'.
  ELSEIF wa_sdbah-rc = '0001'.
    wt_final-status ='Warning'.
  ELSEIF wa_sdbah-rc = '0002'.
    wt_final-status = 'General Error'.
  ELSE.
    wt_final-status = 'Detailed Error'.
  ENDIF.

*Calculating the Duration.

  t1 = wa_sdbah-beg.
  t2 = wa_sdbah-ende.

  CALL FUNCTION 'CCU_TIMESTAMP_DIFFERENCE'
    EXPORTING
      timestamp1 = t2
      timestamp2 = t1
    IMPORTING
      difference = duration.



**Filtering Function with respect to Back_up details.
*  CASE wa_sdbah-funct(1).
*    WHEN 'a'.
*      functpart1 =  'all,'.
*    WHEN 'p'.
*      functpart1 =  'part,'.
*    WHEN 'f'.
*      functpart1 =  'full,'.
*    WHEN 'i'.
*      functpart1 =  'incr,'.
*    WHEN 'A'.
*      functpart1 =  'ALL,'.
*    WHEN 'P'.
*      functpart1 =  'PART,'.
*    WHEN 'F'.
*      functpart1 =  'FULL,'.
*    WHEN 'I'.
*      functpart1 =  'INCR,'.
*  ENDCASE.
*  CASE wa_sdbah-funct+1(1).
*    WHEN 'f'.
*      functpart2 = 'offline,'.
*    WHEN 'n'.
*      functpart2 = 'online,'.
*    WHEN 'F'.                     "extended for RFC MS
*      functpart2 = 'OFFLINE,'.
*    WHEN 'N'.
*      functpart2 = 'ONLINE,'.
*  ENDCASE.
*  CASE wa_sdbah-funct+2(1).
*    WHEN 't'.
*      functpart3 = 'tape'.
*    WHEN 'p'.
*      functpart3 = 'pipe'.
*    WHEN 'd'.
*      functpart3 = 'disk'.
*    WHEN 'f'.
*      functpart3 = 'util'.
*    WHEN 'r'.
*      functpart3 = 'rman'.
*    WHEN 's'.
*      functpart3 = 'stage'.
*    WHEN 'T'.                      "extended for RFC MS
*      functpart3 = 'TAPE'.
*    WHEN 'P'.
*      functpart3 = 'PIPE'.
*    WHEN 'D'.
*      functpart3 = 'DISK'.
*    WHEN 'F'.
*      functpart3 = 'UTIL'.
*    WHEN 'R'.
*      functpart3 = 'RMAN'.
*    WHEN 'S'.
*      functpart3 = 'STAGE'.
*  ENDCASE.
*  CONCATENATE functpart1 functpart2 functpart3 INTO wa_sdbah-funct SEPARATED BY space.

*  condense wa_sdbah-funct no-gaps.




*Call function to read the backup log file.

  CALL FUNCTION 'FILL_OSPROT_TABLE_BRBACKUP'
   EXPORTING
     actid                = wa_sdbah-actid
     function             = wa_sdbah-funct
   TABLES
     prottab              = it_tab
* EXCEPTIONS
*   FILE_NOT_FOUND       = 1
*   OTHERS               = 2
           .

  SEARCH it_tab FOR 'BR0061I'.

  IF sy-subrc = 0.

    LOOP AT it_tab INTO wa_tab.

      IF wa_tab-line CS 'BR0061I'.
        lv_line = wa_tab.
        CLEAR wa_tab.
        EXIT.
      ENDIF.

    ENDLOOP.

    IF lv_line IS NOT INITIAL.
      lv_val1 = strlen( lv_line ) - 14.
      lv_bksize = lv_line+lv_val1(14).
*    wt_final-mb = lv_bksize.
*    APPEND wt_final TO i_final.
*    CLEAR wt_final.
*    CLEAR lv_line.
*    CLEAR lv_bksize.
    ENDIF.

    wt_final-zvdate = wa_sdbah-beg+0(8).
    wt_final-zvtime = wa_sdbah-beg+8(6).
    wt_final-duration = duration.
    wt_final-function = wa_sdbah-funct.
    wt_final-mb = lv_bksize.
    APPEND wt_final TO i_final.
    CLEAR wt_final.
    CLEAR lv_line.
    CLEAR lv_bksize.
  ELSE.
    wt_final-zvdate = wa_sdbah-beg+0(8).
    wt_final-zvtime = wa_sdbah-beg+8(6).
    wt_final-duration = duration.
    wt_final-function = wa_sdbah-funct.
    wt_final-mb = 'Error in Backup'.
    APPEND wt_final TO i_final.
    CLEAR wt_final.
  ENDIF.

  CLEAR it_tab.
  CLEAR wa_sdbah.
ENDLOOP.


LOOP AT i_final INTO wt_final.
  IF wt_final-zvdate = lv_date.
    count = 1.
  ENDIF.
ENDLOOP.

IF count = 0.
  READ TABLE lt_final INTO wa_final INDEX 1.
  IF sy-subrc = 0.
    wa_db_bk-zdtime = wa_final-ztime.
    wa_db_bk-zddate =  wa_final-zdate.
    wa_db_bk-zsize = wa_final-zsize.
    wa_db_bk-used_space = wa_final-used_space.
    wa_db_bk-used_percentage = wa_final-used_percentage.
    wa_db_bk-sysid = wa_final-sysid.
    wa_db_bk-file_utilization = wa_final-file_utilization.
    IF wa_db_bk-start_time IS INITIAL.
      CLEAR wa_db_bk-start_time.
    ENDIF.
    wa_db_bk-message = 'No Backup for today'.
    wa_db_bk-start_date = ''.
    wa_db_bk-start_time = '        '.
    wa_db_bk-duration = ''.
    wa_db_bk-status = ''.
    wa_db_bk-function = ''.
    wa_db_bk-mb = ''.
    APPEND wa_db_bk TO it_db_bk.
    CLEAR  wa_db_bk.
  ENDIF.

ELSE.
  READ TABLE lt_final INTO wa_final INDEX 1.
  IF sy-subrc = 0.
    LOOP AT i_final INTO wt_final WHERE zvdate = lv_date.
      IF sy-subrc = 0.
        wa_db_bk-zdtime = wa_final-ztime.
        wa_db_bk-zddate =  wa_final-zdate.
        wa_db_bk-zsize = wa_final-zsize.
        wa_db_bk-used_space = wa_final-used_space.
        wa_db_bk-used_percentage = wa_final-used_percentage.
        wa_db_bk-sysid = wa_final-sysid.
        wa_db_bk-file_utilization = wa_final-file_utilization.
        wa_db_bk-message = 'Backup for today'.
        wa_db_bk-start_date = wt_final-zvdate.
        wa_db_bk-start_time = wt_final-zvtime.
        wa_db_bk-duration = wt_final-duration.
        wa_db_bk-status = wt_final-status.
        wa_db_bk-function = wt_final-function.
        wa_db_bk-mb = wt_final-mb.
        APPEND wa_db_bk TO it_db_bk.
        CLEAR wa_db_bk.
      ELSE.
        wa_db_bk-zdtime = wa_final-ztime.
        wa_db_bk-zddate =  wa_final-zdate.
        wa_db_bk-zsize = wa_final-zsize.
        wa_db_bk-used_space = wa_final-used_space.
        wa_db_bk-used_percentage = wa_final-used_percentage.
        wa_db_bk-sysid = wa_final-sysid.
        wa_db_bk-file_utilization = wa_final-file_utilization.
        IF wa_db_bk-start_time IS INITIAL.
          CLEAR wa_db_bk-start_time.
        ENDIF.
        wa_db_bk-message = 'No Backup for today'.
        wa_db_bk-start_date = ''.
        wa_db_bk-start_time = '        '.
        wa_db_bk-duration = ''.
        wa_db_bk-status = ''.
        wa_db_bk-function = ''.
        wa_db_bk-mb = ''.
        APPEND wa_db_bk TO it_db_bk.
        CLEAR  wa_db_bk.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDIF.

IF it_db_bk IS NOT INITIAL.

 MODIFY ZDB_TABLE FROM TABLE IT_DB_BK.

 IF sy-subrc EQ 0.
  MESSAGE text-001 TYPE 'I'.
ELSE.
  MESSAGE text-002 TYPE 'W'.
ENDIF.
ENDIF.


*working code

**IF sy-subrc = 0.
**  IF lv_date IS NOT INITIAL.
**    IF lt_final IS NOT INITIAL.
**      READ TABLE lt_final INTO wa_final INDEX 1.
**      IF sy-subrc = 0.
**        CLEAR it_db_bk.
**        wa_db_bk-zddate =  wa_final-zdate.
**        wa_db_bk-zdtime = wa_final-ztime.
**        wa_db_bk-zsize = wa_final-zsize.
**        wa_db_bk-used_space = wa_final-used_space.
**        wa_db_bk-used_percentage = wa_final-used_percentage.
**        wa_db_bk-sysid = wa_final-sysid.
**        wa_db_bk-file_utilization = wa_final-file_utilization.
***        APPEND wa_db_bk TO it_db_bk.
***        CLEAR wa_db_bk.
**        IF i_final IS NOT INITIAL.
**          READ TABLE i_final INTO wt_final WITH KEY zvdate = lv_date.
**          IF sy-subrc EQ 0.
**            wa_db_bk-message = 'Backup for today'.
**            wa_db_bk-start_date = wt_final-zvdate.
**            wa_db_bk-start_time = wt_final-zvtime.
**            wa_db_bk-duration = wt_final-duration.
**            wa_db_bk-status = wt_final-status.
**            wa_db_bk-function = wt_final-function.
**            wa_db_bk-mb = wt_final-mb.
**            APPEND wa_db_bk TO it_db_bk.
**            CLEAR wa_db_bk.
**          ELSE.
**            IF wa_db_bk-start_time IS INITIAL.
**              CLEAR wa_db_bk-start_time.
**            ENDIF.
**            wa_db_bk-message = 'No Backup for today'.
**            wa_db_bk-start_date = ''.
**            wa_db_bk-start_time = '        '.
**            wa_db_bk-duration = ''.
**            wa_db_bk-status = ''.
**            wa_db_bk-function = ''.
**            wa_db_bk-mb = ''.
**            APPEND wa_db_bk TO it_db_bk.
**            CLEAR  wa_db_bk.
**          ENDIF.
**        ENDIF.
**      ENDIF.
**    ENDIF.
**  ENDIF.
**ENDIF.
**
**IF it_db_bk IS NOT INITIAL.
**  READ TABLE it_db_bk  INTO wa_db_bk INDEX 1.
**  IF sy-subrc EQ 0.
**    INSERT zdb_table FROM TABLE it_db_bk.
**    IF sy-subrc EQ 0.
**      CLEAR it_db_bk.
**      MESSAGE text-001 TYPE 'I'.
**    ELSE.
**      MESSAGE text-002 TYPE 'W'.
**    ENDIF.
**  ENDIF.
**ENDIF.

*end of working ocde


*New code with counter AND WORKING FOR Multiple entries for the given date is successful.
**DATA: count TYPE i.
**IF sy-subrc = 0.
**  READ TABLE lt_final INTO wa_final INDEX 1.
**  IF sy-subrc = 0.
**    LOOP AT i_final INTO wt_final where zvdate = lv_date.
**      if sy-subrc = 0.
**        IF count = 0.
**          wa_db_bk-zdtime = wa_final-ztime.
**          wa_db_bk-zddate =  wa_final-zdate.
**          wa_db_bk-zsize = wa_final-zsize.
**          wa_db_bk-used_space = wa_final-used_space.
**          wa_db_bk-used_percentage = wa_final-used_percentage.
**          wa_db_bk-sysid = wa_final-sysid.
**          wa_db_bk-file_utilization = wa_final-file_utilization.
**          wa_db_bk-message = 'Backup for today'.
**          wa_db_bk-start_date = wt_final-zvdate.
**          wa_db_bk-start_time = wt_final-zvtime.
**          wa_db_bk-duration = wt_final-duration.
**          wa_db_bk-status = wt_final-status.
**          wa_db_bk-function = wt_final-function.
**          wa_db_bk-mb = wt_final-mb.
**          APPEND wa_db_bk TO it_db_bk.
**          CLEAR wa_db_bk.
**        ELSE.
**          wa_db_bk-message = 'Backup for today'.
**          wa_db_bk-start_date = wt_final-zvdate.
**          wa_db_bk-start_time = wt_final-zvtime.
**          wa_db_bk-duration = wt_final-duration.
**          wa_db_bk-status = wt_final-status.
**          wa_db_bk-function = wt_final-function.
**          wa_db_bk-mb = wt_final-mb.
**          APPEND wa_db_bk TO it_db_bk.
**          CLEAR wa_db_bk.
**        ENDIF.
**
**
**      ELSE.
**        IF count = 0.
**          wa_db_bk-zdtime = wa_final-ztime.
**          wa_db_bk-zddate =  wa_final-zdate.
**          wa_db_bk-zsize = wa_final-zsize.
**          wa_db_bk-used_space = wa_final-used_space.
**          wa_db_bk-used_percentage = wa_final-used_percentage.
**          wa_db_bk-sysid = wa_final-sysid.
**          wa_db_bk-file_utilization = wa_final-file_utilization.
**          IF wa_db_bk-start_time IS INITIAL.
**            CLEAR wa_db_bk-start_time.
**          ENDIF.
**          wa_db_bk-message = 'No Backup for today'.
**          wa_db_bk-start_date = ''.
**          wa_db_bk-start_time = '        '.
**          wa_db_bk-duration = ''.
**          wa_db_bk-status = ''.
**          wa_db_bk-function = ''.
**          wa_db_bk-mb = ''.
**          APPEND wa_db_bk TO it_db_bk.
**          CLEAR  wa_db_bk.
**        ENDIF.
**       ENDIF.
**       ENDLOOP.
**    ENDIF.
**
**    count = 1.
**  ELSE.
**    IF wa_db_bk-start_time IS INITIAL.
**      CLEAR wa_db_bk-start_time.
**    ENDIF.
**    wa_db_bk-message = 'No Backup for today'.
**    wa_db_bk-start_date = ''.
**    wa_db_bk-start_time = '        '.
**    wa_db_bk-duration = ''.
**    wa_db_bk-status = ''.
**    wa_db_bk-function = ''.
**    wa_db_bk-mb = ''.
**    APPEND wa_db_bk TO it_db_bk.
**    CLEAR  wa_db_bk.
**
**  ENDIF.
**
**
**
**
**IF it_db_bk IS NOT INITIAL.
**INSERT zdb_table FROM TABLE it_db_bk ACCEPTING DUPLICATE KEYS.
**
**IF sy-subrc EQ 0.
**  MESSAGE text-001 TYPE 'I'.
**ELSE.
**  MESSAGE text-002 TYPE 'W'.
**ENDIF.
**ENDIF.

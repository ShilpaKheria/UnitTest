*&---------------------------------------------------------------------*
*&  Include           ZDB_GROWTH_BACKUP_SELECT
*&---------------------------------------------------------------------*

START-OF-SELECTION.

  EXEC SQL.
    CONNECT TO 'DB_CONN'
  ENDEXEC.
*executing the select command
  EXEC SQL.
    SELECT sum(blocks)*8/1024/1024 into :dbn from v$archived_log where status='A' and dest_id=1

  ENDEXEC.
*closing the connection
  EXEC SQL.
    DISCONNECT :'DB_CONN'
  ENDEXEC.

* select for db growth
  SELECT * FROM db02_coll_plan INTO
           TABLE tab_db02_coll_plan.

  READ TABLE tab_db02_coll_plan ASSIGNING <fs_tab>
       WITH KEY  con_name = 'DEFAULT' smon_id = '100'.  "p_id

  IF <fs_tab> IS ASSIGNED.

    monikey-sys   = '--'.
    monikey-db = sy-sysid.
    monikey-filler   = <fs_tab>-monifill.

    INCLUDE zdb_growth_data.
  ENDIF.





**Select for Databack up
*  SELECT SINGLE sysid saprel dbsys FROM db6navsyst
*                             INTO (lv_id,lv_re,lv_db)
*                             WHERE sysid = sy-sysid AND dbsys = 'ORA'.
*
*  IF  lv_re(1) <> '4'.
*    SELECT beg funct sysid rc ende actid FROM sdbah
*                                 INTO TABLE i_sdbah
*                                 WHERE sysid = lv_id AND funct IN i_funct.
*
*  ENDIF.

*Select for Databack up
  SELECT SINGLE sysid saprel dbsys FROM db6navsyst
                             INTO (lv_id,lv_re,lv_db)
                             WHERE sysid = sy-sysid AND dbsys = 'ORA'.

  IF  lv_re(1) <> '4'.
    SELECT beg funct sysid rc ende actid FROM sdbah INTO CORRESPONDING FIELDS OF TABLE i_sdbah
                                         WHERE sysid = lv_id AND funct IN i_funct
                                         ORDER BY BEG DESCENDING.

  ENDIF.

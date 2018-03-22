*&---------------------------------------------------------------------*
*&  Include           ZDB_GROWTH_DATA
*&---------------------------------------------------------------------*
IMPORT date tab_db_ge_md FROM DATABASE moni(db) ID monikey.
wa_final-zdate = sy-datum.
wa_final-ztime = sy-uzeit.
READ TABLE tab_db_ge_md INTO wa_db_ge_md INDEX 1.

IF sy-subrc = 0.
  wa_final-zsize = wa_db_ge_md-size.
  wa_final-used_space = wa_db_ge_md-used.
  wa_final-used_percentage = wa_db_ge_md-per_used.
  wa_final-sysid = sy-sysid.
  wa_final-file_Utilization = dbn.
  APPEND wa_final TO lt_final.
  CLEAR wa_final.
ENDIF.

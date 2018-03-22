*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_ZBS_ODATA_SERV4
*   generation date: 16.01.2018 at 17:03:34 by user TOPGEAR1
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_ZBS_ODATA_SERV4    .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.

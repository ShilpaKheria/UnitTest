*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 16.01.2018 at 17:03:35 by user TOPGEAR1
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZBS_ODATA_SERV..................................*
DATA:  BEGIN OF STATUS_ZBS_ODATA_SERV                .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZBS_ODATA_SERV                .
CONTROLS: TCTRL_ZBS_ODATA_SERV
            TYPE TABLEVIEW USING SCREEN '0902'.
*.........table declarations:.................................*
TABLES: *ZBS_ODATA_SERV                .
TABLES: ZBS_ODATA_SERV                 .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .

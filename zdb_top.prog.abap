*&---------------------------------------------------------------------*
*&  Include           ZDB_TOP
*&---------------------------------------------------------------------*


TABLES: sdbah.


*PARAMETERS:  p_id   TYPE db02_smon_id OBLIGATORY, "Monitor ID
*             sys_id TYPE sy-sysid OBLIGATORY.    "System ID
*             p_db   TYPE DBCON_NAME  OBLIGATORY.  "Database Name.  "dbcon_dbms


PARAMETERS: p_date TYPE sy-datum.

DATA: lv_date TYPE sy-datum.

*IMPORT P_DATE TO LV_DATE FROM MEMORY ID 'DATE'.

lv_date = P_DATE.

*CONSTANTS: p_id TYPE i VALUE '100'.

DATA:  lv_id TYPE sysysid,
       lv_re TYPE sysaprl,
       lv_db TYPE dbcon_dbms,
       container             TYPE REF TO cl_gui_custom_container, "custom container
       lo_alv                TYPE REF TO cl_gui_alv_grid, "alv grid
*       it_fcat               TYPE lvc_t_fcat,
       lv_temp_stime           TYPE sy-timlo,
       lv_temp_sdate          TYPE sy-datum,
       lv_temp_edate          TYPE sy-datum,
       lv_temp_etime          TYPE sy-timlo,
       duration TYPE i,
       t1 TYPE ccupeaka-timestamp,
       t2 TYPE ccupeaka-timestamp,
       functpart1(8),
       functpart2(8),
       functpart3(10),
       date               TYPE d,
       time               TYPE uzeit,
       smon_id            TYPE string,
       monikey            LIKE monikey,
       used_space         TYPE string,
       used_percentage    TYPE string,
       last_analysis_date TYPE d,
       last_analysis_time TYPE uzeit,
       dbn TYPE string,
       lv_line TYPE sdba_line,         "Stores the line which holds the backup size data.
       lv_bksize TYPE string,          "Storing backup size
       lv_val1(20) TYPE c,
       count TYPE i VALUE 0.


TYPES: tywa_db_ge_md  TYPE db02n_dbgemd.
TYPES: tytab_db_ge_md TYPE STANDARD TABLE OF tywa_db_ge_md.

TYPES: BEGIN OF ty_sdbah,
beg TYPE sdba_begin,
funct TYPE sdba_funct,
sysid TYPE sdba_sysid,
rc TYPE sdba_rc,
ende TYPE sdba_end,
actid TYPE sdba_actid,
END OF ty_sdbah.

DATA: tab_db_ge_md          TYPE tytab_db_ge_md,
      wa_db_ge_md           TYPE tywa_db_ge_md,
      tab_db02_coll_plan    TYPE STANDARD TABLE OF db02_coll_plan,
      it_fcat               TYPE lvc_t_fcat,
      wa_fcat               TYPE lvc_s_fcat,
*      container             TYPE REF TO cl_gui_custom_container, "custom container
*      lo_alv                TYPE REF TO cl_gui_alv_grid, "alv grid
      wa_final              TYPE zdbgrowth,
      lt_final              TYPE STANDARD TABLE OF zdbgrowth,     "Internal table declaraton for DB Growth data
      i_sdbah               TYPE STANDARD TABLE OF ty_sdbah,
      wa_sdbah              TYPE ty_sdbah,
      i_final               TYPE STANDARD TABLE OF zvdummy,       "Internal table declaraton for DB backup data
      wt_final              TYPE zvdummy,
      i_funct               TYPE RANGE OF sdbah-funct,            " Declaration for field-Function range.
      wa_funct              LIKE LINE OF i_funct,
      it_tab TYPE STANDARD TABLE OF sdbalist,                     " Declaration for log file
      wa_tab TYPE sdbalist,
      it_db_bk              TYPE STANDARD TABLE OF zdb_growth_backup,  "Final Internal table for Both DB growth and DB Backup.
      wa_db_bk              TYPE zdb_growth_backup.
      "lt_db_bk              TYPE  TABLE OF zdb_growth_backup .



FIELD-SYMBOLS: <fs_fcat>               TYPE lvc_s_fcat,
               <fs_tab> TYPE db02_coll_plan.




* creating a range for function
wa_funct-sign = 'I'.
wa_funct-option = 'EQ'.
wa_funct-low = 'ant'.
APPEND wa_funct TO i_funct.
CLEAR wa_funct.

wa_funct-sign = 'I'.
wa_funct-option = 'EQ'.
wa_funct-low = 'aft'.
APPEND wa_funct TO i_funct.
CLEAR wa_funct.

wa_funct-sign = 'I'.
wa_funct-option = 'EQ'.
wa_funct-low = 'and'.
APPEND wa_funct TO i_funct.
CLEAR wa_funct.

wa_funct-sign = 'I'.
wa_funct-option = 'EQ'.
wa_funct-low = 'afd'.
APPEND wa_funct TO i_funct.
CLEAR wa_funct.

wa_funct-sign = 'I'.
wa_funct-option = 'EQ'.
wa_funct-low = 'anp'.
APPEND wa_funct TO i_funct.
CLEAR wa_funct.

wa_funct-sign = 'I'.
wa_funct-option = 'EQ'.
wa_funct-low = 'afp'.
APPEND wa_funct TO i_funct.
CLEAR wa_funct.

wa_funct-sign = 'I'.
wa_funct-option = 'EQ'.
wa_funct-low = 'anf'.
APPEND wa_funct TO i_funct.
CLEAR wa_funct.

wa_funct-sign = 'I'.
wa_funct-option = 'EQ'.
wa_funct-low = 'aff'.
APPEND wa_funct TO i_funct.
CLEAR wa_funct.

wa_funct-sign = 'I'.
wa_funct-option = 'EQ'.
wa_funct-low = 'anr'.
APPEND wa_funct TO i_funct.
CLEAR wa_funct.

wa_funct-sign = 'I'.
wa_funct-option = 'EQ'.
wa_funct-low = 'ans'.
APPEND wa_funct TO i_funct.
CLEAR wa_funct.

wa_funct-sign = 'I'.
wa_funct-option = 'EQ'.
wa_funct-low = 'afs'.
APPEND wa_funct TO i_funct.
CLEAR wa_funct.

wa_funct-sign = 'I'.
wa_funct-option = 'EQ'.
wa_funct-low = 'anv'.
APPEND wa_funct TO i_funct.
CLEAR wa_funct.

wa_funct-sign = 'I'.
wa_funct-option = 'EQ'.
wa_funct-low = 'afv'.
APPEND wa_funct TO i_funct.
CLEAR wa_funct.

wa_funct-sign = 'I'.
wa_funct-option = 'EQ'.
wa_funct-low = 'pnt'.
APPEND wa_funct TO i_funct.
CLEAR wa_funct.

wa_funct-sign = 'I'.
wa_funct-option = 'EQ'.
wa_funct-low = 'pft'.
APPEND wa_funct TO i_funct.
CLEAR wa_funct.

wa_funct-sign = 'I'.
wa_funct-option = 'EQ'.
wa_funct-low = 'pnd'.
APPEND wa_funct TO i_funct.
CLEAR wa_funct.

wa_funct-sign = 'I'.
wa_funct-option = 'EQ'.
wa_funct-low = 'pfd'.
APPEND wa_funct TO i_funct.
CLEAR wa_funct.

wa_funct-sign = 'I'.
wa_funct-option = 'EQ'.
wa_funct-low = 'pnp'.
APPEND wa_funct TO i_funct.
CLEAR wa_funct.

wa_funct-sign = 'I'.
wa_funct-option = 'EQ'.
wa_funct-low = 'pfp'.
APPEND wa_funct TO i_funct.
CLEAR wa_funct.

wa_funct-sign = 'I'.
wa_funct-option = 'EQ'.
wa_funct-low = 'pnf'.
APPEND wa_funct TO i_funct.
CLEAR wa_funct.

wa_funct-sign = 'I'.
wa_funct-option = 'EQ'.
wa_funct-low = 'pff'.
APPEND wa_funct TO i_funct.
CLEAR wa_funct.

wa_funct-sign = 'I'.
wa_funct-option = 'EQ'.
wa_funct-low = 'pnr'.
APPEND wa_funct TO i_funct.
CLEAR wa_funct.

wa_funct-sign = 'I'.
wa_funct-option = 'EQ'.
wa_funct-low = 'pfr'.
APPEND wa_funct TO i_funct.
CLEAR wa_funct.

wa_funct-sign = 'I'.
wa_funct-option = 'EQ'.
wa_funct-low = 'pns'.
APPEND wa_funct TO i_funct.
CLEAR wa_funct.

wa_funct-sign = 'I'.
wa_funct-option = 'EQ'.
wa_funct-low = 'pfs'.
APPEND wa_funct TO i_funct.
CLEAR wa_funct.

wa_funct-sign = 'I'.
wa_funct-option = 'EQ'.
wa_funct-low = 'fnt'.
APPEND wa_funct TO i_funct.
CLEAR wa_funct.

wa_funct-sign = 'I'.
wa_funct-option = 'EQ'.
wa_funct-low = 'fft'.
APPEND wa_funct TO i_funct.
CLEAR wa_funct.

wa_funct-sign = 'I'.
wa_funct-option = 'EQ'.
wa_funct-low = 'fnd'.
APPEND wa_funct TO i_funct.
CLEAR wa_funct.

wa_funct-sign = 'I'.
wa_funct-option = 'EQ'.
wa_funct-low = 'ffd'.
APPEND wa_funct TO i_funct.
CLEAR wa_funct.

wa_funct-sign = 'I'.
wa_funct-option = 'EQ'.
wa_funct-low = 'fnp'.
APPEND wa_funct TO i_funct.
CLEAR wa_funct.

wa_funct-sign = 'I'.
wa_funct-option = 'EQ'.
wa_funct-low = 'ffp'.
APPEND wa_funct TO i_funct.
CLEAR wa_funct.

wa_funct-sign = 'I'.
wa_funct-option = 'EQ'.
wa_funct-low = 'fnf'.
APPEND wa_funct TO i_funct.
CLEAR wa_funct.

wa_funct-sign = 'I'.
wa_funct-option = 'EQ'.
wa_funct-low = 'fff'.
APPEND wa_funct TO i_funct.
CLEAR wa_funct.

wa_funct-sign = 'I'.
wa_funct-option = 'EQ'.
wa_funct-low = 'fnr'.
APPEND wa_funct TO i_funct.
CLEAR wa_funct.

wa_funct-sign = 'I'.
wa_funct-option = 'EQ'.
wa_funct-low = 'ffr'.
APPEND wa_funct TO i_funct.
CLEAR wa_funct.

wa_funct-sign = 'I'.
wa_funct-option = 'EQ'.
wa_funct-low = 'fns'.
APPEND wa_funct TO i_funct.
CLEAR wa_funct.

wa_funct-sign = 'I'.
wa_funct-option = 'EQ'.
wa_funct-low = 'ffs'.
APPEND wa_funct TO i_funct.
CLEAR wa_funct.

wa_funct-sign = 'I'.
wa_funct-option = 'EQ'.
wa_funct-low = 'fnv'.
APPEND wa_funct TO i_funct.
CLEAR wa_funct.

wa_funct-sign = 'I'.
wa_funct-option = 'EQ'.
wa_funct-low = 'ffv'.
APPEND wa_funct TO i_funct.
CLEAR wa_funct.

wa_funct-sign = 'I'.
wa_funct-option = 'EQ'.
wa_funct-low = 'int'.
APPEND wa_funct TO i_funct.
CLEAR wa_funct.

wa_funct-sign = 'I'.
wa_funct-option = 'EQ'.
wa_funct-low = 'ift'.
APPEND wa_funct TO i_funct.
CLEAR wa_funct.

wa_funct-sign = 'I'.
wa_funct-option = 'EQ'.
wa_funct-low = 'ind'.
APPEND wa_funct TO i_funct.
CLEAR wa_funct.

wa_funct-sign = 'I'.
wa_funct-option = 'EQ'.
wa_funct-low = 'ifd'.
APPEND wa_funct TO i_funct.
CLEAR wa_funct.

wa_funct-sign = 'I'.
wa_funct-option = 'EQ'.
wa_funct-low = 'inp'.
APPEND wa_funct TO i_funct.
CLEAR wa_funct.

wa_funct-sign = 'I'.
wa_funct-option = 'EQ'.
wa_funct-low = 'ifp'.
APPEND wa_funct TO i_funct.
CLEAR wa_funct.

wa_funct-sign = 'I'.
wa_funct-option = 'EQ'.
wa_funct-low = 'inf'.
APPEND wa_funct TO i_funct.
CLEAR wa_funct.

wa_funct-sign = 'I'.
wa_funct-option = 'EQ'.
wa_funct-low = 'iff'.
APPEND wa_funct TO i_funct.
CLEAR wa_funct.

wa_funct-sign = 'I'.
wa_funct-option = 'EQ'.
wa_funct-low = 'inr'.
APPEND wa_funct TO i_funct.
CLEAR wa_funct.

wa_funct-sign = 'I'.
wa_funct-option = 'EQ'.
wa_funct-low = 'ifr'.
APPEND wa_funct TO i_funct.
CLEAR wa_funct.

wa_funct-sign = 'I'.
wa_funct-option = 'EQ'.
wa_funct-low = 'ins'.
APPEND wa_funct TO i_funct.
CLEAR wa_funct.

wa_funct-sign = 'I'.
wa_funct-option = 'EQ'.
wa_funct-low = 'ifs'.
APPEND wa_funct TO i_funct.
CLEAR wa_funct.

wa_funct-sign = 'I'.
wa_funct-option = 'EQ'.
wa_funct-low = 'ANT'.
APPEND wa_funct TO i_funct.
CLEAR wa_funct.

wa_funct-sign = 'I'.
wa_funct-option = 'EQ'.
wa_funct-low = 'AFT'.
APPEND wa_funct TO i_funct.
CLEAR wa_funct.

wa_funct-sign = 'I'.
wa_funct-option = 'EQ'.
wa_funct-low = 'AND'.
APPEND wa_funct TO i_funct.
CLEAR wa_funct.

wa_funct-sign = 'I'.
wa_funct-option = 'EQ'.
wa_funct-low = 'AFD'.
APPEND wa_funct TO i_funct.
CLEAR wa_funct.

wa_funct-sign = 'I'.
wa_funct-option = 'EQ'.
wa_funct-low = 'ANP'.
APPEND wa_funct TO i_funct.
CLEAR wa_funct.

wa_funct-sign = 'I'.
wa_funct-option = 'EQ'.
wa_funct-low = 'AFP'.
APPEND wa_funct TO i_funct.
CLEAR wa_funct.

wa_funct-sign = 'I'.
wa_funct-option = 'EQ'.
wa_funct-low = 'ANF'.
APPEND wa_funct TO i_funct.
CLEAR wa_funct.

wa_funct-sign = 'I'.
wa_funct-option = 'EQ'.
wa_funct-low = 'AFF'.
APPEND wa_funct TO i_funct.
CLEAR wa_funct.

wa_funct-sign = 'I'.
wa_funct-option = 'EQ'.
wa_funct-low = 'ANR'.
APPEND wa_funct TO i_funct.
CLEAR wa_funct.

wa_funct-sign = 'I'.
wa_funct-option = 'EQ'.
wa_funct-low = 'AFR'.
APPEND wa_funct TO i_funct.
CLEAR wa_funct.

wa_funct-sign = 'I'.
wa_funct-option = 'EQ'.
wa_funct-low = 'ANS'.
APPEND wa_funct TO i_funct.
CLEAR wa_funct.


wa_funct-sign = 'I'.
wa_funct-option = 'EQ'.
wa_funct-low = 'AFS'.
APPEND wa_funct TO i_funct.
CLEAR wa_funct.

wa_funct-sign = 'I'.
wa_funct-option = 'EQ'.
wa_funct-low = 'ANV'.
APPEND wa_funct TO i_funct.
CLEAR wa_funct.

wa_funct-sign = 'I'.
wa_funct-option = 'EQ'.
wa_funct-low = 'AFV'.
APPEND wa_funct TO i_funct.
CLEAR wa_funct.

wa_funct-sign = 'I'.
wa_funct-option = 'EQ'.
wa_funct-low = 'PNT'.
APPEND wa_funct TO i_funct.
CLEAR wa_funct.

wa_funct-sign = 'I'.
wa_funct-option = 'EQ'.
wa_funct-low = 'PFT'.
APPEND wa_funct TO i_funct.
CLEAR wa_funct.

wa_funct-sign = 'I'.
wa_funct-option = 'EQ'.
wa_funct-low = 'PND'.
APPEND wa_funct TO i_funct.
CLEAR wa_funct.

wa_funct-sign = 'I'.
wa_funct-option = 'EQ'.
wa_funct-low = 'PFD'.
APPEND wa_funct TO i_funct.
CLEAR wa_funct.


wa_funct-sign = 'I'.
wa_funct-option = 'EQ'.
wa_funct-low = 'PNP'.
APPEND wa_funct TO i_funct.
CLEAR wa_funct.

wa_funct-sign = 'I'.
wa_funct-option = 'EQ'.
wa_funct-low = 'PFP'.
APPEND wa_funct TO i_funct.
CLEAR wa_funct.

wa_funct-sign = 'I'.
wa_funct-option = 'EQ'.
wa_funct-low = 'PNF'.
APPEND wa_funct TO i_funct.
CLEAR wa_funct.

wa_funct-sign = 'I'.
wa_funct-option = 'EQ'.
wa_funct-low = 'PFF'.
APPEND wa_funct TO i_funct.
CLEAR wa_funct.

wa_funct-sign = 'I'.
wa_funct-option = 'EQ'.
wa_funct-low = 'PNS'.
APPEND wa_funct TO i_funct.
CLEAR wa_funct.

wa_funct-sign = 'I'.
wa_funct-option = 'EQ'.
wa_funct-low = 'PFS'.
APPEND wa_funct TO i_funct.
CLEAR wa_funct.

wa_funct-sign = 'I'.
wa_funct-option = 'EQ'.
wa_funct-low = 'FNT'.
APPEND wa_funct TO i_funct.
CLEAR wa_funct.

wa_funct-sign = 'I'.
wa_funct-option = 'EQ'.
wa_funct-low = 'FFT'.
APPEND wa_funct TO i_funct.
CLEAR wa_funct.

wa_funct-sign = 'I'.
wa_funct-option = 'EQ'.
wa_funct-low = 'FND'.
APPEND wa_funct TO i_funct.
CLEAR wa_funct.


wa_funct-sign = 'I'.
wa_funct-option = 'EQ'.
wa_funct-low = 'FFD'.
APPEND wa_funct TO i_funct.
CLEAR wa_funct.

wa_funct-sign = 'I'.
wa_funct-option = 'EQ'.
wa_funct-low = 'FNP'.
APPEND wa_funct TO i_funct.
CLEAR wa_funct.

wa_funct-sign = 'I'.
wa_funct-option = 'EQ'.
wa_funct-low = 'FFP'.
APPEND wa_funct TO i_funct.
CLEAR wa_funct.

wa_funct-sign = 'I'.
wa_funct-option = 'EQ'.
wa_funct-low = 'FNF'.
APPEND wa_funct TO i_funct.
CLEAR wa_funct.

wa_funct-sign = 'I'.
wa_funct-option = 'EQ'.
wa_funct-low = 'FFF'.
APPEND wa_funct TO i_funct.
CLEAR wa_funct.

wa_funct-sign = 'I'.
wa_funct-option = 'EQ'.
wa_funct-low = 'FNR'.
APPEND wa_funct TO i_funct.
CLEAR wa_funct.

wa_funct-sign = 'I'.
wa_funct-option = 'EQ'.
wa_funct-low = 'FFR'.
APPEND wa_funct TO i_funct.
CLEAR wa_funct.

wa_funct-sign = 'I'.
wa_funct-option = 'EQ'.
wa_funct-low = 'FNS'.
APPEND wa_funct TO i_funct.
CLEAR wa_funct.

wa_funct-sign = 'I'.
wa_funct-option = 'EQ'.
wa_funct-low = 'FFS'.
APPEND wa_funct TO i_funct.
CLEAR wa_funct.

wa_funct-sign = 'I'.
wa_funct-option = 'EQ'.
wa_funct-low = 'FNV'.
APPEND wa_funct TO i_funct.
CLEAR wa_funct.

wa_funct-sign = 'I'.
wa_funct-option = 'EQ'.
wa_funct-low = 'FFV'.
APPEND wa_funct TO i_funct.
CLEAR wa_funct.

wa_funct-sign = 'I'.
wa_funct-option = 'EQ'.
wa_funct-low = 'INT'.
APPEND wa_funct TO i_funct.
CLEAR wa_funct.

wa_funct-sign = 'I'.
wa_funct-option = 'EQ'.
wa_funct-low = 'IFT'.
APPEND wa_funct TO i_funct.
CLEAR wa_funct.

wa_funct-sign = 'I'.
wa_funct-option = 'EQ'.
wa_funct-low = 'IND'.
APPEND wa_funct TO i_funct.
CLEAR wa_funct.

wa_funct-sign = 'I'.
wa_funct-option = 'EQ'.
wa_funct-low = 'IFD'.
APPEND wa_funct TO i_funct.
CLEAR wa_funct.

wa_funct-sign = 'I'.
wa_funct-option = 'EQ'.
wa_funct-low = 'INP'.
APPEND wa_funct TO i_funct.
CLEAR wa_funct.


wa_funct-sign = 'I'.
wa_funct-option = 'EQ'.
wa_funct-low = 'IFP'.
APPEND wa_funct TO i_funct.
CLEAR wa_funct.


wa_funct-sign = 'I'.
wa_funct-option = 'EQ'.
wa_funct-low = 'INF'.
APPEND wa_funct TO i_funct.
CLEAR wa_funct.

wa_funct-sign = 'I'.
wa_funct-option = 'EQ'.
wa_funct-low = 'IFF'.
APPEND wa_funct TO i_funct.
CLEAR wa_funct.

wa_funct-sign = 'I'.
wa_funct-option = 'EQ'.
wa_funct-low = 'INF'.
APPEND wa_funct TO i_funct.
CLEAR wa_funct.


wa_funct-sign = 'I'.
wa_funct-option = 'EQ'.
wa_funct-low = 'IFF'.
APPEND wa_funct TO i_funct.
CLEAR wa_funct.

wa_funct-sign = 'I'.
wa_funct-option = 'EQ'.
wa_funct-low = 'INS'.
APPEND wa_funct TO i_funct.
CLEAR wa_funct.

wa_funct-sign = 'I'.
wa_funct-option = 'EQ'.
wa_funct-low = 'IFS'.
APPEND wa_funct TO i_funct.
CLEAR wa_funct.

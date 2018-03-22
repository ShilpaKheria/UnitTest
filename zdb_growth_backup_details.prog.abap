*&---------------------------------------------------------------------*
*& Report  ZDB_GROWTH_BACKUP_DETAILS
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT zdb_growth_backup_details.


INCLUDE ZDB_TOP.                     " DATA Declarations

INCLUDE ZDB_GROWTH_BACKUP_SELECT.    " Select query for DB Growth data.

INCLUDE ZDB_BACKUP_DATA.             " select DB Backup

*INCLUDE ZDB_GROWTH_BACKUP_OP.        "Displaying the DB Growth and Backup data.

"INCLUDE ZDB_MONITORING.              "Monitoring DB growth and DB backup.

*{   INSERT         EC8K900092                                        1

INCLUDE ZDB_GROWTH_BACKUP_SELECT.
*}   INSERT

*{   INSERT         EC8K900092                                        2

INCLUDE ZDB_BACKUP_DATA.
*}   INSERT

*&---------------------------------------------------------------------*
*& Report  ZGW_MASS_LOCK_UNLOCK_USERS
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT zgw_mass_lock_unlock_users.
TABLES: usr02.

SELECT-OPTIONS: s_bname1 FOR usr02-bname NO INTERVALS.


DATA i_lock_unlock_flag TYPE zgw_lock_unlock_flag.
DATA e_error_str        TYPE string.
DATA s_bname            TYPE zty_bname.
DATA w_bname            TYPE zts_bname.

START-OF-SELECTION.
   w_bname-sign = 'I'.
   w_bname-option = 'EQ'.

   LOOP AT s_bname1.
     w_bname-low = s_bname1-low.
     APPEND w_bname TO s_bname.
   ENDLOOP.

*  CALL FUNCTION 'ZFM_USER_LOCK_UNLOCK_V3'
*    EXPORTING
*      i_lock_unlock_flag = i_lock_unlock_flag
*    IMPORTING
*      e_error_str        = e_error_str
*    TABLES
*      s_bname            = s_bname.

  IF e_error_str IS NOT INITIAL.
    WRITE: e_error_str.
  ELSE.
    WRITE: 'Mass Lock/Unlock request executed successfully'.
  ENDIF.

FUNCTION zgw_kill_usersess_v3.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IM_CLIENT) TYPE  MANDT
*"     VALUE(IM_USERNAME) TYPE  UBNAME
*"     VALUE(IM_TID) TYPE  UTID
*"  EXCEPTIONS
*"      AUTHORITY_ERROR
*"      UNKNOWN_ERROR
*"----------------------------------------------------------------------

*Delete SAP session
  CALL FUNCTION 'TH_DELETE_USER'
    EXPORTING
      user            = im_username
      client          = im_client
      tid             = im_tid
    EXCEPTIONS
      authority_error = 1
      OTHERS          = 2.

  CASE sy-subrc.
    WHEN 0.
    WHEN 1. RAISE authority_error.
    WHEN 2. RAISE unknown_error.
    WHEN OTHERS.
  ENDCASE.
ENDFUNCTION.

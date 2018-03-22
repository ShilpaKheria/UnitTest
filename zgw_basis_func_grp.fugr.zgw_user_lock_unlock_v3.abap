FUNCTION zgw_user_lock_unlock_v3.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_EXCEPTION_STRING) TYPE  STRING
*"  EXCEPTIONS
*"      CANT_CREATE_JOB
*"      INVALID_JOB_DATA
*"      JOBNAME_MISSING
*"      CANT_START_IMMEDIATE
*"      INVALID_STARTDATE
*"      JOB_CLOSE_FAILED
*"      JOB_NOSTEPS
*"      JOB_NOTEX
*"      LOCK_FAILED
*"      INVALID_TARGET
*"      UNLOCK_ERROR
*"----------------------------------------------------------------------

  DATA: isel TYPE TABLE OF rsparams.
  DATA: xsel TYPE rsparams.

  DATA: jobname LIKE tbtcjob-jobname VALUE 'ZGW_USER_LOCK_UNLOCK'.
  DATA: jobgroup LIKE tbtcjob-jobgroup.
  DATA: jobcount LIKE tbtcjob-jobcount.

  CALL FUNCTION 'JOB_OPEN'
    EXPORTING
      jobname          = jobname
    IMPORTING
      jobcount         = jobcount
    EXCEPTIONS
      cant_create_job  = 1
      invalid_job_data = 2
      jobname_missing  = 3
      OTHERS           = 4.

  IF sy-subrc EQ 0.
    xsel-selname = 'S_BNAME1'.
    xsel-kind    = 'S'.
    xsel-sign    = 'I'.
    xsel-option  = 'EQ'.

    DO.
      SPLIT i_exception_string AT ';' INTO xsel-low i_exception_string.
      IF i_exception_string IS NOT INITIAL.
        APPEND xsel TO isel.
      ELSE.
        EXIT.
      ENDIF.
    ENDDO.

    SUBMIT zgw_mass_lock_unlock_users USER sy-uname
    VIA JOB jobname NUMBER jobcount
    WITH SELECTION-TABLE isel AND RETURN.

    CALL FUNCTION 'JOB_CLOSE'
      EXPORTING
        jobname              = jobname
        jobcount             = jobcount
        strtimmed            = 'X'
      EXCEPTIONS
        cant_start_immediate = 1
        invalid_startdate    = 2
        jobname_missing      = 3
        job_close_failed     = 4
        job_nosteps          = 5
        job_notex            = 6
        lock_failed          = 7
        invalid_target       = 8
        OTHERS               = 9.

    CASE sy-subrc.
      WHEN 1. RAISE cant_start_immediate.
      WHEN 2. RAISE invalid_startdate.
      WHEN 3. RAISE jobname_missing.
      WHEN 4. RAISE job_close_failed.
      WHEN 5. RAISE job_nosteps.
      WHEN 6. RAISE job_notex.
      WHEN 7. RAISE lock_failed.
      WHEN 8. RAISE invalid_target.
      WHEN 9. RAISE unlock_error.
    ENDCASE.
  ELSE.
    CASE sy-subrc.
      WHEN 1. RAISE cant_create_job.
      WHEN 2. RAISE invalid_job_data.
      WHEN 3. RAISE jobname_missing.
      WHEN 4. RAISE unknown_error.
    ENDCASE.
  ENDIF.
ENDFUNCTION.

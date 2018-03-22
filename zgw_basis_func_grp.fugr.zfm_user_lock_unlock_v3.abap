FUNCTION zfm_user_lock_unlock_v3.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_LOCK_UNLOCK_FLAG) TYPE  ZGW_LOCK_UNLOCK_FLAG
*"  EXPORTING
*"     VALUE(E_ERROR_STR) TYPE  STRING
*"  TABLES
*"      S_BNAME TYPE  ZTY_BNAME OPTIONAL
*"----------------------------------------------------------------------

  DATA: l_flg_error TYPE flag VALUE ''.
  DATA: lt_usr_locked TYPE STANDARD TABLE OF zusrlck.

  IF i_lock_unlock_flag = 1.
    DELETE FROM zusrlck.
    SELECT bname FROM usr02 INTO TABLE lt_usr_locked
                                 WHERE ustyp EQ 'A'
                                   AND uflag <> 0.

    IF sy-subrc EQ 0.
      INSERT zusrlck FROM TABLE lt_usr_locked.
      IF sy-subrc <> 0.
        e_error_str = 'DB Insertion error'.
        RETURN.
      ELSE.
        COMMIT WORK AND WAIT.
      ENDIF.
    ENDIF.

    SELECT * FROM usr02 INTO TABLE it_usr
                             WHERE bname NOT IN s_bname
                               AND ustyp EQ 'A'
                               AND uflag = 0.

    IF sy-subrc EQ 0.
      LOOP AT it_usr INTO wa_usr.
        CALL FUNCTION 'BAPI_USER_LOCK'
          EXPORTING
            username = wa_usr-bname
          TABLES
            return   = it_return.

        SORT it_return BY type.
        READ TABLE it_return INTO wa_return WITH KEY type = 'E' BINARY SEARCH.
        IF sy-subrc EQ 0.
          l_flg_error = c_x.
          CONCATENATE 'User ID:' wa_usr-bname ',' 'Error: ' wa_return-message INTO e_error_str SEPARATED BY space.
          EXIT.
        ENDIF.
      ENDLOOP.

      IF l_flg_error IS INITIAL.
        LOOP AT it_usr INTO wa_usr.
          CALL FUNCTION 'TH_USER_INFO'
            EXPORTING
              client       = wa_usr-mandt
              user         = wa_usr-bname
            IMPORTING
              act_sessions = w_active.

          IF w_active IS NOT INITIAL.
            CALL FUNCTION 'TH_DELETE_USER'
              EXPORTING
                user            = wa_usr-bname
                client          = wa_usr-mandt
              EXCEPTIONS
                authority_error = 1
                OTHERS          = 2.

            CASE sy-subrc.
              WHEN 0.
              WHEN 1.
                l_flg_error = 'X'.
                e_error_str = 'Authorization'.
                EXIT.
              WHEN 2.
                l_flg_error = 'X'.
                e_error_str = sy-msgv1.
                EXIT.
              WHEN OTHERS.
            ENDCASE.
          ENDIF.
        ENDLOOP.
      ELSE.
        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
      ENDIF.

      IF l_flg_error IS INITIAL.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait = 'X'.
      ELSE.
        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
      ENDIF.
    ENDIF.
  ELSEIF i_lock_unlock_flag = 2.
    SELECT * FROM zusrlck INTO TABLE lt_usr_locked.
    IF lt_usr_locked IS INITIAL.
      SELECT bname FROM usr02 INTO TABLE lt_usr_locked
                                 WHERE ustyp EQ 'A'
                                   AND uflag <> 0.
    ENDIF.

    SELECT * FROM usr02 INTO TABLE it_usr
      FOR ALL ENTRIES IN lt_usr_locked
                             WHERE bname NE lt_usr_locked-bname
                               AND ustyp EQ 'A'
                               AND uflag <> 0.

    IF sy-subrc EQ 0.
      LOOP AT it_usr INTO wa_usr.
        CALL FUNCTION 'BAPI_USER_UNLOCK'
          EXPORTING
            username = wa_usr-bname
          TABLES
            return   = it_return.

        SORT it_return BY type.
        READ TABLE it_return INTO wa_return WITH KEY type = 'E' BINARY SEARCH.
        IF sy-subrc EQ 0.
          l_flg_error = c_x.
          CONCATENATE 'User ID:' wa_usr-bname ',' 'Error: ' wa_return-message INTO e_error_str SEPARATED BY space.
          EXIT.
        ENDIF.
      ENDLOOP.

      IF l_flg_error IS INITIAL.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait = 'X'.
      ELSE.
        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFUNCTION.

FUNCTION Z_ECCERP_LOCK_USER_V3.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IM_USERNAME) TYPE  SYUNAME
*"  EXPORTING
*"     VALUE(EX_MSGTYPE) TYPE  BAPI_MTYPE
*"     VALUE(EX_MSGNAME) TYPE  BAPI_MSG
*"--------------------------------------------------------------------

  TYPES: BEGIN OF lty_usr02,
           mandt TYPE mandt,
           bname TYPE xubname,
           class TYPE xuclass,
           uflag TYPE xuuflag,
           kostl TYPE xukostl,
         END OF lty_usr02.

  DATA: lwa_usr02 TYPE lty_usr02,
        lt_return TYPE bapiret2_tab,
        wa_return TYPE bapiret2.

  CONSTANTS: lc_s TYPE c VALUE 'S'.
  CONSTANTS: lc_e TYPE c VALUE 'E'.

  SELECT  SINGLE
          mandt " client
          bname " User Name in User Master Record
          class " User group in user master maintenance
          uflag " User Lock Status
       FROM usr02
       INTO lwa_usr02
       WHERE bname = im_username.

  IF sy-subrc <> 0.
    ex_msgtype = lc_e.
    ex_msgname = 'No data exists for given inputs'.
  ELSE.
    CALL FUNCTION 'BAPI_USER_LOCK'
      EXPORTING
        username = lwa_usr02-bname
      TABLES
        return   = lt_return.

    READ TABLE lt_return INTO wa_return WITH KEY type = lc_e.
    IF sy-subrc EQ 0.
      ex_msgtype = lc_e.
      ex_msgname = wa_return-message.
    ELSE.
*      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
*        EXPORTING
*          wait = 'X'.

      ex_msgtype = lc_s.
      ex_msgname = 'Locking successful'.
    ENDIF.
  ENDIF.
ENDFUNCTION.

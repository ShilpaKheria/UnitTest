FUNCTION ZSM04_RFC_V3.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IM_USERNAME) TYPE  SYUNAME
*"  EXPORTING
*"     VALUE(EX_MSGTYPE) TYPE  BAPI_MTYPE
*"     VALUE(EX_MESSAGE) TYPE  BAPI_MSG
*"--------------------------------------------------------------------
* ----------------------------------------------------------------------*
*  Program Specification   - Monitoring - User Sessions/Killing
*  Date                    - 09.01.2018
*  Programmer              - Navya V and Deepika Shrivasthav
*  Transport No.           -
*  Description-
*                           RFC used in automation tool to  enhance the
*                           performance by killing the sessions tool will
*                           identify the server in which the user session
*                           is active and kill the User Sessiom
* ----------------------------------------------------------------------*
  DATA: gt_list TYPE STANDARD TABLE OF uinfo,
        gs_list TYPE uinfo.

  CONSTANTS: gc_succmsgtyp  TYPE bapi_mtype VALUE 'S',
             gc_succmsg     TYPE bapi_msg   VALUE 'Success',
             gc_errmsgtyp   TYPE bapi_mtype VALUE 'E',
             gc_errnosess   TYPE bapi_msg   VALUE 'No open sessions exist for given User',
             gc_errkill     TYPE bapi_msg   VALUE 'Error while killing the sessions',
             gc_noauth      TYPE bapi_msg   VALUE 'No authorization',
             gc_unknown     TYPE bapi_msg   VALUE 'Unknown error'.

  CALL FUNCTION 'TH_USER_LIST'
    TABLES
      list          = gt_list
    EXCEPTIONS
      auth_misssing = 1
      OTHERS        = 2.

  IF sy-subrc EQ 0.
    IF gt_list IS NOT INITIAL.

      SORT gt_list BY bname term.

      DELETE gt_list WHERE bname <> im_username.

      IF gt_list IS NOT INITIAL.

        LOOP AT gt_list INTO gs_list .
*     Delete SAP session
          CALL FUNCTION 'TH_DELETE_USER'
            EXPORTING
              user            = gs_list-bname
              client          = gs_list-mandt
              tid             = gs_list-tid
            EXCEPTIONS
              authority_error = 1
              OTHERS          = 2.

          IF sy-subrc = 0.
            ex_msgtype = gc_succmsgtyp.
            ex_message = gc_succmsg.

          ELSE.
            ex_msgtype = gc_errmsgtyp.
            ex_message = gc_errkill.

          ENDIF.

          CLEAR: gs_list.

        ENDLOOP.

      ELSE.
        ex_msgtype = gc_errmsgtyp.
        ex_message = gc_errnosess.

      ENDIF.

    ELSE.
      ex_msgtype = gc_errmsgtyp.
      ex_message = gc_errnosess.

    ENDIF.

    CLEAR: gt_list.
  ELSEIF sy-subrc EQ 1.
    ex_msgtype = gc_errmsgtyp.
    ex_message = gc_noauth.
  ELSEIF sy-subrc EQ 2.
    ex_msgtype = gc_errmsgtyp.
    ex_message = gc_unknown.
  ENDIF.
ENDFUNCTION.

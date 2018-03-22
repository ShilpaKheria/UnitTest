FUNCTION zfm_rfc_spool_req.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_FROM_TIME) TYPE  RSPOCRETIM
*"     VALUE(IV_TO_TIME) TYPE  RSPOCRETIM
*"  EXPORTING
*"     VALUE(IT_SPL_DETL) TYPE  ZTTSPL_DETL
*"  EXCEPTIONS
*"      NO_DATA_FOUND
*"----------------------------------------------------------------------


  CONCATENATE iv_from_time '00' INTO iv_from_time.
  CONCATENATE iv_to_time '00' INTO iv_to_time.

  RANGES : r_timestamp FOR iv_from_time.
  r_timestamp-sign = 'I'.
  r_timestamp-option = 'BT'.
  r_timestamp-low = iv_from_time .
  r_timestamp-high = iv_to_time .
  APPEND r_timestamp.

  REFRESH : it_spl_detl[].

  TYPES : BEGIN OF ty_spl_tmp,
            pjident    TYPE rspoid,
            pjcreatime TYPE rspocretim,
            pjstatus   TYPE rspopjstat,
            pjinfo     TYPE rstscnt,
            pjowner    TYPE rspouser,
            pjclient   TYPE rstsclient,
          END OF ty_spl_tmp.

  DATA : it_spl_tmp TYPE STANDARD TABLE OF ty_spl_tmp,
         wa_spl_tmp TYPE ty_spl_tmp.

  DATA : wa_spcl_delt TYPE zspl_detl.
  REFRESH it_spl_tmp[].

  SELECT pjident
         pjcreatime
         pjstatus
         pjinfo
         pjowner
         pjclient
      FROM tsp02
      INTO TABLE it_spl_tmp
      WHERE pjcreatime IN r_timestamp.

  IF sy-subrc IS INITIAL .
    SORT it_spl_tmp[].
    CLEAR : wa_spl_tmp.
    DELETE it_spl_tmp WHERE pjstatus = '1'.
    DELETE it_spl_tmp WHERE pjstatus = '4'.
    DELETE it_spl_tmp WHERE pjstatus = '5'.
    DELETE it_spl_tmp WHERE pjstatus = '7'.
    DELETE it_spl_tmp WHERE pjstatus = '8'.
    DELETE it_spl_tmp WHERE pjstatus = '9'.

    LOOP AT it_spl_tmp INTO wa_spl_tmp.
      CASE wa_spl_tmp-pjstatus.
          WHEN '2'.
          IF wa_spl_tmp-pjinfo < 255.
            CLEAR : wa_spcl_delt .
            wa_spcl_delt-pjident = wa_spl_tmp-pjident.
            wa_spcl_delt-pjclient = wa_spl_tmp-pjclient.
            wa_spcl_delt-pjowner = wa_spl_tmp-pjowner.
            wa_spcl_delt-pjstatus = 'Waiting'.
            APPEND wa_spcl_delt to it_spl_detl.
          ENDIF.
          WHEN '3'.
            CLEAR : wa_spcl_delt .
            wa_spcl_delt-pjident = wa_spl_tmp-pjident.
            wa_spcl_delt-pjclient = wa_spl_tmp-pjclient.
            wa_spcl_delt-pjowner = wa_spl_tmp-pjowner.
            wa_spcl_delt-pjstatus = 'Waiting'.
            APPEND wa_spcl_delt to it_spl_detl.
          WHEN '6'.
            CLEAR : wa_spcl_delt .
            wa_spcl_delt-pjident = wa_spl_tmp-pjident.
            wa_spcl_delt-pjclient = wa_spl_tmp-pjclient.
            wa_spcl_delt-pjowner = wa_spl_tmp-pjowner.
            wa_spcl_delt-pjstatus = 'Error'.
            APPEND wa_spcl_delt to it_spl_detl.
      ENDCASE.
      CLEAR : wa_spl_tmp.
    ENDLOOP.
    ELSE.
      RAISE NO_DATA_FOUND.
  ENDIF.


ENDFUNCTION.

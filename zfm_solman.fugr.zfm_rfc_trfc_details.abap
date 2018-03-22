FUNCTION zfm_rfc_trfc_details.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_FROM_TIME) TYPE  CHAR14
*"     VALUE(IV_TO_TIME) TYPE  CHAR14
*"  EXPORTING
*"     VALUE(IT_RFC_DETL) TYPE  ZTTSTRFC_DETL
*"  EXCEPTIONS
*"      NO_DATA_FOUND
*"----------------------------------------------------------------------

  TYPES : BEGIN OF ty_rfc_tmp,
            arfcdest  TYPE rfcdest,
            arfcstate TYPE arfcstate,
            arfcuzeit TYPE syuzeit,
            arfcdatum TYPE sydatum,
            arfcuser  TYPE syuname,
          END OF ty_rfc_tmp.

  DATA : gv_time TYPE syuzeit,
         gv_date TYPE sydatum.
  DATA : wa_rfc_detl TYPE zstrfc_detl.

  DATA : it_rfc_tmp TYPE STANDARD TABLE OF ty_rfc_tmp,
         wa_rfc_tmp TYPE ty_rfc_tmp.


  RANGES : r_time FOR gv_time,
           r_date FOR gv_date.

  r_time-sign = 'I'.
  r_time-option = 'BT'.
  r_time-low = iv_from_time+8(06).
  r_time-high =  iv_to_time+8(06).
  APPEND r_time.

  r_date-sign = 'I'.
  r_date-option = 'BT'.
  r_date-low = iv_from_time+0(8).
  r_date-high = iv_to_time+0(8).
  APPEND r_date.


  REFRESH : IT_RFC_DETL[], it_rfc_tmp[].

           SELECT  arfcdest
                   arfcstate
                   arfcuzeit
                   arfcdatum
                   arfcuser
                  FROM ARFCSSTATE
                  INTO TABLE it_rfc_tmp
                  WHERE ARFCSTATE = 'CPICERR' OR
                        ARFCSTATE = 'SYSFAIL'
                        AND arfcuzeit IN r_time
                        AND arfcdatum IN r_date.
             IF sy-subrc IS INITIAL .
              SORT it_rfc_tmp .
              LOOP AT it_rfc_tmp INTO wa_rfc_tmp.
                wa_rfc_detl-ARFCUSER = wa_rfc_tmp-arfcuser.
                wa_rfc_detl-ARFCDEST = wa_rfc_tmp-ARFCDEST.
                wa_rfc_detl-status = 'User is locked. Please notify the person responsible'(001).
                APPEND wa_rfc_detl to IT_RFC_DETL.
               clear : wa_rfc_tmp, wa_rfc_detl.
              ENDLOOP.
              ELSE.
              RAISE no_data_found.
             ENDIF.










ENDFUNCTION.

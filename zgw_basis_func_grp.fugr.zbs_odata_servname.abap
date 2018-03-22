FUNCTION zbs_odata_servname.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  TABLES
*"      IT_ODATA_SERV TYPE  ZBT_ODATA_SERV
*"  EXCEPTIONS
*"      NO_DATA_FOUND
*"----------------------------------------------------------------------

  REFRESH : it_odata_serv[].

  SELECT serv_key
         url
         descp
         FROM zbs_odata_serv INTO CORRESPONDING FIELDS OF TABLE it_odata_serv.
  IF  sy-subrc IS INITIAL .
    SORT it_odata_serv BY serv_key .
  ENDIF.
  IF it_odata_serv[] IS INITIAL.
    RAISE no_data_found.
  ENDIF.




ENDFUNCTION.

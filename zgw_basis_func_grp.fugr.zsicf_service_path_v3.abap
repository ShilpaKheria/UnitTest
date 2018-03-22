FUNCTION ZSICF_SERVICE_PATH_V3.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_SERVICE_PATH) TYPE  ICFREQUEST_PATH OPTIONAL
*"  TABLES
*"      IT_RETURN STRUCTURE  DDSHRETVAL OPTIONAL
*"      IT_FINAL TYPE  ZSERVICE_PATH OPTIONAL
*"  EXCEPTIONS
*"      NO_DATA_AVAILABLE
*"--------------------------------------------------------------------
  DATA: BEGIN OF lt_final OCCURS 0,
        path TYPE icfinstact-path,
        END OF lt_final.
*DATA: it_return LIKE ddshretval OCCURS 0 WITH HEADER LINE.
  IF iv_service_path IS NOT INITIAL.
    TRANSLATE iv_service_path TO LOWER CASE.
    CONCATENATE '%' iv_service_path '%' INTO iv_service_path.
    SELECT  path FROM icfinstact
    INTO TABLE it_final
    WHERE  path LIKE iv_service_path.
  ELSE.
    SELECT  path FROM icfinstact
    INTO TABLE it_final.
  ENDIF.

*  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
*    EXPORTING
*      retfield        = 'PATH'
*      dynprofield     = 'IV_SERVICE_PATH'
*      dynpprog        = sy-cprog
*      dynpnr          = sy-dynnr
*      value_org       = 'S'
*      multiple_choice = 'X'
*    TABLES
*      value_tab       = lt_final
*      return_tab      = it_return.

*  REFRESH it_final.
  MOVE-CORRESPONDING lt_final TO it_final.
  IF it_final[] IS INITIAL .
    RAISE  no_data_available.
  ENDIF.
ENDFUNCTION.

FUNCTION ZSICF_SERVICE_NAME_V3.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(ICF_SERV) TYPE  ICFALTNME OPTIONAL
*"  TABLES
*"      L_RETTAB STRUCTURE  DDSHRETVAL OPTIONAL
*"      IT_FINAL TYPE  ZSERVICE_NAME OPTIONAL
*"  EXCEPTIONS
*"      NO_DATA_AVAILABLE
*"--------------------------------------------------------------------

*  DATA: l_rettab TYPE ddshretval OCCURS 0 WITH HEADER LINE.
  DATA: BEGIN OF intf4_service OCCURS 0,
           icf_name TYPE icfname,
           icfaltnme TYPE icfaltnme,
        END OF intf4_service.

  DATA: BEGIN OF f4_service OCCURS 0,
           variant TYPE icfaltnme,
        END OF f4_service.
  DATA: int_field TYPE dfies-fieldname.
  DATA: wa_f4_serv LIKE intf4_service,
        ls_final TYPE zservice_name_s.

* determ the values

  IF icf_serv IS INITIAL .
    SELECT DISTINCT icf_name icfaltnme FROM icfservice
                       INTO TABLE intf4_service
                       WHERE icf_name NE space.
  ELSEIF icf_serv IS NOT INITIAL.
    CONCATENATE '%' icf_serv '%' INTO icf_serv.
    SELECT DISTINCT icf_name icfaltnme FROM icfservice
                   INTO TABLE intf4_service
                   WHERE  icfaltnme LIKE icf_serv.
  ENDIF.
  LOOP AT intf4_service INTO wa_f4_serv.
    IF NOT wa_f4_serv-icfaltnme IS INITIAL.
      ls_final-variant = wa_f4_serv-icfaltnme.
      f4_service-variant = wa_f4_serv-icfaltnme.
    ELSE.
      f4_service-variant = wa_f4_serv-icf_name.
      ls_final-variant = wa_f4_serv-icf_name.
    ENDIF.
    APPEND f4_service.
    APPEND ls_final TO it_final.
    CLEAR:ls_final.
  ENDLOOP.

*  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
*    EXPORTING
**     retfield        = 'PA_MUSER'
*      retfield        = 'ICF_SERV'
*      value_org       = 'S'
*    TABLES
*      value_tab       = f4_service
*      return_tab      = l_rettab
*    EXCEPTIONS
*      parameter_error = 1
*      no_values_found = 2
*      OTHERS          = 3.

  icf_serv = l_rettab-fieldval.
  MOVE-CORRESPONDING f4_service TO it_final.
  if it_final is INITIAL .
    RAISE NO_DATA_AVAILABLE.
    ENDIF.
ENDFUNCTION.

FUNCTION zsicf_service_detail_v3.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_ROOT_NODE) TYPE  ICFNAME OPTIONAL
*"     VALUE(IV_FLAG) TYPE  ICFALIFLAG
*"     VALUE(IV_COUNT) TYPE  ZGW_REC_COUNT OPTIONAL
*"     VALUE(IV_STRING) TYPE  STRING OPTIONAL
*"  EXPORTING
*"     VALUE(IE_LINE_COUNT) TYPE  ZGW_REC_COUNT
*"     VALUE(ET_RETURN_SERV) TYPE  ZGW_SICFLIST_TT
*"  EXCEPTIONS
*"      NO_ENTRIES_FOUND
*"----------------------------------------------------------------------



  DATA: lt_icf TYPE TABLE OF icfservice,
        ls_icf TYPE icfservice.

  DATA: lt_serv TYPE TABLE OF icfservloc,
        ls_serv TYPE icfservloc.

  DATA: nodguid      TYPE icfnodguid,
        url          TYPE icfurlbuf,
        host_number  TYPE icfhostnum,
        host_name    TYPE icfname,
        extended_url TYPE string.


  DATA: es_return_serv TYPE zgw_sicflist.
  RANGES: r_string FOR icfservice-icfaltnme_orig.


  IF iv_flag = 1.
    SELECT * FROM icfservice INTO TABLE lt_icf
      WHERE icfaltnme_orig <> ''
      AND icfchildno = '0' ORDER BY icfparguid.
  ELSEIF iv_flag EQ 2.
    CONCATENATE '*' iv_string '*' INTO iv_string.
    r_string-sign = 'I'.
    r_string-option = 'CP'.
    r_string-low = iv_string.
    APPEND r_string.

    SELECT * FROM icfservice INTO TABLE lt_icf
     WHERE icfchildno = '0'
     AND icfaltnme_orig IN r_string
    ORDER BY icfparguid.
  ENDIF.                                "count *

  IF lt_icf IS NOT INITIAL.
    SELECT * FROM  icfservloc INTO TABLE lt_serv
      FOR ALL ENTRIES IN lt_icf
        WHERE  icf_name = lt_icf-icf_name
        AND icfparguid = lt_icf-icfparguid.
  ENDIF.

  LOOP AT lt_icf INTO ls_icf.

    nodguid = ls_icf-icfparguid.
    CALL FUNCTION 'HTTP_GET_URL_FROM_NODGUID'
      EXPORTING
        nodguid      = nodguid
      IMPORTING
        url          = url
        host_number  = host_number
        host_name    = host_name
        extended_url = extended_url
      EXCEPTIONS
        icf_inconst  = 1
        OTHERS       = 2.

    IF host_name = iv_root_node.
      es_return_serv-serv_name = ls_icf-icfaltnme_orig.
      es_return_serv-serv_path = extended_url.
      READ TABLE lt_serv INTO ls_serv WITH KEY icf_name = ls_icf-icf_name.
      IF sy-subrc = 0.
        es_return_serv-status = ls_serv-icfactive.
      ENDIF.
      APPEND es_return_serv TO et_return_serv.
    ENDIF.
  ENDLOOP.

  IF et_return_serv[] IS INITIAL.
    RAISE no_entries_found.
  ELSE.
    DESCRIBE TABLE et_return_serv LINES ie_line_count.

    iv_count = iv_count + 1.
    DELETE et_return_serv FROM iv_count.
  ENDIF.
ENDFUNCTION.

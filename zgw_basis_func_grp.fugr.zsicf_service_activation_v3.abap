FUNCTION ZSICF_SERVICE_ACTIVATION_V3.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(ICF_SERV) TYPE  ICFALTNME OPTIONAL
*"     VALUE(S_PATH) TYPE  ICFREQUEST_PATH OPTIONAL
*"     VALUE(IV_ACTIVATE) TYPE  BOOLEAN OPTIONAL
*"     VALUE(IV_DEACTIVATE) TYPE  BOOLEAN OPTIONAL
*"  EXPORTING
*"     VALUE(ES_INT_ICFINSTACT) TYPE  ICFINSTACT
*"  EXCEPTIONS
*"      NODE_NOT_EXISTING
*"      ENQUEUE_ERROR
*"      NO_AUTHORITY
*"      URL_AND_NODEGUID_SPACE
*"      URL_AND_NODEGUID_FILL_IN
*"      NO_INPUT_AVAILABLE
*"      ALREADY_ACTIVE
*"--------------------------------------------------------------------

*"General Data
  TYPE-POOLS: slis.


  DATA: BEGIN OF lt_int_icfinstact OCCURS 0.
          INCLUDE STRUCTURE icfinstact.
  DATA: END OF lt_int_icfinstact.
  DATA: dynpfield     TYPE dynpread,
        dynpfields    TYPE TABLE OF dynpread.
  DATA: hashvalue     TYPE hash160.
  DATA: len           TYPE i.
  DATA: len1          TYPE i.
  DATA: int_alt_path  TYPE string.
  DATA: int_nodguid   TYPE icfnodguid,
        ls_int_icfinstact  TYPE icfinstact,
        lv_icfnodguid      TYPE icfnodguid,
        lv_icfparguid	     TYPE icfparguid,
        lv_int_url         TYPE icfurlbuf,
        lv_active          TYPE icfactive.
  DATA: lv_serv_name TYPE icfname.
  DATA: l_icfinstact TYPE icfinstact.

  FIELD-SYMBOLS: <fs_int_icfinstact>  TYPE icfinstact.

* authenfication
  CALL FUNCTION 'AUTHORITY_CHECK_TCODE'
    EXPORTING
      tcode  = 'SICF'
    EXCEPTIONS
      ok     = 0
      not_ok = 1
      OTHERS = 2.
  IF sy-subrc NE 0.
    RAISE no_authority.
  ENDIF.
  AUTHORITY-CHECK OBJECT 'S_ADMI_FCD'
                  ID 'S_ADMI_FCD' FIELD 'NADM'.
  IF sy-subrc NE 0.
    RAISE no_authority.
  ENDIF.


  IF s_path IS NOT INITIAL.
    ls_int_icfinstact-path = s_path.
    APPEND ls_int_icfinstact TO lt_int_icfinstact.
    CLEAR:ls_int_icfinstact.
  ENDIF.
  IF s_path IS INITIAL AND icf_serv IS INITIAL.
    RAISE no_input_available.
  ENDIF.

  IF icf_serv IS INITIAL.
    LOOP AT lt_int_icfinstact ASSIGNING <fs_int_icfinstact>.
      CLEAR:lv_int_url.
      lv_int_url = <fs_int_icfinstact>-path.
* check consitent from URL
      TRANSLATE lv_int_url TO UPPER CASE.
      IF iv_activate IS NOT INITIAL.
        CALL FUNCTION 'HTTP_ACTIVATE_NODE'
          EXPORTING
            url                      = lv_int_url
            hostname                 = 'DEFAULT_HOST'
            expand                   = 'X'
          EXCEPTIONS
            node_not_existing        = 1
            enqueue_error            = 2
            no_authority             = 3
            url_and_nodeguid_space   = 4
            url_and_nodeguid_fill_in = 5
            OTHERS                   = 6.
        IF sy-subrc <> 0.
          CASE sy-subrc.
            WHEN '1'.
              RAISE node_not_existing.
              <fs_int_icfinstact>-status = text-001.
            WHEN '2'.
              RAISE enqueue_error.
              <fs_int_icfinstact>-status = text-002.
            WHEN '3'.
              RAISE  no_authority.
              <fs_int_icfinstact>-status = text-003.
            WHEN '4'.
              RAISE   url_and_nodeguid_space.
              <fs_int_icfinstact>-status = text-004.
            WHEN '5'.
              RAISE  url_and_nodeguid_fill_in.
              <fs_int_icfinstact>-status = text-005.
            WHEN '6'.
              <fs_int_icfinstact>-status = text-006.
          ENDCASE.
          APPEND <fs_int_icfinstact> TO  lt_int_icfinstact.
        ELSE.
          <fs_int_icfinstact>-status = text-007.
        ENDIF.
      ELSEIF iv_deactivate IS NOT INITIAL.
        CALL FUNCTION 'HTTP_INACTIVATE_NODE'
          EXPORTING
            url                      = lv_int_url
            hostname                 = 'DEFAULT_HOST'
            expand                   = 'X'
          EXCEPTIONS
            node_not_existing        = 1
            enqueue_error            = 2
            no_authority             = 3
            url_and_nodeguid_space   = 4
            url_and_nodeguid_fill_in = 5
            OTHERS                   = 6.
        IF sy-subrc <> 0.
          CASE sy-subrc.
            WHEN '1'.
              RAISE node_not_existing.
              <fs_int_icfinstact>-status = text-001.
            WHEN '2'.
              RAISE enqueue_error.
              <fs_int_icfinstact>-status = text-002.
            WHEN '3'.
              RAISE  no_authority.
              <fs_int_icfinstact>-status = text-003.
            WHEN '4'.
              RAISE   url_and_nodeguid_space.
              <fs_int_icfinstact>-status = text-004.
            WHEN '5'.
              RAISE  url_and_nodeguid_fill_in.
              <fs_int_icfinstact>-status = text-005.
            WHEN '6'.
              <fs_int_icfinstact>-status = text-006.
          ENDCASE.
          APPEND <fs_int_icfinstact> TO  lt_int_icfinstact.
        ELSE.
          <fs_int_icfinstact>-status = text-014.
        ENDIF.
      ENDIF.
      UNASSIGN <fs_int_icfinstact>.
    ENDLOOP.
  ELSEIF icf_serv IS NOT INITIAL.
    CLEAR:lv_icfparguid,lv_icfnodguid.
    SELECT SINGLE  icfparguid icfnodguid icf_name
       FROM icfservice
      INTO (lv_icfparguid , lv_icfnodguid, lv_serv_name )
      WHERE icfaltnme EQ icf_serv.
    IF sy-subrc = 0 AND iv_activate IS NOT INITIAL.
      IF icf_serv IS NOT INITIAL.
        SELECT SINGLE  icfactive
          FROM  icfservloc INTO lv_active
          WHERE icf_name EQ lv_serv_name AND icfparguid EQ lv_icfparguid AND icfactive EQ abap_true.
        IF sy-subrc = 0.
          RAISE already_active.
        ENDIF.
      ENDIF.

      ASSIGN l_icfinstact TO <fs_int_icfinstact>.
      CALL FUNCTION 'HTTP_ACTIVATE_NODE'
        EXPORTING
*{   REPLACE        EC8K900103                                        1
*\          nodeguid                 = lv_icfparguid
          nodeguid                 = lv_icfnodguid
*}   REPLACE
          hostname                 = 'DEFAULT_HOST'
          expand                   = 'X'
        EXCEPTIONS
          node_not_existing        = 1
          enqueue_error            = 2
          no_authority             = 3
          url_and_nodeguid_space   = 4
          url_and_nodeguid_fill_in = 5
          OTHERS                   = 6.
      IF sy-subrc <> 0.
        CASE sy-subrc.
          WHEN '1'.
            RAISE node_not_existing.
            <fs_int_icfinstact>-status = text-001.
          WHEN '2'.
            RAISE enqueue_error.
            <fs_int_icfinstact>-status = text-002.
          WHEN '3'.
            RAISE  no_authority.
            <fs_int_icfinstact>-status = text-003.
          WHEN '4'.
            RAISE   url_and_nodeguid_space.
            <fs_int_icfinstact>-status = text-004.
          WHEN '5'.
            RAISE  url_and_nodeguid_fill_in.
            <fs_int_icfinstact>-status = text-005.
          WHEN '6'.
            <fs_int_icfinstact>-status = text-006.
        ENDCASE.
      ELSE.
        ls_int_icfinstact-status = text-007.
      ENDIF.
      ls_int_icfinstact-path = icf_serv .
      APPEND ls_int_icfinstact TO lt_int_icfinstact.
      CLEAR:ls_int_icfinstact.
    ELSEIF sy-subrc = 0 AND iv_deactivate IS NOT INITIAL.
      ASSIGN l_icfinstact TO <fs_int_icfinstact>.
      CALL FUNCTION 'HTTP_INACTIVATE_NODE'
        EXPORTING
*{   REPLACE        EC8K900103                                        2
*\          nodeguid                 = lv_icfparguid
          nodeguid                 = lv_icfnodguid
*}   REPLACE
          hostname                 = 'DEFAULT_HOST'
          expand                   = 'X'
        EXCEPTIONS
          node_not_existing        = 1
          enqueue_error            = 2
          no_authority             = 3
          url_and_nodeguid_space   = 4
          url_and_nodeguid_fill_in = 5
          OTHERS                   = 6.
      IF sy-subrc <> 0.
        CASE sy-subrc.
          WHEN '1'.
            RAISE node_not_existing.
            <fs_int_icfinstact>-status = text-001.
          WHEN '2'.
            RAISE enqueue_error.
            <fs_int_icfinstact>-status = text-002.
          WHEN '3'.
            RAISE  no_authority.
            <fs_int_icfinstact>-status = text-003.
          WHEN '4'.
            RAISE   url_and_nodeguid_space.
            <fs_int_icfinstact>-status = text-004.
          WHEN '5'.
            RAISE  url_and_nodeguid_fill_in.
            <fs_int_icfinstact>-status = text-005.
          WHEN '6'.
            <fs_int_icfinstact>-status = text-006.
        ENDCASE.
        APPEND <fs_int_icfinstact> TO  lt_int_icfinstact.
      ELSE.
        <fs_int_icfinstact>-status = text-014.
      ENDIF.
    ENDIF.
  ELSE.
    RAISE no_input_available.
  ENDIF.

*  READ TABLE lt_int_icfinstact INTO ls_int_icfinstact.
  READ TABLE lt_int_icfinstact INTO ls_int_icfinstact INDEX 1.
  IF sy-subrc = 0.
    MOVE-CORRESPONDING ls_int_icfinstact TO es_int_icfinstact.
  ENDIF.

ENDFUNCTION.

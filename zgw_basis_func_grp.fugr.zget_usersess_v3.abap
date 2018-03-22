FUNCTION ZGET_USERSESS_V3.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IM_USERNAME) TYPE  SYUNAME
*"  EXPORTING
*"     VALUE(ET_USERSESS) TYPE  ZTT_UINF02_V3
*"  EXCEPTIONS
*"      NOOPENSESSION
*"      ENTERUSERNAME
*"----------------------------------------------------------------------
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
*{   REPLACE        EC8K900103                                        1
*\  DATA: gs_usersess   TYPE zst_uinf02,
  DATA: gs_usersess   TYPE zst_uinf02_v3,
*}   REPLACE
        lv_pnodeindex TYPE i ,
        lv_nodeindex  TYPE i,
        lv_parentnodeid  TYPE i,
        lv_tid        TYPE utid .

  DATA:  lt_info1     TYPE STANDARD TABLE OF uinfo2,
         ls_info1     TYPE uinfo2,
         lv_hierarchy TYPE i.

  DATA: lt_list TYPE STANDARD TABLE OF uinfo,
        ls_list TYPE uinfo.

  IF im_username IS NOT INITIAL.

    CALL FUNCTION 'TH_LONG_USR_INFO'
      EXPORTING
        user      = im_username
      TABLES
        user_info = lt_info1.

    IF lt_info1 IS NOT INITIAL.

      CALL FUNCTION 'TH_USER_LIST'
        TABLES
          list          = lt_list
        EXCEPTIONS
          auth_misssing = 1
          OTHERS        = 2.
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF.

      SORT lt_list BY bname term.

*{   REPLACE        EC8K900103                                        2
*\      DELETE lt_list WHERE bname <> sy-uname.
      DELETE lt_list WHERE bname <> im_username.
*}   REPLACE

      SORT lt_info1 BY user terminal.

      LOOP AT lt_info1 INTO ls_info1.
        lv_nodeindex = lv_nodeindex + 1.
        READ TABLE lt_list INTO ls_list WITH KEY term = ls_info1-terminal.
        IF sy-subrc = 0.
          CLEAR: lv_tid.
          lv_tid = ls_list-tid.
        ENDIF.

        AT NEW terminal.
          CLEAR: lv_parentnodeid.
          gs_usersess-nodeid         = lv_nodeindex.
          gs_usersess-parentnodeid   = ''."lv_pnodeindex.
          lv_pnodeindex              = gs_usersess-nodeid.
          gs_usersess-hierarchylevel = lv_hierarchy.
          gs_usersess-client         = ls_info1-client.
          gs_usersess-terminal       = ls_info1-terminal.
          gs_usersess-tid            = lv_tid.
          gs_usersess-lang           = ls_info1-lang.
          gs_usersess-username       = ls_info1-user.
          lv_parentnodeid = gs_usersess-nodeid  .
          lv_pnodeindex              = lv_pnodeindex  + 1.
          APPEND gs_usersess TO et_usersess.
          CLEAR gs_usersess.
        ENDAT.

        gs_usersess-nodeid         = lv_nodeindex + 1.
        gs_usersess-parentnodeid   = lv_parentnodeid.
        gs_usersess-hierarchylevel = lv_hierarchy + 1.
        gs_usersess-client         = ls_info1-client.
        gs_usersess-lang           = ls_info1-lang.
        gs_usersess-tcode          = ls_info1-tcode.
        gs_usersess-terminal       = ls_info1-terminal.
        gs_usersess-tid            = lv_tid.
        gs_usersess-time           = ls_info1-time.
        gs_usersess-username       = ls_info1-user.
        APPEND gs_usersess TO et_usersess.
        CLEAR gs_usersess.

      ENDLOOP.

    ELSE.
      RAISE noopensession.

    ENDIF.
  ELSE.
    RAISE enterusername.

  ENDIF.

ENDFUNCTION.

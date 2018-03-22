FUNCTION zzsusr_rfc_user_interface.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(USER) LIKE  USR02-BNAME
*"     VALUE(ACTIVITY) LIKE  AUTHB-ACTVT DEFAULT '03'
*"     VALUE(PASSWORD) LIKE  XU213-BCODE OPTIONAL
*"     VALUE(USER_GROUP) LIKE  USR02-CLASS OPTIONAL
*"     VALUE(VALID_FROM) LIKE  USR02-GLTGV OPTIONAL
*"     VALUE(VALID_UNTIL) LIKE  USR02-GLTGB OPTIONAL
*"     VALUE(USER_TYPE) LIKE  USR02-USTYP DEFAULT 'A'
*"     VALUE(ACCOUNT) LIKE  USR02-ACCNT OPTIONAL
*"     VALUE(EXT_NAME) LIKE  USR15-LONGNAME OPTIONAL
*"  EXPORTING
*"     VALUE(USER_GROUP) LIKE  USR02-CLASS
*"     VALUE(USER_STATE) LIKE  USR02-UFLAG
*"     VALUE(VALID_FROM) LIKE  USR02-GLTGV
*"     VALUE(VALID_UNTIL) LIKE  USR02-GLTGB
*"     VALUE(USER_TYPE) LIKE  USR02-USTYP
*"     VALUE(EXT_NAME) LIKE  USR15-LONGNAME
*"     VALUE(ACCOUNT) LIKE  USR02-ACCNT
*"     VALUE(MODIFIER) LIKE  USR02-ANAME
*"     VALUE(MODDATE) LIKE  USR02-ERDAT
*"     VALUE(LOGIN_DATE) LIKE  USR02-TRDAT
*"     VALUE(LOGIN_TIME) LIKE  USR02-LTIME
*"     VALUE(EX_MSGTYPE) TYPE  CHAR01
*"     VALUE(EX_MSGNAME) TYPE  BAPI_MSG
*"  TABLES
*"      USER_DEFAULTS STRUCTURE  USR01 OPTIONAL
*"      USER_ADDRESS STRUCTURE  USR03 OPTIONAL
*"      USER_PARAMETERS STRUCTURE  USR05 OPTIONAL
*"      USER_PROFILES STRUCTURE  US334 OPTIONAL
*"  EXCEPTIONS
*"      USER_DONT_EXIST
*"      USER_ALLREADY_EXISTS
*"      NOT_AUTHORIZED
*"      USERNAME_REQUIRED
*"      BAD_METHOD
*"      PASSWORD_REQUIRED
*"      USERGROUP_DONT_EXIST
*"      BAD_TIME_RAGE
*"      BAD_USERTYPE
*"      UPDATE_ERROR
*"----------------------------------------------------------------------


  DATA: lt_bname                    TYPE        suid_tt_bname
      , lt_node_root                TYPE        suid_tt_node_root
      , lr_node_root                TYPE REF TO suid_st_node_root
      , ls_node_organization        TYPE        suid_st_node_organization
      , lo_msg_buffer               TYPE REF TO if_suid_msg_buffer
      , ls_node_person_name         TYPE        suid_st_node_person_name
      , ls_node_logondata           TYPE        suid_st_node_logondata
      , ls_node_password            TYPE        suid_st_node_password
      , ls_node_defaults            TYPE        suid_st_node_defaults
      , lt_node_parameters          TYPE        suid_tt_node_parameters
      , lt_node_old_parameters      TYPE        suid_tt_node_parameters
      , ls_node_parameter           TYPE        suid_st_node_parameter
      , lr_node_parameter           TYPE REF TO suid_st_node_parameter
      , lr_node_old_parameter       TYPE REF TO suid_st_node_parameter
      , lt_node_profiles            TYPE        suid_tt_node_profiles
      , ls_node_profile             TYPE        suid_st_node_profile
      , lt_node_old_profiles        TYPE        suid_tt_node_profiles
      , lr_node_old_profile         TYPE REF TO suid_st_node_profile
      , lx_suid_identity            TYPE REF TO cx_suid_identity
      , lv_tabix                    TYPE        sy-tabix
      , lv_locked_by_admin          TYPE        char01
      , lv_locked_by_failed_logon   TYPE        char01
      , ls_admindata                TYPE        suid_st_node_admindata
      , lv_rejected                 TYPE        sesf_boolean
      , ls_tsp03                    TYPE        tsp03
      , lv_idadtype                 TYPE        suidadtype
      , ls_tech_user                TYPE        suid_st_node_tech_user
      , lv_grp_required             TYPE        sesf_boolean
      .

  DATA: lv_use_return_table TYPE char01.


  DATA: lv_bypass TYPE char01,
        lv_uflag  TYPE XUUFLAG.


  CONSTANTS : lc_x TYPE char01  VALUE 'X'.




  IF activity = '05'.
    CLEAR : lv_uflag.
    SELECT SINGLE uflag FROM usr02 INTO lv_uflag WHERE
        bname = user .
    IF  lv_uflag = 0.
      CLEAR : lv_bypass .
    ELSE .
      lv_bypass = lc_x.
      ex_msgtype = 'E'.
      ex_msgname = 'USER IS ALREADY LOCKED' .
    ENDIF.
  ELSEIF activity = '43'.
    CLEAR : lv_uflag.
    SELECT SINGLE  uflag FROM usr02 INTO lv_uflag WHERE
        bname = user .
    IF lv_uflag EQ 0.
      lv_bypass = lc_x.
      ex_msgtype = 'E'.
      ex_msgname = 'USER IS NOT LOCKED' .
    ELSE .
      CLEAR : lv_bypass.
    ENDIF.
  ENDIF.





  IF lv_bypass IS INITIAL .



    IF lv_use_return_table IS INITIAL.
      PERFORM authority_check USING user_group activity user.
      PERFORM authority_check_profiles TABLES user_profiles USING user activity.
      PERFORM parameter_check
        USING user activity password user_group valid_from valid_until user_type.
    ENDIF.

    CLEAR: lt_bname.
    APPEND user TO lt_bname.

*   --- Display User -----------------------------------------------------------
*
    IF activity EQ act_show.
      TRY.

          CALL METHOD cl_identity=>retrieve
            EXPORTING
              it_bname      = lt_bname
            IMPORTING
              et_node_root  = lt_node_root
              eo_msg_buffer = lo_msg_buffer.

          READ TABLE lt_node_root REFERENCE INTO lr_node_root INDEX 1.
          IF sy-subrc NE 0.
            CALL METHOD cl_identity=>cleanup.
            RETURN.
          ENDIF.

*.........Get PersonName (Only first and last name)
          CLEAR: ls_node_person_name, user_address, user_address[].
          CALL METHOD lr_node_root->idref->if_identity_address~get_personname
            IMPORTING
              es_personname = ls_node_person_name
              eo_msg_buffer = lo_msg_buffer.

          user_address-name2 = ls_node_person_name-name_last.
          user_address-name1 = ls_node_person_name-name_first.
          user_address-mandt = sy-mandt.
          user_address-bname = user.
          APPEND user_address.

*.........Get LogonData
          CLEAR: ls_node_logondata.
          CALL METHOD lr_node_root->idref->get_logondata
            IMPORTING
              es_logondata  = ls_node_logondata
              eo_msg_buffer = lo_msg_buffer.

          user_group  = ls_node_logondata-class.
          valid_from  = ls_node_logondata-gltgv.
          valid_until = ls_node_logondata-gltgb.
          user_type   = ls_node_logondata-ustyp.
          account     = ls_node_logondata-accnt.

          CALL METHOD lr_node_root->idref->get_lockstatus
            IMPORTING
              ev_locked_by_admin        = lv_locked_by_admin
              ev_locked_by_failed_logon = lv_locked_by_failed_logon
              eo_msg_buffer             = lo_msg_buffer.

          IF     lv_locked_by_failed_logon EQ 'X'.
            state = 1.
          ELSEIF lv_locked_by_admin EQ 'X'.
            state = 2.
          ELSE.
            state = 0.
          ENDIF.

          CALL METHOD lr_node_root->idref->get_admindata
            IMPORTING
              es_admindata  = ls_admindata
              eo_msg_buffer = lo_msg_buffer.

          modifier   = ls_admindata-modifier.
          moddate    = ls_admindata-moddate.
          login_date = ls_admindata-trdat.
          login_time = ls_admindata-ltime.

*.........Get Defaults
          CLEAR: ls_node_defaults, user_defaults, user_defaults[].
          CALL METHOD lr_node_root->idref->get_defaults
            IMPORTING
              es_defaults   = ls_node_defaults
              eo_msg_buffer = lo_msg_buffer.

          MOVE-CORRESPONDING ls_node_defaults TO user_defaults.
          user_defaults-mandt = sy-mandt.
          user_defaults-bname = user.
          APPEND user_defaults.

*.........Get Parameter
          CLEAR: lt_node_parameters, ls_node_parameter, user_parameters, user_parameters[].
          CALL METHOD lr_node_root->idref->get_parameters
            IMPORTING
              et_parameters = lt_node_parameters.

          LOOP AT lt_node_parameters INTO ls_node_parameter.
            MOVE-CORRESPONDING ls_node_parameter TO user_parameters.
            user_parameters-mandt = sy-mandt.
            user_parameters-bname = user.
            APPEND user_parameters.
          ENDLOOP.

*.........Get Profiles
          CLEAR: lt_node_profiles, ls_node_profile, user_profiles, user_profiles[].
          CALL METHOD lr_node_root->idref->get_profiles
            IMPORTING
              et_profiles = lt_node_profiles.

          LOOP AT lt_node_profiles INTO ls_node_profile.
            MOVE ls_node_profile-profile TO user_profiles-profn.
            APPEND user_profiles.
          ENDLOOP.

        CATCH cx_suid_identity INTO lx_suid_identity.
          RETURN.
      ENDTRY.
      RETURN.
    ENDIF.


    TRY.

        CASE activity.
*   --- Create User -----------------------------------------------------------
*
          WHEN act_add.
            CALL METHOD cl_identity=>create
              EXPORTING
                it_bname             = lt_bname
                iv_cua_ts_local_user = 'X'
              IMPORTING
                et_node_root         = lt_node_root
                eo_msg_buffer        = lo_msg_buffer.

            READ TABLE lt_node_root REFERENCE INTO lr_node_root INDEX 1.
            IF sy-subrc NE 0.
              CALL METHOD cl_identity=>cleanup.
              RAISE update_error.
            ENDIF.

            CALL METHOD lr_node_root->idref->get_identity_indicator
              IMPORTING
                ev_id_indicator = lv_idadtype.

*...........Old User: Create Default address
            IF lv_idadtype EQ if_identity=>co_idad_olduser.
              CALL FUNCTION 'SUSR_COMP_ADDR_DEFAULT_GET'
                EXCEPTIONS
                  no_default_comp_addr = 1
                  OTHERS               = 2.
            ENDIF.

*...........Set Technical User
            CLEAR: ls_tech_user.
            ls_tech_user-tech_indicator = 'X'.

            CALL METHOD lr_node_root->idref->if_identity_address~set_technical_user_indicator
              EXPORTING
                is_tech_user = ls_tech_user.


*...........Set LogonData
            CLEAR: ls_node_logondata.
            ls_node_logondata-gltgv = valid_from.
            ls_node_logondata-gltgb = valid_until.
            ls_node_logondata-ustyp = user_type.
            ls_node_logondata-class = user_group.
            ls_node_logondata-accnt = account.

            CALL METHOD lr_node_root->idref->set_logondata
              EXPORTING
                is_logondata = ls_node_logondata.

*...........Set Password
            CLEAR: ls_node_password.
            ls_node_password-password = password.
            CALL METHOD lr_node_root->idref->if_identity_password~set_password
              EXPORTING
                iv_pwdplain = ls_node_password.

*...........Set Defaults
            CLEAR: ls_node_defaults.
            READ TABLE user_defaults INDEX 1.    " Nur erste Zeile
            MOVE-CORRESPONDING user_defaults TO ls_node_defaults.
            ls_node_defaults-start_menu = user_defaults-stcod.

            CALL METHOD lr_node_root->idref->set_defaults
              EXPORTING
                is_defaults = ls_node_defaults.

*...........Set Parameter
            CLEAR: lt_node_parameters, ls_node_parameter.
            LOOP AT user_parameters .
              MOVE-CORRESPONDING user_parameters TO ls_node_parameter.
              ls_node_parameter-change_mode = if_identity=>co_insert.
              APPEND ls_node_parameter TO lt_node_parameters.
            ENDLOOP.

            SORT lt_node_parameters BY parid.
            CALL METHOD lr_node_root->idref->set_parameters
              EXPORTING
                it_parameters = lt_node_parameters.

*...........Set Profiles
            CLEAR: lt_node_profiles, ls_node_profile.
            LOOP AT user_profiles.
              MOVE user_profiles-profn TO ls_node_profile-profile.
              ls_node_profile-change_mode  = if_identity=>co_insert.
              APPEND ls_node_profile TO lt_node_profiles.
            ENDLOOP.

            CALL METHOD lr_node_root->idref->set_profiles
              EXPORTING
                it_profiles = lt_node_profiles.


*   --- Change User -----------------------------------------------------------
*
          WHEN act_change.
            CALL METHOD cl_identity=>retrieve_for_update
              EXPORTING
                it_bname      = lt_bname
              IMPORTING
                et_node_root  = lt_node_root
                eo_msg_buffer = lo_msg_buffer.

            READ TABLE lt_node_root REFERENCE INTO lr_node_root INDEX 1.
            IF sy-subrc NE 0.
              CALL METHOD cl_identity=>cleanup.
              RAISE update_error.
            ENDIF.


*...........Set PersonName (Only first and last name)
            CLEAR: ls_node_person_name.
            CALL METHOD lr_node_root->idref->if_identity_address~get_personname
              IMPORTING
                es_personname = ls_node_person_name.

            READ TABLE user_address INDEX 1.    " Nur erste Zeile
            IF user_address-name2 IS NOT INITIAL.
              ls_node_person_name-name_last  = user_address-name2.
            ENDIF.
            IF ls_node_person_name-name_last IS INITIAL.
              ls_node_person_name-name_last = user.
            ENDIF.
            IF user_address-name1 IS NOT INITIAL.
              ls_node_person_name-name_first = user_address-name1.
            ENDIF.

            CALL METHOD lr_node_root->idref->if_identity_address~set_personname
              EXPORTING
                is_personname = ls_node_person_name.

*...........Set LogonData
            CLEAR: ls_node_logondata.
            CALL METHOD lr_node_root->idref->get_logondata
              IMPORTING
                es_logondata = ls_node_logondata.

            IF ls_node_logondata-gltgv NE valid_from.
              ls_node_logondata-gltgv = valid_from.
            ENDIF.
            IF ls_node_logondata-gltgb NE valid_until.
              ls_node_logondata-gltgb = valid_until.
            ENDIF.
            IF ls_node_logondata-ustyp NE user_type.
              ls_node_logondata-ustyp = user_type.
            ENDIF.
            IF ls_node_logondata-class NE user_group.
              CALL METHOD cl_suid_tools=>check_user_grp_required
                IMPORTING
                  ev_active = lv_grp_required.
              IF lv_grp_required IS INITIAL.
                ls_node_logondata-class = user_group.
              ELSEIF user_group IS NOT INITIAL.
                ls_node_logondata-class = user_group.
              ENDIF.
            ENDIF.
            IF ls_node_logondata-accnt NE account.
              ls_node_logondata-accnt = account.
            ENDIF.

            CALL METHOD lr_node_root->idref->set_logondata
              EXPORTING
                is_logondata = ls_node_logondata.

*...........Set Password
            IF password IS NOT INITIAL.
              CLEAR: ls_node_password.
              ls_node_password-password = password.
              CALL METHOD lr_node_root->idref->if_identity_password~set_password
                EXPORTING
                  iv_pwdplain = ls_node_password.
            ENDIF.

*...........Set Defaults
            READ TABLE user_defaults INDEX 1.    " Nur erste Zeile
            CLEAR: ls_node_defaults.
            CALL METHOD lr_node_root->idref->get_defaults
              IMPORTING
                es_defaults = ls_node_defaults.

            IF user_defaults-stcod IS NOT INITIAL.
              ls_node_defaults-start_menu = user_defaults-stcod.
            ENDIF.

            IF cl_abap_datfm=>check_date_format( user_defaults-datfm ) = 'X'.
              ls_node_defaults-datfm = user_defaults-datfm.
            ENDIF.

            ls_node_defaults-dcpfm = user_defaults-dcpfm.

            IF user_defaults-spda IS INITIAL.
              user_defaults-spda = 'D'.
            ENDIF.
            ls_node_defaults-spda = user_defaults-spda.

            IF user_defaults-spdb IS INITIAL.
              user_defaults-spdb = 'G'.
            ENDIF.
            ls_node_defaults-spdb = user_defaults-spdb.

            IF user_defaults-spld NE space.
              SELECT SINGLE * FROM tsp03 INTO ls_tsp03
                     WHERE padest = user_defaults-spld.
              IF sy-subrc <> 0.
                CLEAR user_defaults-spld.
              ENDIF.
            ENDIF.
            ls_node_defaults-spld = user_defaults-spld.

            CALL METHOD lr_node_root->idref->set_defaults
              EXPORTING
                is_defaults = ls_node_defaults.

*...........Set Parameter
            CLEAR: lt_node_parameters, ls_node_parameter, lt_node_old_parameters.
            CALL METHOD lr_node_root->idref->get_parameters
              IMPORTING
                et_parameters = lt_node_old_parameters.

            LOOP AT user_parameters.
              MOVE-CORRESPONDING user_parameters TO ls_node_parameter.
              READ TABLE lt_node_old_parameters
                   WITH KEY parid = ls_node_parameter-parid
                   TRANSPORTING NO FIELDS
                   BINARY SEARCH.
              lv_tabix = sy-tabix.
              IF sy-subrc NE 0.
                ls_node_parameter-change_mode = if_identity=>co_insert.
              ELSE.
                ls_node_parameter-change_mode = if_identity=>co_update.
                DELETE lt_node_old_parameters INDEX lv_tabix.
              ENDIF.
              APPEND ls_node_parameter TO lt_node_parameters.
            ENDLOOP.

            SORT lt_node_parameters BY parid.

            LOOP AT lt_node_old_parameters REFERENCE INTO lr_node_old_parameter.
              READ TABLE lt_node_parameters
                   WITH KEY parid = lr_node_old_parameter->parid
                   TRANSPORTING NO FIELDS
                   BINARY SEARCH.
              lv_tabix = sy-tabix.
              IF sy-subrc <> 0.
                INSERT INITIAL LINE INTO lt_node_parameters REFERENCE INTO lr_node_parameter
                       INDEX lv_tabix.
                MOVE lr_node_old_parameter->* TO lr_node_parameter->*.
                lr_node_parameter->change_mode = if_identity=>co_delete.
              ENDIF.
            ENDLOOP.

            SORT lt_node_parameters BY parid.
            CALL METHOD lr_node_root->idref->set_parameters
              EXPORTING
                it_parameters = lt_node_parameters.

*...........Set Profiles
            CLEAR: lt_node_profiles, ls_node_profile.
            CALL METHOD lr_node_root->idref->get_profiles
              IMPORTING
                et_profiles = lt_node_old_profiles.

            LOOP AT user_profiles.
              ls_node_profile-profile = user_profiles-profn.
              READ TABLE lt_node_old_profiles
                   WITH KEY profile = ls_node_profile-profile
                   TRANSPORTING NO FIELDS
                   BINARY SEARCH.
              lv_tabix = sy-tabix.
              IF sy-subrc NE 0.
                ls_node_profile-change_mode  = if_identity=>co_insert.
                APPEND ls_node_profile TO lt_node_profiles.
              ELSE.
                DELETE lt_node_old_profiles INDEX lv_tabix.
              ENDIF.
            ENDLOOP.

            SORT lt_node_profiles.

            LOOP AT lt_node_old_profiles REFERENCE INTO lr_node_old_profile
                 WHERE type <> 'G'.
              READ TABLE lt_node_profiles
                   WITH KEY profile = lr_node_old_profile->profile
                   TRANSPORTING NO FIELDS
                   BINARY SEARCH.
              lv_tabix = sy-tabix.
              IF sy-subrc <> 0.
                lr_node_old_profile->change_mode = if_identity=>co_delete.
                INSERT lr_node_old_profile->* INTO lt_node_profiles INDEX lv_tabix.
              ENDIF.
            ENDLOOP.

            SORT lt_node_profiles.

            CALL METHOD lr_node_root->idref->set_profiles
              EXPORTING
                it_profiles = lt_node_profiles.


*   --- Lock User -----------------------------------------------------------
*
          WHEN act_lock.

            CALL METHOD cl_identity=>retrieve_for_update
              EXPORTING
                it_bname      = lt_bname
                iv_node_name  = if_identity_definition=>gc_node_lockdata
              IMPORTING
                et_node_root  = lt_node_root
                eo_msg_buffer = lo_msg_buffer.

            READ TABLE lt_node_root REFERENCE INTO lr_node_root INDEX 1.
            IF sy-subrc NE 0.
              CALL METHOD cl_identity=>cleanup.
              RAISE update_error.
            ENDIF.

            CALL METHOD lr_node_root->idref->action_lock.


*   --- Unlock User -----------------------------------------------------------
*
          WHEN act_unlock.

            CALL METHOD cl_identity=>retrieve_for_update
              EXPORTING
                it_bname      = lt_bname
                iv_node_name  = if_identity_definition=>gc_node_lockdata
              IMPORTING
                et_node_root  = lt_node_root
                eo_msg_buffer = lo_msg_buffer.

            READ TABLE lt_node_root REFERENCE INTO lr_node_root INDEX 1.
            IF sy-subrc NE 0.
              CALL METHOD cl_identity=>cleanup.
              RAISE update_error.
            ENDIF.

            CALL METHOD lr_node_root->idref->action_unlock.


*   --- Delete User -----------------------------------------------------------
*
          WHEN act_delete.

            CALL METHOD cl_identity=>delete
              EXPORTING
                it_bname     = lt_bname
              IMPORTING
                et_node_root = lt_node_root.

            READ TABLE lt_node_root REFERENCE INTO lr_node_root INDEX 1.
            IF sy-subrc NE 0.
              CALL METHOD cl_identity=>cleanup.
              RAISE update_error.
            ENDIF.

        ENDCASE.

        cl_identity=>do_check(
          IMPORTING
            ev_rejected   = lv_rejected ).

        IF lv_rejected EQ 'X'.
          CALL METHOD cl_identity=>cleanup.
          RAISE update_error.
        ENDIF.

        cl_identity=>do_save(
          EXPORTING
            iv_update_task = if_identity=>co_false
          IMPORTING
            ev_rejected    = lv_rejected ).

        IF lv_rejected EQ 'X'.
          CALL METHOD cl_identity=>cleanup.
          RAISE update_error.
        ENDIF.

      CATCH cx_suid_identity INTO lx_suid_identity.
        RAISE update_error.
    ENDTRY.


*  commit work.  "nicht BI fähig   done by Aritra
*  call function 'DB_COMMIT'
*    exceptions
*      others = 1.
    IF activity = '05'.
      ex_msgtype = 'S'.
      ex_msgname = 'USER IS SUCCESSFULLY LOCKED ' .
    ELSEIF activity = '43'.
      ex_msgtype = 'S'.
      ex_msgname = 'USER IS SUCCESSFULLY UNLOCKED ' .
    ENDIF.
  ENDIF.
ENDFUNCTION.

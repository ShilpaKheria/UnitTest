*&---------------------------------------------------------------------*
*&  Include           LZVMI_USER_LOCKF01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  AUTHORITY_CHECK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_USER_GROUP  text
*      -->P_ACTIVITY  text
*      -->P_USER  text
*----------------------------------------------------------------------*
form authority_check using group method user.
  data: rc              like sy-subrc
      , activity(2)
      , ls_usr02        type usr02
      , lv_grp_required	type sesf_boolean
      .

  if method = act_unlock.              "<<<<< changed
    activity = act_lock.               "<<<<< changed
  else.
    activity = method.                 "<<<<< changed
  endif.

  if method eq act_add.
    perform auth_check using obj_group
            group space act_add rc.
    if rc <> 0.
      raise not_authorized.
    endif.
  else.
    clear: ls_usr02.
    select single * from usr02 into ls_usr02
           where bname = user.
    if sy-subrc ne 0.
      return. " User does not exist -> exit later
    endif.
    perform auth_check using obj_group
            ls_usr02-class space activity rc.
    if rc <> 0.
      raise not_authorized.
    endif.
    if method eq act_change and group ne ls_usr02-class.
      call method cl_suid_tools=>check_user_grp_required
        importing
          ev_active = lv_grp_required.
      " If group is required and new group is initial -> group cannot be set, no check
      if not ( group is initial and lv_grp_required eq if_identity=>co_true ).
        perform auth_check using obj_group
                group space act_add rc.
        if rc <> 0.
          raise not_authorized.
        endif.
      endif.
    endif.
  endif.

endform.
*&---------------------------------------------------------------------*
*&      Form  AUTHORITY_CHECK_PROFILES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_USER_PROFILES  text
*      -->P_USER  text
*      -->P_ACTIVITY  text
*----------------------------------------------------------------------*

form authority_check_profiles
     tables user_profiles structure  us334
      using user activity.

  data: lt_ust04 type table of ust04
      , ls_ust04 type          ust04
      .

  if activity eq act_add     or
     activity eq act_change.

    select * from ust04 into table lt_ust04
            where bname = user.

    sort lt_ust04.
    sort user_profiles.

    loop at user_profiles.
      read table lt_ust04 with key profile = user_profiles-profn
           binary search
           transporting no fields.
      if sy-subrc ne 0.
        call function 'SUSR_BASE_AUTHORITY_CHECK'
          exporting
            asg_type       = 'UP'
            profile        = user_profiles-profn
            user           = user
          exceptions
            not_authorized = 1
            others         = 3.
        if sy-subrc ne 0.
          raise not_authorized.
        endif.
      endif.
    endloop.

    loop at lt_ust04 into ls_ust04.
      read table user_profiles with key profn = ls_ust04-profile
           binary search
           transporting no fields.
      if sy-subrc ne 0.
        call function 'SUSR_BASE_AUTHORITY_CHECK'
          exporting
            asg_type       = 'UP'
            profile        = ls_ust04-profile
            user           = user
          exceptions
            not_authorized = 1
            others         = 3.
        if sy-subrc ne 0.
          raise not_authorized.
        endif.
      endif.
    endloop.
  endif.

endform.                    " authority_check_profiles

FORM auth_check USING objtype TYPE any
                      val1    TYPE any
                      val2    TYPE any
                      val3    TYPE any
                      rc      TYPE any.

  CONSTANTS: obj_sys(3) VALUE 'SYS'.

  CASE objtype.
    WHEN obj_objct.                                     "#EC PF_ACT_GLO
      IF val1 = space AND val2 = space.
        AUTHORITY-CHECK OBJECT 'S_DEVELOP'
                 ID 'DEVCLASS' DUMMY
                 ID 'OBJTYPE'  FIELD 'SUSO'
                 ID 'OBJNAME'  DUMMY
                 ID 'P_GROUP'  DUMMY
                 ID 'ACTVT'    FIELD val3.
      ELSE.
        AUTHORITY-CHECK OBJECT 'S_DEVELOP'
                 ID 'DEVCLASS' DUMMY
                 ID 'OBJTYPE'  FIELD 'SUSO'
                 ID 'OBJNAME'  FIELD val1
                 ID 'P_GROUP'  DUMMY
                 ID 'ACTVT'    FIELD val3.
      ENDIF.
    WHEN obj_auth.                                      "#EC PF_ACT_GLO
      IF val1 = space AND val2 = space.
        AUTHORITY-CHECK OBJECT 'S_USER_AUT'
                        ID 'OBJECT' DUMMY
                        ID 'AUTH'   DUMMY
                        ID 'ACTVT'  FIELD val3.
      ELSE.
        IF val1 = space.
          AUTHORITY-CHECK OBJECT 'S_USER_AUT'
                          ID 'OBJECT' DUMMY
                          ID 'AUTH'   FIELD val2
                          ID 'ACTVT'  FIELD val3.
        ELSE.
          IF val2 = space.
            AUTHORITY-CHECK OBJECT 'S_USER_AUT'
                            ID 'OBJECT' FIELD val1
                            ID 'AUTH'   DUMMY
                            ID 'ACTVT'  FIELD val3.
          ELSE.
            AUTHORITY-CHECK OBJECT 'S_USER_AUT'
                            ID 'OBJECT' FIELD val1
                            ID 'AUTH'   FIELD val2
                            ID 'ACTVT'  FIELD val3.
          ENDIF.
        ENDIF.
      ENDIF.
    WHEN obj_prof.                                      "#EC PF_ACT_GLO
      IF val1 = space.
        AUTHORITY-CHECK OBJECT 'S_USER_PRO'
                        ID 'PROFILE' DUMMY
                        ID 'ACTVT'   FIELD val3.
      ELSE.
        AUTHORITY-CHECK OBJECT 'S_USER_PRO'
                        ID 'PROFILE' FIELD val1
                        ID 'ACTVT'   FIELD val3.
      ENDIF.
    WHEN obj_group.                                     "#EC PF_ACT_GLO
      IF val1 = space.
        AUTHORITY-CHECK OBJECT 'S_USER_GRP'
                        ID 'CLASS' DUMMY
                        ID 'ACTVT' FIELD val3.
      ELSE.
        AUTHORITY-CHECK OBJECT 'S_USER_GRP'
                        ID 'CLASS' FIELD val1
                        ID 'ACTVT' FIELD val3.
      ENDIF.
    WHEN obj_sys.                                       "#EC PF_ACT_GLO
      IF val1 = space.
        AUTHORITY-CHECK OBJECT 'S_USER_SYS'
                        ID 'SUBSYSTEM' DUMMY
                        ID 'ACTVT'     FIELD val3.
      ELSE.
        AUTHORITY-CHECK OBJECT 'S_USER_SYS'
                        ID 'SUBSYSTEM' FIELD val1
                        ID 'ACTVT'     FIELD val3.
      ENDIF.
  ENDCASE.
  rc = sy-subrc.
ENDFORM.
form parameter_check
  using user             type usr02-bname
        method           type authb-actvt
        password         type xu213-bcode
        group            type usr02-class
        validf           type usr02-gltgv
        validu           type usr02-gltgb
        type             type usr02-ustyp.

  data: lv_old_style_pwd type boole_d
      , lv_bapipwd       type bapipwd
      , lv_rc            type sysubrc
      , ls_msg           type symsg
      , ls_usgrp         type usgrp
      , lv_bname         type usr02-bname
      .

  "username must be specified!
  if ( user = space ).
    message id '01' type 'E' number '264'
       raising username_required.
  endif.

  "check for supported activities
  if ( method <> act_add    ) and
     ( method <> act_change ) and
     ( method <> act_show   ) and
     ( method <> act_lock   ) and
     ( method <> act_delete ) and
     ( method <> act_unlock ).
    raise bad_method.
  endif.

  "In case of user creation a password must be specified!
  if ( method   = act_add   ) and
     ( password = space     ).
    message id '01' type 'E' number '290'
       raising password_required.
  endif.

  "Only defined usergroups (table USGRP) are allowed!
  if ( method <> act_show   ) and
     ( group  <> space      ).
    select single * from usgrp into ls_usgrp where usergroup = group.
    if ( sy-subrc <> 0 ).
      message id '01' type 'E' number '518' with group
         raising usergroup_dont_exist.
    endif..
  endif.

  "If specified, the valid from date must be less than the valid to date!
  if ( method <> act_show   ) and
     ( validf > '000000'    ) and
     ( validu > '000000'    ) and
     ( validf > validu      ).
    message id '01' type 'E' number '105' with validf validu
       raising bad_time_rage. "bad_time_range was meant
  endif.

  "check for allowed user types
  if ( method <> act_show   ) and
     ( type   <> typdia     ) and
     ( type   <> typbatch   ) and
     ( type   <> typcpic    ) and
     ( type   <> typbdc     ).
    message id '01' type 'E' number '519' with type
       raising bad_usertype.
  endif.

  "user must: NOT exist in case of creation
  "       &&      exist in all other cases
  select single bname from usr02 into lv_bname where bname = user.
  if     ( sy-subrc =  0       ) and
         ( method   =  act_add ).
    message id '01' type 'E' number '224' with user
       raising user_allready_exists.
  elseif ( sy-subrc <> 0       ) and
         ( method   <> act_add ).
    message id '01' type 'E' number '124' with user
       raising user_dont_exist.
  endif.

  "check if new password meets the rules:
  if ( ( method = act_add    ) or
       ( method = act_change )    ) and
     ( not password is initial    ).

    "evaluate login/password_downwards_compatibility
    call function 'GET_PASSWORD_COMPATIBILITY'
      importing
        only_old_style = lv_old_style_pwd.

    lv_bapipwd-bapipwd = password.

    if ( not lv_old_style_pwd is initial ).
      translate lv_bapipwd-bapipwd to upper case.        "#EC TRANSLANG
    endif.

    call function 'PASSWORD_FORMAL_CHECK'
      exporting
        password             = lv_bapipwd
        downwards_compatible = lv_old_style_pwd
      importing
        rc                   = lv_rc
        msgid                = ls_msg-msgid
        msgno                = ls_msg-msgno
        msgv1                = ls_msg-msgv1
        msgv2                = ls_msg-msgv2
        msgv3                = ls_msg-msgv3
        msgv4                = ls_msg-msgv4
      exceptions
        internal_error       = 1
        others               = 2
              .
    if ( sy-subrc <> 0 ) or
       ( lv_rc    <> 0 ).

      if ( lv_rc = 100 ).
        "usually we inform the administrator about, but not in this 'dark mode'.
        "message w194(00). "Password is part of the Exception-Table
      else.
        message id ls_msg-msgid type 'E' number ls_msg-msgno
              with ls_msg-msgv1 ls_msg-msgv2 ls_msg-msgv3 ls_msg-msgv4
           raising password_required.
      endif.
    endif.

  endif.

endform.                               " PARAMETER_CHECK

*----------------------------------------------------------------------*
*       CLASS ZCL_ZGW_BASIS_ODATA_DPC_EXT DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
class ZCL_ZGW_BASIS_ODATA_DPC_EXT definition
  public
  inheriting from ZCL_ZGW_BASIS_ODATA_DPC
  create public .

public section.

  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~CHANGESET_BEGIN
    redefinition .
  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~CHANGESET_END
    redefinition .
  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~CHANGESET_PROCESS
    redefinition .
protected section.

  methods DBBACKUPREPTSET_GET_ENTITYSET
    redefinition .
  methods ITODATASERVSET_GET_ENTITY
    redefinition .
  methods ITODATASERVSET_GET_ENTITYSET
    redefinition .
  methods SERVACTDEACTSET_UPDATE_ENTITY
    redefinition .
  methods SICFSERVICESET_GET_ENTITYSET
    redefinition .
  methods USERGETLISTSET_GET_ENTITY
    redefinition .
  methods USERGETLISTSET_GET_ENTITYSET
    redefinition .
  methods USERGETSESSIONSE_GET_ENTITYSET
    redefinition .
  methods USERLOCKSET_UPDATE_ENTITY
    redefinition .
  methods USERSESSIONKILLS_UPDATE_ENTITY
    redefinition .
  methods USERUNLOCKSET_UPDATE_ENTITY
    redefinition .
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_ZGW_BASIS_ODATA_DPC_EXT IMPLEMENTATION.


  method /IWBEP/IF_MGW_APPL_SRV_RUNTIME~CHANGESET_BEGIN.
*    CV_DEFER_MODE = 'X'.
**TRY.
*CALL METHOD SUPER->/IWBEP/IF_MGW_APPL_SRV_RUNTIME~CHANGESET_BEGIN
*  EXPORTING
*    IT_OPERATION_INFO =
**  CHANGING
**    cv_defer_mode     =
*    .
** CATCH /iwbep/cx_mgw_busi_exception .
** CATCH /iwbep/cx_mgw_tech_exception .
**ENDTRY.
  endmethod.


  method /IWBEP/IF_MGW_APPL_SRV_RUNTIME~CHANGESET_END.

**TRY.
*CALL METHOD SUPER->/IWBEP/IF_MGW_APPL_SRV_RUNTIME~CHANGESET_END
*    .
** CATCH /iwbep/cx_mgw_busi_exception .
** CATCH /iwbep/cx_mgw_tech_exception .
**ENDTRY.
  endmethod.


  method /IWBEP/IF_MGW_APPL_SRV_RUNTIME~CHANGESET_PROCESS.
**TRY.
*CALL METHOD SUPER->/IWBEP/IF_MGW_APPL_SRV_RUNTIME~CHANGESET_PROCESS
*  EXPORTING
*    IT_CHANGESET_REQUEST  =
*  CHANGING
*    CT_CHANGESET_RESPONSE =
*    .
** CATCH /iwbep/cx_mgw_busi_exception .
** CATCH /iwbep/cx_mgw_tech_exception .
**ENDTRY.
  endmethod.


  METHOD dbbackupreptset_get_entityset.
    DATA: lo_message_container TYPE REF TO /iwbep/if_message_container.
    DATA: ex_msgtype TYPE bapi_mtype.
    DATA: wa_key_tab TYPE /iwbep/s_mgw_name_value_pair.
    DATA: l_srvname TYPE icfaltnme.

    DATA: res_tab TYPE zdb_fm_struc_tt,
          res_tab_wa TYPE zdb_fm_struc,
          final_tab_wa TYPE zcl_zgw_basis_odata_mpc=>ts_dbbackuprept.

    DATA: wa_filter_opt TYPE /iwbep/s_mgw_select_option,
          wa_sel_opt TYPE /iwbep/s_cod_select_option.

    DATA: l_date TYPE sy-datum,
          l_today TYPE flag,
          l_weekly TYPE flag,
          l_monthly TYPE flag.

    lo_message_container = me->mo_context->get_message_container( ).

    CLEAR: wa_filter_opt, wa_sel_opt.
    READ TABLE it_filter_select_options INTO wa_filter_opt WITH KEY property = 'Date'.
    IF sy-subrc EQ 0.
      READ TABLE wa_filter_opt-select_options INTO wa_sel_opt INDEX 1.
      IF sy-subrc EQ 0.
        l_date = wa_sel_opt-low.
      ENDIF.
    ENDIF.

    CLEAR: wa_filter_opt, wa_sel_opt.
    READ TABLE it_filter_select_options INTO wa_filter_opt WITH KEY property = 'Today'.
    IF sy-subrc EQ 0.
      READ TABLE wa_filter_opt-select_options INTO wa_sel_opt INDEX 1.
      IF sy-subrc EQ 0.
        l_today = wa_sel_opt-low.
      ENDIF.
    ENDIF.

    CLEAR: wa_filter_opt, wa_sel_opt.
    READ TABLE it_filter_select_options INTO wa_filter_opt WITH KEY property = 'Weekly'.
    IF sy-subrc EQ 0.
      READ TABLE wa_filter_opt-select_options INTO wa_sel_opt INDEX 1.
      IF sy-subrc EQ 0.
        l_weekly = wa_sel_opt-low.
      ENDIF.
    ENDIF.

    CLEAR: wa_filter_opt, wa_sel_opt.
    READ TABLE it_filter_select_options INTO wa_filter_opt WITH KEY property = 'Monthly'.
    IF sy-subrc EQ 0.
      READ TABLE wa_filter_opt-select_options INTO wa_sel_opt INDEX 1.
      IF sy-subrc EQ 0.
        l_monthly = wa_sel_opt-low.
      ENDIF.
    ENDIF.


    CALL FUNCTION 'ZFM_DB_BACKUP_REPORT_V3'
      EXPORTING
        date             = l_date
        today            = l_today
        weekly           = l_weekly
        monthly          = l_monthly
      IMPORTING
        result_tab       = res_tab
      EXCEPTIONS
        no_entries_found = 1
        OTHERS           = 2.

    IF sy-subrc EQ 0.
      LOOP AT res_tab INTO res_tab_wa.
        MOVE-CORRESPONDING res_tab_wa TO final_tab_wa.
        final_tab_wa-date = l_date.
        final_tab_wa-today = l_today.
        final_tab_wa-weekly = l_weekly.
        final_tab_wa-monthly = l_monthly.

        IF final_tab_wa-start_date EQ ''.
          final_tab_wa-start_date = '00000000'.
        ENDIF.
        IF final_tab_wa-start_time EQ ''.
          final_tab_wa-start_time = '000000'.
        ENDIF.
        APPEND final_tab_wa TO et_entityset.
      ENDLOOP.
    ELSEIF sy-subrc EQ 1.
      ex_msgtype = 'E'.
      lo_message_container->add_message_text_only(
        EXPORTING
          iv_msg_type               = ex_msgtype    " Message Type - defined by GCS_MESSAGE_TYPE
          iv_msg_text               = 'No entries found'    " Message Text
           iv_add_to_response_header = abap_true    " Flag for adding or not the message to the response header
      ).

      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          textid            = /iwbep/cx_mgw_busi_exception=>business_error
          message_container = lo_message_container.
    ELSEIF sy-subrc EQ 2.
      ex_msgtype = 'E'.
      lo_message_container->add_message_text_only(
        EXPORTING
          iv_msg_type               = ex_msgtype    " Message Type - defined by GCS_MESSAGE_TYPE
          iv_msg_text               = 'Unknown error'    " Message Text
           iv_add_to_response_header = abap_true    " Flag for adding or not the message to the response header
      ).

      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          textid            = /iwbep/cx_mgw_busi_exception=>business_error
          message_container = lo_message_container.
    ENDIF.
  ENDMETHOD.                    "dbbackupreptset_get_entityset


  METHOD itodataservset_get_entity.
    DATA: gt_final TYPE zbt_odata_serv.
    DATA: lo_message_container TYPE REF TO /iwbep/if_message_container.
    DATA: ex_msgtype TYPE bapi_mtype.

    lo_message_container = me->mo_context->get_message_container( ).

    CALL FUNCTION 'ZBS_ODATA_SERVNAME'
      TABLES
        it_odata_serv = gt_final
      EXCEPTIONS
        no_data_found = 1
        OTHERS        = 2.
    IF sy-subrc EQ 0.
      READ TABLE gt_final INTO er_entity WITH KEY serv_key = '0001'.
*      et_entityset[] = gt_final[].
    ELSEIF sy-subrc EQ 1 OR gt_final[] IS INITIAL.
      ex_msgtype = 'E'.
      lo_message_container->add_message_text_only(
        EXPORTING
          iv_msg_type               = ex_msgtype    " Message Type - defined by GCS_MESSAGE_TYPE
          iv_msg_text               = 'No Services Available'    " Message Text
           iv_add_to_response_header = abap_true    " Flag for adding or not the message to the response header
      ).

      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          textid            = /iwbep/cx_mgw_busi_exception=>business_error
          message_container = lo_message_container.
    ELSEIF sy-subrc EQ 2.
      ex_msgtype = 'E'.
      lo_message_container->add_message_text_only(
        EXPORTING
          iv_msg_type               = ex_msgtype    " Message Type - defined by GCS_MESSAGE_TYPE
          iv_msg_text               = 'Unknown Error'    " Message Text
           iv_add_to_response_header = abap_true    " Flag for adding or not the message to the response header
      ).

      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          textid            = /iwbep/cx_mgw_busi_exception=>business_error
          message_container = lo_message_container.
    ENDIF.
  ENDMETHOD.


  METHOD itodataservset_get_entityset.
    DATA: gt_final TYPE zbt_odata_serv.
    DATA: lo_message_container TYPE REF TO /iwbep/if_message_container.
    DATA: ex_msgtype TYPE bapi_mtype.

    lo_message_container = me->mo_context->get_message_container( ).

    CALL FUNCTION 'ZBS_ODATA_SERVNAME'
      TABLES
        it_odata_serv = gt_final
      EXCEPTIONS
        no_data_found = 1
        OTHERS        = 2.
    IF sy-subrc EQ 0.
      et_entityset[] = gt_final[].
    ELSEIF sy-subrc EQ 1 OR gt_final[] IS INITIAL.
      ex_msgtype = 'E'.
      lo_message_container->add_message_text_only(
        EXPORTING
          iv_msg_type               = ex_msgtype    " Message Type - defined by GCS_MESSAGE_TYPE
          iv_msg_text               = 'No Services Available'    " Message Text
           iv_add_to_response_header = abap_true    " Flag for adding or not the message to the response header
      ).

      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          textid            = /iwbep/cx_mgw_busi_exception=>business_error
          message_container = lo_message_container.
    ELSEIF sy-subrc EQ 2.
      ex_msgtype = 'E'.
      lo_message_container->add_message_text_only(
        EXPORTING
          iv_msg_type               = ex_msgtype    " Message Type - defined by GCS_MESSAGE_TYPE
          iv_msg_text               = 'Unknown Error'    " Message Text
           iv_add_to_response_header = abap_true    " Flag for adding or not the message to the response header
      ).

      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          textid            = /iwbep/cx_mgw_busi_exception=>business_error
          message_container = lo_message_container.
    ENDIF.
  ENDMETHOD.                    "ITODATASERVSET_GET_ENTITYSET


  METHOD servactdeactset_update_entity.
    DATA: wa_serv_line TYPE zcl_zgw_basis_odata_mpc=>ts_servactdeact.
    DATA: lo_message_container TYPE REF TO /iwbep/if_message_container.
    DATA: ex_msgtype TYPE bapi_mtype.
    DATA: l_msg_text TYPE bapi_msg.
    DATA: e_return TYPE icfinstact.
    DATA: ls_header TYPE ihttpnvp.
    DATA: l_subrc TYPE sy-subrc.

    lo_message_container = me->mo_context->get_message_container( ).
    TRY.
        io_data_provider->read_entry_data(
           IMPORTING
             es_data = wa_serv_line
        ).
      CATCH /iwbep/cx_mgw_tech_exception.    " Technical Exception
        ex_msgtype = 'E'.
        lo_message_container->add_message_text_only(
          EXPORTING
            iv_msg_type               = ex_msgtype    " Message Type - defined by GCS_MESSAGE_TYPE
            iv_msg_text               = 'Unknown technical error'    " Message Text
             iv_add_to_response_header = abap_true    " Flag for adding or not the message to the response header
        ).

        RAISE EXCEPTION TYPE /iwbep/cx_mgw_tech_exception
          EXPORTING
            textid            = /iwbep/cx_mgw_busi_exception=>business_error
            message_container = lo_message_container.
    ENDTRY.

    IF wa_serv_line-iv_activate IS INITIAL AND wa_serv_line-iv_deactivate IS INITIAL.
      ex_msgtype = 'E'.
      lo_message_container->add_message_text_only(
        EXPORTING
          iv_msg_type               = ex_msgtype    " Message Type - defined by GCS_MESSAGE_TYPE
          iv_msg_text               = 'Activation/Deactivation Flag both Null'    " Message Text
           iv_add_to_response_header = abap_true    " Flag for adding or not the message to the response header
      ).

      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          textid            = /iwbep/cx_mgw_busi_exception=>business_error
          message_container = lo_message_container.
    ELSEIF wa_serv_line-iv_activate IS NOT INITIAL AND wa_serv_line-iv_deactivate IS NOT INITIAL.
      ex_msgtype = 'E'.
      lo_message_container->add_message_text_only(
        EXPORTING
          iv_msg_type               = ex_msgtype    " Message Type - defined by GCS_MESSAGE_TYPE
          iv_msg_text               = 'Activation/Deactivation Flag both Set'    " Message Text
           iv_add_to_response_header = abap_true    " Flag for adding or not the message to the response header
      ).

      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          textid            = /iwbep/cx_mgw_busi_exception=>business_error
          message_container = lo_message_container.
    ELSE.
      CALL FUNCTION 'ZSICF_SERVICE_ACTIVATION_V3'
        EXPORTING
          icf_serv                 = wa_serv_line-icf_serv
          s_path                   = wa_serv_line-s_path
          iv_activate              = wa_serv_line-iv_activate
          iv_deactivate            = wa_serv_line-iv_deactivate
        IMPORTING
          es_int_icfinstact        = e_return
        EXCEPTIONS
          node_not_existing        = 1
          enqueue_error            = 2
          no_authority             = 3
          url_and_nodeguid_space   = 4
          url_and_nodeguid_fill_in = 5
          no_input_available       = 6
          already_active           = 7
          OTHERS                   = 8.

      l_subrc = sy-subrc.
      CASE l_subrc.
        WHEN 0.
          ex_msgtype = 'S'.
          IF wa_serv_line-iv_activate IS NOT INITIAL.
            l_msg_text = 'Service successfully activated'.
          ELSEIF wa_serv_line-iv_deactivate IS NOT INITIAL.
            l_msg_text = 'Service successfully de-activated'.
          ENDIF.

          ls_header-name = 'success-message' .
          ls_header-value = l_msg_text.
          /iwbep/if_mgw_conv_srv_runtime~set_header( ls_header ).
        WHEN 1.
          ex_msgtype = 'E'.
          lo_message_container->add_message_text_only(
            EXPORTING
              iv_msg_type               = ex_msgtype    " Message Type - defined by GCS_MESSAGE_TYPE
              iv_msg_text               = 'Service not available'    " Message Text
               iv_add_to_response_header = abap_true    " Flag for adding or not the message to the response header
          ).
        WHEN 2.
          ex_msgtype = 'E'.
          lo_message_container->add_message_text_only(
            EXPORTING
              iv_msg_type               = ex_msgtype    " Message Type - defined by GCS_MESSAGE_TYPE
              iv_msg_text               = 'Lock error'    " Message Text
               iv_add_to_response_header = abap_true    " Flag for adding or not the message to the response header
          ).
        WHEN 3.
          ex_msgtype = 'E'.
          lo_message_container->add_message_text_only(
            EXPORTING
              iv_msg_type               = ex_msgtype    " Message Type - defined by GCS_MESSAGE_TYPE
              iv_msg_text               = 'No authorization'    " Message Text
               iv_add_to_response_header = abap_true    " Flag for adding or not the message to the response header
          ).
        WHEN 4.
          ex_msgtype = 'E'.
          lo_message_container->add_message_text_only(
            EXPORTING
              iv_msg_type               = ex_msgtype    " Message Type - defined by GCS_MESSAGE_TYPE
              iv_msg_text               = 'URL incorrect'    " Message Text
               iv_add_to_response_header = abap_true    " Flag for adding or not the message to the response header
          ).
        WHEN 5.
          ex_msgtype = 'E'.
          lo_message_container->add_message_text_only(
            EXPORTING
              iv_msg_type               = ex_msgtype    " Message Type - defined by GCS_MESSAGE_TYPE
              iv_msg_text               = 'URL inconsistency. Activate URL manually'    " Message Text
               iv_add_to_response_header = abap_true    " Flag for adding or not the message to the response header
          ).
        WHEN 6.
          ex_msgtype = 'E'.
          lo_message_container->add_message_text_only(
            EXPORTING
              iv_msg_type               = ex_msgtype    " Message Type - defined by GCS_MESSAGE_TYPE
              iv_msg_text               = 'No input is available'    " Message Text
               iv_add_to_response_header = abap_true    " Flag for adding or not the message to the response header
          ).
        WHEN 7.
          ex_msgtype = 'E'.
          lo_message_container->add_message_text_only(
            EXPORTING
              iv_msg_type               = ex_msgtype    " Message Type - defined by GCS_MESSAGE_TYPE
              iv_msg_text               = 'Selected Service is already in Active Status'    " Message Text
               iv_add_to_response_header = abap_true    " Flag for adding or not the message to the response header
          ).
        WHEN 8.
          ex_msgtype = 'E'.
          lo_message_container->add_message_text_only(
            EXPORTING
              iv_msg_type               = ex_msgtype    " Message Type - defined by GCS_MESSAGE_TYPE
              iv_msg_text               = 'Unknown Error'    " Message Text
               iv_add_to_response_header = abap_true    " Flag for adding or not the message to the response header
          ).
        WHEN OTHERS.
      ENDCASE.

      IF l_subrc <> 0.
        RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
          EXPORTING
            textid            = /iwbep/cx_mgw_busi_exception=>business_error
            message_container = lo_message_container.
      ENDIF.
    ENDIF.
  ENDMETHOD.                    "servactdeactset_update_entity


  METHOD sicfserviceset_get_entityset.
    DATA: lo_message_container TYPE REF TO /iwbep/if_message_container.
    DATA: ex_msgtype TYPE bapi_mtype.
    DATA: wa_entityset TYPE zcl_zgw_basis_odata_mpc=>ts_sicfservice.

    DATA: wa_filter_opt TYPE /iwbep/s_mgw_select_option,
          wa_sel_opt TYPE /iwbep/s_cod_select_option.

    DATA: lv_top   TYPE zgw_rec_count,
          lv_skip  TYPE zgw_rec_count,
          lv_max_row TYPE zgw_rec_count,
          lv_total_rec_count TYPE zgw_rec_count,
          l_paging TYPE /iwbep/s_mgw_paging.

    DATA: l_rootnode TYPE icfname,
          l_string TYPE string,
          lv_flag TYPE icfaliflag.

    DATA: et_serv_table TYPE zgw_sicflist_tt,
          es_serv_table TYPE zgw_sicflist.

    lo_message_container = me->mo_context->get_message_container( ).

    CLEAR: wa_filter_opt, wa_sel_opt.
    READ TABLE it_filter_select_options INTO wa_filter_opt WITH KEY property = 'IvRootNode'.
    IF sy-subrc EQ 0.
      READ TABLE wa_filter_opt-select_options INTO wa_sel_opt INDEX 1.
      IF sy-subrc EQ 0.
        l_rootnode = wa_sel_opt-low.
      ENDIF.
    ENDIF.

    CLEAR: wa_filter_opt, wa_sel_opt.
    READ TABLE it_filter_select_options INTO wa_filter_opt WITH KEY property = 'IvString'.
    IF sy-subrc EQ 0.
      READ TABLE wa_filter_opt-select_options INTO wa_sel_opt INDEX 1.
      IF sy-subrc EQ 0.
        l_string = wa_sel_opt-low.
      ENDIF.
    ENDIF.

    lv_top = io_tech_request_context->get_top( ).
    lv_skip = io_tech_request_context->get_skip( ).
    lv_max_row = lv_top + lv_skip.

    IF l_string IS INITIAL.
      lv_flag = 1.
    ELSE.
      lv_flag = 2.
    ENDIF.

    CALL FUNCTION 'ZSICF_SERVICE_DETAIL_V3'
      EXPORTING
        iv_root_node     = l_rootnode
        iv_flag          = lv_flag
        iv_count         = lv_max_row
        iv_string        = l_string
      IMPORTING
        ie_line_count    = lv_total_rec_count
        et_return_serv   = et_serv_table
      EXCEPTIONS
        no_entries_found = 1
        OTHERS           = 2.

    CASE sy-subrc.
      WHEN 0.
        LOOP AT et_serv_table INTO es_serv_table.
          wa_entityset-iv_root_node = l_rootnode.
          wa_entityset-iv_string = l_string.
          MOVE-CORRESPONDING es_serv_table TO wa_entityset.
          APPEND wa_entityset TO et_entityset.
        ENDLOOP.

        l_paging-top = lv_top.
        l_paging-skip = lv_skip.

        CALL METHOD /iwbep/cl_mgw_data_util=>paging
          EXPORTING
            is_paging = l_paging
          CHANGING
            ct_data   = et_entityset.

        IF io_tech_request_context->has_inlinecount( ) = abap_true.
          es_response_context-inlinecount = lv_total_rec_count.
        ENDIF.
*      WHEN 1.
*        ex_msgtype = 'E'.
*        lo_message_container->add_message_text_only(
*          EXPORTING
*            iv_msg_type               = ex_msgtype    " Message Type - defined by GCS_MESSAGE_TYPE
*            iv_msg_text               = 'No entries found'    " Message Text
*             iv_add_to_response_header = abap_true    " Flag for adding or not the message to the response header
*        ).
*
*        RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
*          EXPORTING
*            textid            = /iwbep/cx_mgw_busi_exception=>business_error
*            message_container = lo_message_container.
      WHEN 2.
        ex_msgtype = 'E'.
        lo_message_container->add_message_text_only(
          EXPORTING
            iv_msg_type               = ex_msgtype    " Message Type - defined by GCS_MESSAGE_TYPE
            iv_msg_text               = 'Unknwon error'    " Message Text
             iv_add_to_response_header = abap_true    " Flag for adding or not the message to the response header
        ).

        RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
          EXPORTING
            textid            = /iwbep/cx_mgw_busi_exception=>business_error
            message_container = lo_message_container.
      WHEN OTHERS.
    ENDCASE.
  ENDMETHOD.                    "sicfserviceset_get_entityset


  METHOD usergetlistset_get_entity.
    DATA: lo_message_container TYPE REF TO /iwbep/if_message_container.
    DATA: wa_key_tab TYPE /iwbep/s_mgw_name_value_pair.
    DATA: et_entityset TYPE zcl_zgw_basis_odata_mpc=>tt_usergetlist.
    DATA: ex_msgtype TYPE bapi_mtype.

    DATA: wa_filter_opt TYPE /iwbep/s_mgw_select_option,
          wa_sel_opt TYPE /iwbep/s_cod_select_option.

    DATA: l_filter TYPE zgw_user_master_rec,
          lv_top   TYPE zgw_rec_count,
          lv_skip  TYPE zgw_rec_count,
          lv_max_row TYPE zgw_rec_count,
          lv_total_rec_count TYPE zgw_rec_count,
          l_paging TYPE /iwbep/s_mgw_paging.


    lo_message_container = me->mo_context->get_message_container( ).
    READ TABLE it_key_tab INTO wa_key_tab WITH KEY name = 'Bname'.
    IF sy-subrc EQ 0.
      l_filter-bname = wa_key_tab-value.
    ENDIF.

    CALL FUNCTION 'ZGW_USERS_GET'
      EXPORTING
        im_rec_count     = 1
        im_filter_data   = l_filter
      TABLES
        result_list      = et_entityset
      EXCEPTIONS
        no_entries_found = 1
        packet_size_zero = 2
        OTHERS           = 3.

    CASE sy-subrc.
      WHEN 0.
        READ TABLE et_entityset INTO er_entity INDEX 1.
      WHEN 1.
        ex_msgtype = 'E'.
        lo_message_container->add_message_text_only(
          EXPORTING
            iv_msg_type               = ex_msgtype    " Message Type - defined by GCS_MESSAGE_TYPE
            iv_msg_text               = 'No entries found'    " Message Text
             iv_add_to_response_header = abap_true    " Flag for adding or not the message to the response header
        ).

        RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
          EXPORTING
            textid            = /iwbep/cx_mgw_busi_exception=>business_error
            message_container = lo_message_container.
      WHEN 2.
        ex_msgtype = 'E'.
        lo_message_container->add_message_text_only(
          EXPORTING
            iv_msg_type               = ex_msgtype    " Message Type - defined by GCS_MESSAGE_TYPE
            iv_msg_text               = 'Packet size cannot be zero'    " Message Text
             iv_add_to_response_header = abap_true    " Flag for adding or not the message to the response header
        ).

        RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
          EXPORTING
            textid            = /iwbep/cx_mgw_busi_exception=>business_error
            message_container = lo_message_container.
      WHEN OTHERS.
    ENDCASE.
  ENDMETHOD.                    "usergetlistset_get_entity


  METHOD usergetlistset_get_entityset.
    DATA: lo_message_container TYPE REF TO /iwbep/if_message_container.
    DATA: ex_msgtype TYPE bapi_mtype.

    DATA: wa_filter_opt TYPE /iwbep/s_mgw_select_option,
          wa_sel_opt    TYPE /iwbep/s_cod_select_option.

    DATA: l_filter           TYPE zgw_user_master_rec,
          lv_top             TYPE zgw_rec_count,
          lv_skip            TYPE zgw_rec_count,
          lv_max_row         TYPE zgw_rec_count,
          lv_total_rec_count TYPE zgw_rec_count,
          l_paging           TYPE /iwbep/s_mgw_paging.


    lo_message_container = me->mo_context->get_message_container( ).
    CLEAR: wa_filter_opt, wa_sel_opt.
    READ TABLE it_filter_select_options INTO wa_filter_opt WITH KEY property = 'Bname'.
    IF sy-subrc EQ 0.
      READ TABLE wa_filter_opt-select_options INTO wa_sel_opt INDEX 1.
      IF sy-subrc EQ 0.
        l_filter-bname = wa_sel_opt-low.
        TRANSLATE l_filter-bname TO UPPER CASE.
      ENDIF.
    ENDIF.

    CLEAR: wa_filter_opt, wa_sel_opt.
    READ TABLE it_filter_select_options INTO wa_filter_opt WITH KEY property = 'Class'.
    IF sy-subrc EQ 0.
      READ TABLE wa_filter_opt-select_options INTO wa_sel_opt INDEX 1.
      IF sy-subrc EQ 0.
        l_filter-class = wa_sel_opt-low.
      ENDIF.
    ENDIF.

    CLEAR: wa_filter_opt, wa_sel_opt.
    READ TABLE it_filter_select_options INTO wa_filter_opt WITH KEY property = 'Gltgb'.
    IF sy-subrc EQ 0.
      READ TABLE wa_filter_opt-select_options INTO wa_sel_opt INDEX 1.
      IF sy-subrc EQ 0.
        l_filter-gltgb = wa_sel_opt-low.
      ENDIF.
    ENDIF.

    CLEAR: wa_filter_opt, wa_sel_opt.
    READ TABLE it_filter_select_options INTO wa_filter_opt WITH KEY property = 'Kostl'.
    IF sy-subrc EQ 0.
      READ TABLE wa_filter_opt-select_options INTO wa_sel_opt INDEX 1.
      IF sy-subrc EQ 0.
        l_filter-kostl = wa_sel_opt-low.
      ENDIF.
    ENDIF.

    CLEAR: wa_filter_opt, wa_sel_opt.
    READ TABLE it_filter_select_options INTO wa_filter_opt WITH KEY property = 'Uflag'.
    IF sy-subrc EQ 0.
      READ TABLE wa_filter_opt-select_options INTO wa_sel_opt INDEX 1.
      IF sy-subrc EQ 0.
        l_filter-uflag = wa_sel_opt-low.
      ENDIF.
    ENDIF.


    lv_top = io_tech_request_context->get_top( ).
    lv_skip = io_tech_request_context->get_skip( ).
    lv_max_row = lv_top + lv_skip.

    CALL FUNCTION 'ZGW_USERS_GET'
      EXPORTING
        im_rec_count     = lv_max_row
        im_filter_data   = l_filter
      IMPORTING
        ex_packet_count  = lv_total_rec_count
      TABLES
        result_list      = et_entityset
      EXCEPTIONS
        no_entries_found = 1
        packet_size_zero = 2
        OTHERS           = 3.

    CASE sy-subrc.
      WHEN 0.
        l_paging-top = lv_top.
        l_paging-skip = lv_skip.

        CALL METHOD /iwbep/cl_mgw_data_util=>paging
          EXPORTING
            is_paging = l_paging
          CHANGING
            ct_data   = et_entityset.

        IF io_tech_request_context->has_inlinecount( ) = abap_true.
          es_response_context-inlinecount = lv_total_rec_count.
        ENDIF.
*      WHEN 1.
*        ex_msgtype = 'E'.
*        lo_message_container->add_message_text_only(
*          EXPORTING
*            iv_msg_type               = ex_msgtype    " Message Type - defined by GCS_MESSAGE_TYPE
*            iv_msg_text               = 'No entries found'    " Message Text
*             iv_add_to_response_header = abap_true    " Flag for adding or not the message to the response header
*        ).
*
*        RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
*          EXPORTING
*            textid            = /iwbep/cx_mgw_busi_exception=>business_error
*            message_container = lo_message_container.
      WHEN 2.
        ex_msgtype = 'E'.
        lo_message_container->add_message_text_only(
          EXPORTING
            iv_msg_type               = ex_msgtype    " Message Type - defined by GCS_MESSAGE_TYPE
            iv_msg_text               = 'Packet size cannot be zero'    " Message Text
             iv_add_to_response_header = abap_true    " Flag for adding or not the message to the response header
        ).

        RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
          EXPORTING
            textid            = /iwbep/cx_mgw_busi_exception=>business_error
            message_container = lo_message_container.
      WHEN OTHERS.
    ENDCASE.
  ENDMETHOD.                    "usergetlistset_get_entityset


  METHOD usergetsessionse_get_entityset.
    DATA: lo_message_container TYPE REF TO /iwbep/if_message_container.
    DATA: ex_msgtype TYPE bapi_mtype.

    DATA: wa_filter_opt TYPE /iwbep/s_mgw_select_option,
          wa_sel_opt TYPE /iwbep/s_cod_select_option.

    DATA: l_username TYPE xubname.

    lo_message_container = me->mo_context->get_message_container( ).

    CLEAR: wa_filter_opt, wa_sel_opt.
    READ TABLE it_filter_select_options INTO wa_filter_opt WITH KEY property = 'Username'.
    IF sy-subrc EQ 0.
      READ TABLE wa_filter_opt-select_options INTO wa_sel_opt INDEX 1.
      IF sy-subrc EQ 0.
        l_username = wa_sel_opt-low.
      ENDIF.
    ENDIF.

    CALL FUNCTION 'ZGET_USERSESS_V3'
      EXPORTING
        im_username   = l_username
      IMPORTING
        et_usersess   = et_entityset
      EXCEPTIONS
        noopensession = 1
        enterusername = 2
        OTHERS        = 3.

    CASE sy-subrc.
      WHEN 0.
      WHEN 1.
        ex_msgtype = 'E'.
        lo_message_container->add_message_text_only(
          EXPORTING
            iv_msg_type               = ex_msgtype    " Message Type - defined by GCS_MESSAGE_TYPE
            iv_msg_text               = 'No open session'    " Message Text
             iv_add_to_response_header = abap_true    " Flag for adding or not the message to the response header
        ).

        RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
          EXPORTING
            textid            = /iwbep/cx_mgw_busi_exception=>business_error
            message_container = lo_message_container.
      WHEN 2.
        ex_msgtype = 'E'.
        lo_message_container->add_message_text_only(
          EXPORTING
            iv_msg_type               = ex_msgtype    " Message Type - defined by GCS_MESSAGE_TYPE
            iv_msg_text               = 'Username not entered'    " Message Text
             iv_add_to_response_header = abap_true    " Flag for adding or not the message to the response header
        ).

        RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
          EXPORTING
            textid            = /iwbep/cx_mgw_busi_exception=>business_error
            message_container = lo_message_container.
      WHEN OTHERS.
    ENDCASE.
  ENDMETHOD.                    "usergetsessionse_get_entityset


  METHOD userlockset_update_entity.
    DATA: wa_userlock TYPE zcl_zgw_basis_odata_mpc=>ts_userlock.
    DATA: lo_message_container TYPE REF TO /iwbep/if_message_container.
    DATA: ex_msgtype TYPE bapi_mtype.
    DATA: l_msg_text TYPE bapi_msg.
    DATA: e_return TYPE icfinstact.
    DATA: ls_header TYPE ihttpnvp.
    DATA: l_uname TYPE sy-uname.
    DATA: l_subrc TYPE sy-subrc.

    lo_message_container = me->mo_context->get_message_container( ).
    TRY.
        io_data_provider->read_entry_data(
           IMPORTING
             es_data = wa_userlock
        ).
      CATCH /iwbep/cx_mgw_tech_exception.    " Technical Exception
        ex_msgtype = 'E'.
        lo_message_container->add_message_text_only(
          EXPORTING
            iv_msg_type               = ex_msgtype    " Message Type - defined by GCS_MESSAGE_TYPE
            iv_msg_text               = 'Unknown technical error'    " Message Text
             iv_add_to_response_header = abap_true    " Flag for adding or not the message to the response header
        ).

        RAISE EXCEPTION TYPE /iwbep/cx_mgw_tech_exception
          EXPORTING
            textid            = /iwbep/cx_mgw_busi_exception=>business_error
            message_container = lo_message_container.
    ENDTRY.

    l_uname = wa_userlock-im_username.
    TRANSLATE l_uname TO UPPER CASE.

*    CALL FUNCTION 'Z_ECCERP_LOCK_USER_V3'
*      EXPORTING
*        im_username = l_uname
*      IMPORTING
*        ex_msgtype  = ex_msgtype
*        ex_msgname  = l_msg_text.

    CALL FUNCTION 'ZZSUSR_RFC_USER_INTERFACE'
      EXPORTING
        user                 = l_uname
        activity             = '05'
        user_type            = 'A'
      IMPORTING
        ex_msgtype           = ex_msgtype
        ex_msgname           = l_msg_text
      EXCEPTIONS
        user_dont_exist      = 1
        user_allready_exists = 2
        not_authorized       = 3
        username_required    = 4
        bad_method           = 5
        password_required    = 6
        usergroup_dont_exist = 7
        bad_time_rage        = 8
        bad_usertype         = 9
        update_error         = 10
        OTHERS               = 11.

    CASE ex_msgtype.
      WHEN 'S'.
        ls_header-name = 'success-message' .
        ls_header-value = l_msg_text.
        /iwbep/if_mgw_conv_srv_runtime~set_header( ls_header ).
      WHEN 'E'.
        lo_message_container->add_message_text_only(
          EXPORTING
            iv_msg_type               = ex_msgtype    " Message Type - defined by GCS_MESSAGE_TYPE
            iv_msg_text               = l_msg_text    " Message Text
             iv_add_to_response_header = abap_true    " Flag for adding or not the message to the response header
        ).

        RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
          EXPORTING
            textid            = /iwbep/cx_mgw_busi_exception=>business_error
            message_container = lo_message_container.

    ENDCASE.
  ENDMETHOD.                    "USERLOCKSET_UPDATE_ENTITY


  METHOD usersessionkills_update_entity.
    DATA: wa_usersess TYPE zcl_zgw_basis_odata_mpc=>ts_usersessionkill.
    DATA: lo_message_container TYPE REF TO /iwbep/if_message_container.
    DATA: ex_msgtype TYPE bapi_mtype.
    DATA: l_msg_text TYPE bapi_msg.
    DATA: e_return TYPE icfinstact.
    DATA: ls_header TYPE ihttpnvp.
    DATA: l_uname TYPE sy-uname.
    DATA: l_subrc TYPE sy-subrc.
    DATA: l_tid TYPE utid.

    lo_message_container = me->mo_context->get_message_container( ).
    TRY.
        io_data_provider->read_entry_data(
           IMPORTING
             es_data = wa_usersess
        ).
      CATCH /iwbep/cx_mgw_tech_exception.    " Technical Exception
        ex_msgtype = 'E'.
        lo_message_container->add_message_text_only(
          EXPORTING
            iv_msg_type               = ex_msgtype    " Message Type - defined by GCS_MESSAGE_TYPE
            iv_msg_text               = 'Unknown technical error'    " Message Text
             iv_add_to_response_header = abap_true    " Flag for adding or not the message to the response header
        ).

        RAISE EXCEPTION TYPE /iwbep/cx_mgw_tech_exception
          EXPORTING
            textid            = /iwbep/cx_mgw_busi_exception=>business_error
            message_container = lo_message_container.
    ENDTRY.

    TRANSLATE wa_usersess-im_username TO UPPER CASE.
    CALL FUNCTION 'CONVERT_STRING_TO_INTEGER'
      EXPORTING
        p_string      = wa_usersess-im_tid
      IMPORTING
        p_int         = l_tid
      EXCEPTIONS
        overflow      = 1
        invalid_chars = 2
        OTHERS        = 3.
    IF sy-subrc <> 0.
    ENDIF.

    CALL FUNCTION 'ZGW_KILL_USERSESS_V3'
      EXPORTING
        im_client       = wa_usersess-im_client
        im_username     = wa_usersess-im_username
        im_tid          = l_tid
      EXCEPTIONS
        authority_error = 1
        unknown_error   = 2
        OTHERS          = 3.

    CASE sy-subrc.
      WHEN 0.
        ls_header-name = 'success-message' .
        ls_header-value = 'Session successfully killed'.
        /iwbep/if_mgw_conv_srv_runtime~set_header( ls_header ).
      WHEN 1.
        ex_msgtype = 'E'.
        lo_message_container->add_message_text_only(
          EXPORTING
            iv_msg_type               = ex_msgtype    " Message Type - defined by GCS_MESSAGE_TYPE
            iv_msg_text               = 'Authorization error'    " Message Text
             iv_add_to_response_header = abap_true    " Flag for adding or not the message to the response header
        ).

        RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
          EXPORTING
            textid            = /iwbep/cx_mgw_busi_exception=>business_error
            message_container = lo_message_container.
      WHEN 2.
        ex_msgtype = 'E'.
        lo_message_container->add_message_text_only(
          EXPORTING
            iv_msg_type               = ex_msgtype    " Message Type - defined by GCS_MESSAGE_TYPE
            iv_msg_text               = 'Unknown error'    " Message Text
             iv_add_to_response_header = abap_true    " Flag for adding or not the message to the response header
        ).

        RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
          EXPORTING
            textid            = /iwbep/cx_mgw_busi_exception=>business_error
            message_container = lo_message_container.
      WHEN OTHERS.
    ENDCASE.
  ENDMETHOD.                    "usersessionkills_update_entity


  METHOD userunlockset_update_entity.
    DATA: wa_userlock TYPE zcl_zgw_basis_odata_mpc=>ts_userunlock.
    DATA: lo_message_container TYPE REF TO /iwbep/if_message_container.
    DATA: ex_msgtype TYPE bapi_mtype.
    DATA: l_msg_text TYPE bapi_msg.
    DATA: e_return TYPE icfinstact.
    DATA: ls_header TYPE ihttpnvp.
    DATA: l_uname TYPE sy-uname.
    DATA: l_subrc TYPE sy-subrc.

    lo_message_container = me->mo_context->get_message_container( ).
    TRY.
        io_data_provider->read_entry_data(
           IMPORTING
             es_data = wa_userlock
        ).
      CATCH /iwbep/cx_mgw_tech_exception.    " Technical Exception
        ex_msgtype = 'E'.
        lo_message_container->add_message_text_only(
          EXPORTING
            iv_msg_type               = ex_msgtype    " Message Type - defined by GCS_MESSAGE_TYPE
            iv_msg_text               = 'Unknown technical error'    " Message Text
             iv_add_to_response_header = abap_true    " Flag for adding or not the message to the response header
        ).

        RAISE EXCEPTION TYPE /iwbep/cx_mgw_tech_exception
          EXPORTING
            textid            = /iwbep/cx_mgw_busi_exception=>business_error
            message_container = lo_message_container.
    ENDTRY.

    l_uname = wa_userlock-im_username.
    TRANSLATE l_uname TO UPPER CASE.

*    CALL FUNCTION 'Z_ECCERP_UNLOCK_USER_V3'
*      EXPORTING
*        im_username = l_uname
*      IMPORTING
*        ex_msgtype  = ex_msgtype
*        ex_msgname  = l_msg_text.
    CALL FUNCTION 'ZZSUSR_RFC_USER_INTERFACE'
      EXPORTING
        user                 = l_uname
        activity             = '43'
        user_type            = 'A'
      IMPORTING
        ex_msgtype           = ex_msgtype
        ex_msgname           = l_msg_text
      EXCEPTIONS
        user_dont_exist      = 1
        user_allready_exists = 2
        not_authorized       = 3
        username_required    = 4
        bad_method           = 5
        password_required    = 6
        usergroup_dont_exist = 7
        bad_time_rage        = 8
        bad_usertype         = 9
        update_error         = 10
        OTHERS               = 11.

    CASE ex_msgtype.
      WHEN 'S'.
        ls_header-name = 'success-message' .
        ls_header-value = l_msg_text.
        /iwbep/if_mgw_conv_srv_runtime~set_header( ls_header ).
      WHEN 'E'.
        lo_message_container->add_message_text_only(
          EXPORTING
            iv_msg_type               = ex_msgtype    " Message Type - defined by GCS_MESSAGE_TYPE
            iv_msg_text               = l_msg_text    " Message Text
             iv_add_to_response_header = abap_true    " Flag for adding or not the message to the response header
        ).

        RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
          EXPORTING
            textid            = /iwbep/cx_mgw_busi_exception=>business_error
            message_container = lo_message_container.
      WHEN OTHERS.
    ENDCASE.
  ENDMETHOD.                    "userunlockset_update_entity
ENDCLASS.

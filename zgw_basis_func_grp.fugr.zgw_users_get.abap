FUNCTION zgw_users_get.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IM_REC_COUNT) TYPE  ZGW_REC_COUNT
*"     VALUE(IM_FILTER_DATA) TYPE  ZGW_USER_MASTER_REC OPTIONAL
*"  EXPORTING
*"     VALUE(EX_PACKET_COUNT) TYPE  ZGW_REC_COUNT
*"  TABLES
*"      RESULT_LIST STRUCTURE  ZGW_USER_MASTER_REC
*"  EXCEPTIONS
*"      NO_ENTRIES_FOUND
*"      PACKET_SIZE_ZERO
*"----------------------------------------------------------------------

*  TYPES : BEGIN OF ty_user_filter,
*            bname TYPE xubname,
*            class TYPE xuclass,
*            gltgb TYPE xugltgb,
*            uflag TYPE xuuflag,
*             kostl TYPE kostl,
*         END OF ty_user_filter .
*
*  TYPES : BEGIN OF ty_user_ccntre,
*           bname TYPE xubname,
*           kostl TYPE kostl,
*          END OF ty_user_ccntre.



*  DATA : it_user_fltr TYPE STANDARD TABLE OF ZGW_USER_MASTER_REC,
*         wa_user_fltr TYPE ZGW_USER_MASTER_REC
*         it_user_ccntre TYPE STANDARD TABLE OF ty_user_ccntre,
*         wa_user_ccntre TYPE ty_user_ccntre,
*         wa_result_list TYPE zgw_user_master_rec.

  RANGES: r_bname FOR zgw_user_master_rec-bname.
  RANGES: r_class FOR zgw_user_master_rec-class.
  RANGES: r_gltgb FOR zgw_user_master_rec-gltgb.
  RANGES: r_uflag FOR zgw_user_master_rec-uflag.
  RANGES: r_kostl FOR zgw_user_master_rec-kostl.

  IF im_filter_data-bname IS NOT INITIAL .
    r_bname-sign = 'I'.
    r_bname-option = 'EQ'.
    r_bname-low = im_filter_data-bname.
    APPEND r_bname.
  ENDIF.

  IF im_filter_data-class IS NOT INITIAL .
    r_class-sign = 'I'.
    r_class-option = 'EQ'.
    r_class-low = im_filter_data-class.
    APPEND r_class.
  ENDIF.
  IF im_filter_data-gltgb IS NOT INITIAL .
    r_gltgb-sign = 'I'.
    r_gltgb-option = 'EQ'.
    r_gltgb-low = im_filter_data-gltgb.
    APPEND r_gltgb.
  ENDIF.
  IF im_filter_data-uflag IS NOT INITIAL .
    r_uflag-sign = 'I'.
    r_uflag-option = 'EQ'.
    r_uflag-low = im_filter_data-uflag.
    APPEND r_uflag.
  ENDIF.
  IF im_filter_data-kostl IS NOT INITIAL .
    r_kostl-sign = 'I'.
    r_kostl-option = 'EQ'.
    r_kostl-low = im_filter_data-kostl.
    APPEND r_kostl.
  ENDIF.

*  REFRESH : it_user_fltr[].
  IF  r_kostl[] IS NOT INITIAL .


    SELECT a~bname
           class
           gltgb
           kostl
           uflag
         FROM usr02 AS a INNER JOIN usr03 AS b
          ON a~bname = b~bname INTO TABLE result_list UP TO im_rec_count ROWS
         WHERE a~bname IN r_bname
         AND   class IN r_class
         AND   gltgb IN r_gltgb
         AND   uflag IN r_uflag
         AND  kostl IN r_kostl.
*  SELECT COUNT(*) FROM usr02 INTO ex_packet_count
*       WHERE bname in r_bname
*       AND   class in r_class
*       AND   gltgb in r_gltgb
*       AND   uflag in r_uflag .
    IF result_list IS NOT INITIAL  .
      SELECT COUNT(*)
      FROM usr02 AS a INNER JOIN usr03 AS b
       ON a~bname = b~bname INTO ex_packet_count
      WHERE a~bname IN r_bname
      AND   class IN r_class
      AND   gltgb IN r_gltgb
      AND   uflag IN r_uflag
      AND  kostl IN r_kostl.
    ENDIF.


  ELSE .
    SELECT a~bname
    class
    gltgb
    kostl
    uflag
  FROM usr02 AS a LEFT OUTER JOIN usr03 AS b
   ON a~bname = b~bname INTO TABLE result_list UP TO im_rec_count ROWS
  WHERE a~bname IN r_bname
  AND   class IN r_class
  AND   gltgb IN r_gltgb
  AND   uflag IN r_uflag.

    SELECT COUNT(*)
FROM usr02 AS a LEFT OUTER JOIN usr03 AS b
ON a~bname = b~bname INTO ex_packet_count
WHERE a~bname IN r_bname
AND   class IN r_class
AND   gltgb IN r_gltgb
AND   uflag IN r_uflag.

  ENDIF.


IF  result_list[] IS INITIAL .
 RAISE no_entries_found .
ENDIF.

*  IF  sy-subrc IS INITIAL.
**    SORT it_user_fltr BY bname .
**
**    REFRESH it_user_ccntre[].
**    SELECT bname kostl
**           FROM usr03 INTO TABLE it_user_ccntre
**           FOR ALL ENTRIES IN it_user_fltr
**            WHERE bname = it_user_fltr-bname .
**    IF sy-subrc IS INITIAL .
**      SORT it_user_ccntre BY bname.
**    ENDIF.
*
*    SELECT COUNT(*)
*         FROM usr02 AS a INNER JOIN usr03 AS b
*          ON a~bname = b~bname INTO ex_packet_count
*         WHERE a~bname IN r_bname
*         AND   class IN r_class
*         AND   gltgb IN r_gltgb
*         AND   uflag IN r_uflag
*         AND  kostl IN r_kostl.
*
*  ELSE.
*    RAISE no_entries_found.
*
*  ENDIF.

*  CLEAR : wa_user_fltr, wa_user_ccntre.
*
*  LOOP AT it_user_fltr INTO wa_user_fltr.
*    CLEAR : wa_result_list.
*    wa_result_list-bname = wa_user_fltr-bname.
*    wa_result_list-class = wa_user_fltr-class.
*    wa_result_list-gltgb = wa_user_fltr-gltgb.
*    wa_result_list-uflag = wa_user_fltr-uflag.
*    CLEAR : wa_user_ccntre .
*    READ TABLE it_user_ccntre INTO wa_user_ccntre WITH KEY bname = wa_user_fltr-bname.
*    IF sy-subrc IS INITIAL .
*      wa_result_list-kostl = wa_user_ccntre-kostl.
*    ENDIF.
*    APPEND wa_result_list TO result_list.
*  ENDLOOP.

*  IF result_list IS INITIAL .
*    RAISE no_entries_found.
*  ENDIF.

ENDFUNCTION.

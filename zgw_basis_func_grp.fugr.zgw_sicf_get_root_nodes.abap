FUNCTION zgw_sicf_get_root_nodes.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  TABLES
*"      ET_ROOT_NODES STRUCTURE  ZGW_ROOT_NODE
*"  EXCEPTIONS
*"      NO_ENTRIES_FOUND
*"----------------------------------------------------------------------

  SELECT icf_name FROM icfvirhost INTO TABLE et_root_nodes.
  IF sy-subrc <> 0.
    RAISE no_entries_found.
  ENDIF.
ENDFUNCTION.

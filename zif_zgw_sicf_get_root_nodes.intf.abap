interface ZIF_ZGW_SICF_GET_ROOT_NODES
  public .


  types:
    ICFNAME type C length 000015 .
  types:
    begin of ZGW_ROOT_NODE,
      ICF_NAME type ICFNAME,
    end of ZGW_ROOT_NODE .
  types:
    __ZGW_ROOT_NODE                type standard table of ZGW_ROOT_NODE                  with non-unique default key .
endinterface.

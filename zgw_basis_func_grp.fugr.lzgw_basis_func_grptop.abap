FUNCTION-POOL ZGW_BASIS_FUNC_GRP.           "MESSAGE-ID ..

DATA : it_return        TYPE TABLE OF bapiret2,
       wa_return        TYPE bapiret2,
       it_out_tmp       TYPE TABLE OF bapiret2,
       wa_out_tmp       TYPE bapiret2,
       it_usr           TYPE TABLE OF usr02,
       wa_usr           TYPE usr02,
       wa_bname         TYPE zusrlck,
       it_bname         TYPE TABLE OF zusrlck,
       it_bname1        TYPE TABLE OF zusrlck,
       it_exp           TYPE TABLE OF zusr_exception,
       wa_exp           TYPE zusr_exception,
       r_exp            TYPE RANGE OF bname,
       w_exp            LIKE LINE OF r_exp,
       w_active         TYPE sm04dic-counter.

CONSTANTS : c_x TYPE c VALUE 'X'.
* INCLUDE LZGW_BASIS_FUNC_GRPD...            " Local class definition

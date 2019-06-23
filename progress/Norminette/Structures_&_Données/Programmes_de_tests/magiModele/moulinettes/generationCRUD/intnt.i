/*------------------------------------------------------------------------
File        : intnt.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttIntnt
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdcsy     as character  initial ? 
    field cddev     as character  initial ? 
    field cdmsy     as character  initial ? 
    field cdreg     as character  initial ? 
    field cdtri     as character  initial ? 
    field dtcsy     as date       initial ? 
    field dtmsy     as date       initial ? 
    field edapf     as character  initial ? 
    field FgCrg     as logical    initial ? 
    field fgimprdoc as logical    initial ? 
    field fgmadispo as logical    initial ? 
    field fgpay     as logical    initial ? 
    field hecsy     as integer    initial ? 
    field hemsy     as integer    initial ? 
    field idpre     as integer    initial ? 
    field idsui     as integer    initial ? 
    field lbdiv     as character  initial ? 
    field lbdiv2    as character  initial ? 
    field lbdiv3    as character  initial ? 
    field lipar     as character  initial ? 
    field mtprov    as decimal    initial ?  decimals 2
    field nbden     as integer    initial ? 
    field nbnum     as integer    initial ? 
    field nocon     as int64      initial ? 
    field nocon-dec as decimal    initial ?  decimals 0
    field noidt     as int64      initial ? 
    field noidt-dec as decimal    initial ?  decimals 0
    field tpcon     as character  initial ? 
    field tpidt     as character  initial ? 
    field tpmadisp  as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.

/*------------------------------------------------------------------------
File        : frset.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttFrset
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field anirv     as integer    initial ? 
    field cdcsy     as character  initial ? 
    field cdirv     as integer    initial ? 
    field cdmsy     as character  initial ? 
    field cdprt     as character  initial ? 
    field dtcsy     as date       initial ? 
    field dtmsy     as date       initial ? 
    field dtrev     as date       initial ? 
    field fgfac     as logical    initial ? 
    field fgrev     as logical    initial ? 
    field hecsy     as integer    initial ? 
    field hemsy     as integer    initial ? 
    field infrv     as character  initial ? 
    field lbcpt     as character  initial ? 
    field lbdiv     as character  initial ? 
    field lbdiv2    as character  initial ? 
    field lbdiv3    as character  initial ? 
    field nobud     as int64      initial ? 
    field nobud-dec as decimal    initial ?  decimals 0
    field noexo     as integer    initial ? 
    field noirv     as integer    initial ? 
    field nomdt     as integer    initial ? 
    field noper     as integer    initial ? 
    field tpbud     as character  initial ? 
    field tpmdt     as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.

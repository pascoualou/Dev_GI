/*------------------------------------------------------------------------
File        : ladrs.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttLadrs
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdadr     as character  initial ? 
    field cdcsy     as character  initial ? 
    field cddev     as character  initial ? 
    field cdmsy     as character  initial ? 
    field cdte1     as character  initial ? 
    field cdte2     as character  initial ? 
    field cdte3     as character  initial ? 
    field dtcsy     as date       initial ? 
    field dtdeb     as date       initial ? 
    field dtfin     as date       initial ? 
    field dtmsy     as date       initial ? 
    field hecsy     as integer    initial ? 
    field hemsy     as integer    initial ? 
    field lbdiv     as character  initial ? 
    field lbdiv2    as character  initial ? 
    field lbdiv3    as character  initial ? 
    field noadr     as int64      initial ? 
    field noidt     as int64      initial ? 
    field noidt-dec as decimal    initial ?  decimals 0
    field nolie     as int64      initial ? 
    field note1     as character  initial ? 
    field note2     as character  initial ? 
    field note3     as character  initial ? 
    field novoi     as character  initial ? 
    field tpadr     as character  initial ? 
    field tpfrt     as character  initial ? 
    field tpidt     as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.

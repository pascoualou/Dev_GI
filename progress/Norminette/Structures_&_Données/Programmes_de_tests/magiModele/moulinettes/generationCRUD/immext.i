/*------------------------------------------------------------------------
File        : immext.i
Purpose     : Immeubles externes (0712/0243 - GECINA)
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttImmext
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field activite as character  initial ? 
    field cdcsy    as character  initial ? 
    field cdext    as character  initial ? 
    field cdmsy    as character  initial ? 
    field dtcsy    as date       initial ? 
    field dtmsy    as date       initial ? 
    field hecsy    as integer    initial ? 
    field hemsy    as integer    initial ? 
    field immcli   as character  initial ? 
    field lbdiv    as character  initial ? 
    field lbdiv2   as character  initial ? 
    field lbdiv3   as character  initial ? 
    field lbdiv4   as character  initial ? 
    field lbdiv5   as character  initial ? 
    field lbdiv6   as character  initial ? 
    field noidt    as int64      initial ? 
    field nomimm   as character  initial ? 
    field tpidt    as character  initial ? 
    field tpimm    as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.

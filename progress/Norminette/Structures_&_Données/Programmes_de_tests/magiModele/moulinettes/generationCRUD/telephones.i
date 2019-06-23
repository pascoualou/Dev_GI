/*------------------------------------------------------------------------
File        : telephones.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttTelephones
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field adr-cd    as integer    initial ? 
    field cdcsy     as character  initial ? 
    field cdmsy     as character  initial ? 
    field cdtel     as character  initial ? 
    field dtcsy     as date       initial ? 
    field dtmsy     as date       initial ? 
    field four-cle  as character  initial ? 
    field hecsy     as integer    initial ? 
    field hemsy     as integer    initial ? 
    field lbdiv     as character  initial ? 
    field lbdiv2    as character  initial ? 
    field lbdiv3    as character  initial ? 
    field libadr-cd as integer    initial ? 
    field noidt     as integer    initial ? 
    field nopos     as integer    initial ? 
    field notel     as character  initial ? 
    field numero    as integer    initial ? 
    field soc-cd    as integer    initial ? 
    field tpidt     as character  initial ? 
    field tptel     as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.

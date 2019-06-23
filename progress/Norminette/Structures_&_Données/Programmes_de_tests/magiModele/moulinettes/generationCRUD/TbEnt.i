/*------------------------------------------------------------------------
File        : TbEnt.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttTbent
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdcsy     as character  initial ? 
    field cddev     as character  initial ? 
    field cdent     as character  initial ? 
    field cdmsy     as character  initial ? 
    field dtcsy     as date       initial ? 
    field dten1     as date       initial ? 
    field dten2     as date       initial ? 
    field dtmsy     as date       initial ? 
    field fgen1     as logical    initial ? 
    field fgen2     as logical    initial ? 
    field hecsy     as integer    initial ? 
    field hemsy     as integer    initial ? 
    field iden1     as character  initial ? 
    field iden2     as character  initial ? 
    field lbdiv     as character  initial ? 
    field lbdiv2    as character  initial ? 
    field lbdiv3    as character  initial ? 
    field lben1     as character  initial ? 
    field lben2     as character  initial ? 
    field mten1     as decimal    initial ?  decimals 2
    field mten1-dev as decimal    initial ?  decimals 2
    field mten2     as decimal    initial ?  decimals 2
    field mten2-dev as decimal    initial ?  decimals 2
    field nben1     as int64      initial ? 
    field nben2     as int64      initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.

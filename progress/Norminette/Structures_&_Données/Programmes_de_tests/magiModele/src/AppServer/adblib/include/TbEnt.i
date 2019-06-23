/*------------------------------------------------------------------------
File        : tbent.i
Purpose     : 
Author(s)   : generation automatique le 04/27/18
Notes       :
derniere revue: 2018/05/14 - phm: OK
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
    field dtcsy     as date
    field dten1     as date
    field dten2     as date
    field dtmsy     as date
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
    field mten1     as decimal    initial ? decimals 2
    field mten1-dev as decimal    initial ? decimals 2
    field mten2     as decimal    initial ? decimals 2
    field mten2-dev as decimal    initial ? decimals 2
    field nben1     as int64      initial ?
    field nben2     as int64      initial ?
    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.

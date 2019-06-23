/*------------------------------------------------------------------------
File        : GINETDOC.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttGinetdoc
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field CDCAT  as character  initial ? 
    field cdcsy  as character  initial ? 
    field cdmsy  as character  initial ? 
    field dtcsy  as date       initial ? 
    field dtmsy  as date       initial ? 
    field dttrf  as date       initial ? 
    field fgsup  as logical    initial ? 
    field fgtrf  as logical    initial ? 
    field hecsy  as integer    initial ? 
    field hemsy  as integer    initial ? 
    field lb01   as character  initial ? 
    field lb02   as character  initial ? 
    field lbdiv  as character  initial ? 
    field lbdiv2 as character  initial ? 
    field lbdiv3 as character  initial ? 
    field nocon  as integer    initial ? 
    field noct1  as integer    initial ? 
    field noct2  as integer    initial ? 
    field NODOC  as integer    initial ? 
    field noidt  as integer    initial ? 
    field noimm  as integer    initial ? 
    field noloc  as integer    initial ? 
    field nom    as character  initial ? 
    field nomdt  as integer    initial ? 
    field NOROL  as integer    initial ? 
    field tpcon  as character  initial ? 
    field tpct1  as character  initial ? 
    field tpct2  as character  initial ? 
    field tpidt  as character  initial ? 
    field TPROL  as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.

/*------------------------------------------------------------------------
File        : cteur.i
Purpose     : 
Author(s)   : SPo - 2018/02/08
Notes       :
derniere revue: 2018/04/27 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttcteur
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field dtcsy  as date
    field hecsy  as integer   initial ?
    field cdcsy  as character initial ?
    field dtmsy  as date
    field hemsy  as integer   initial ?
    field cdmsy  as character initial ?
    field tpcon  as character initial ?   // champ à créer en V19.00
    field nocon  as integer   initial ?   // champ à créer en V19.00
    field noimm  as integer   initial ?
    field nolot  as integer   initial ?
    field tpcpt  as character initial ?
    field nocpt  as character initial ?
    field cduni  as character initial ?
    field dtins  as date   
    field lbemp  as character initial ? 
    field cddev  as character initial ?
    field lbdiv  as character initial ?
    field lbdiv2 as character initial ?
    field lbdiv3 as character initial ?

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.

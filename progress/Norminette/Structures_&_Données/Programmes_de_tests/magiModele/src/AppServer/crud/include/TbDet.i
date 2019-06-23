/*------------------------------------------------------------------------
File        : tbdet.i
Purpose     : 
Author(s)   : generation automatique le 04/27/18
Notes       : champs techniques utiles pour cette table
derniere revue: 2018/08/08 - phm: 
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttTbdet
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cddev     as character initial ?
    field cdent     as character initial ?
    field dtde1     as date
    field dtde2     as date
    field fgde1     as logical   initial ?
    field fgde2     as logical   initial ?
    field idde1     as character initial ?
    field idde2     as character initial ?
    field iden1     as character initial ?
    field iden2     as character initial ?
    field lbde1     as character initial ?
    field lbde2     as character initial ?
    field lbdiv     as character initial ?
    field lbdiv2    as character initial ?
    field lbdiv3    as character initial ?
    field mtde1     as decimal   initial ? decimals 2
    field mtde1-dev as decimal   initial ? decimals 2
    field mtde2     as decimal   initial ? decimals 2
    field mtde2-dev as decimal   initial ? decimals 2
    field nbde1     as int64     initial ?
    field nbde2     as int64     initial ?

    field cdcsy     as character  initial ?
    field cdmsy     as character  initial ?
    field dtcsy     as date
    field dtmsy     as date
    field hecsy     as integer    initial ?
    field hemsy     as integer    initial ?

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.

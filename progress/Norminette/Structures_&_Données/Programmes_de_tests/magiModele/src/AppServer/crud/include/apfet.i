/*------------------------------------------------------------------------
File        : apfet.i
Purpose     : 
Author(s)   : generation automatique le 08/08/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttApfet
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cddev     as character initial ?
    field cdeta     as integer   initial ?
    field dtapp     as date
    field dtrepdef  as date
    field dttrf     as date
    field fgrepdef  as logical   initial ?
    field lbapp     as character initial ?
    field lbdiv     as character initial ?
    field lbdiv2    as character initial ?
    field lbdiv3    as character initial ?
    field modetrait as character initial ?
    field mtapp     as decimal   initial ? decimals 2
    field mtapp-dev as decimal   initial ? decimals 2
    field noapp     as integer   initial ?
    field nocpt     as integer   initial ?
    field nofon     as int64     initial ?
    field noimm     as integer   initial ?
    field noscp     as integer   initial ?
    field tpapf     as character initial ?
    field tpapp     as character initial ?

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.

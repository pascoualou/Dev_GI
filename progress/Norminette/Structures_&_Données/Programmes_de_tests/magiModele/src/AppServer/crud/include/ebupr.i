/*------------------------------------------------------------------------
File        : ebupr.i
Purpose     : budgets prévisionnels non validés
Author(s)   : generation automatique le 08/08/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttEbupr
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cddev     as character initial ?
    field dtdeb     as date
    field dtfin     as date
    field dttir     as date
    field lbdiv     as character initial ?
    field lbdiv2    as character initial ?
    field lbdiv3    as character initial ?
    field mtper     as decimal   initial ? decimals 2
    field mtper-dev as decimal   initial ? decimals 2
    field nbmoi     as integer   initial ?
    field nobud     as int64     initial ?
    field nobud-dec as decimal   initial ? decimals 0
    field noper     as integer   initial ?
    field notir     as integer   initial ?

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.

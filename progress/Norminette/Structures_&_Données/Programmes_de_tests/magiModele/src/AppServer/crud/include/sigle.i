/*------------------------------------------------------------------------
File        : sigle.i
Purpose     : Sigle cabinet
Author(s)   : generation automatique le 08/08/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttSigle
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cddev     as character initial ?
    field lbdiv     as character initial ?
    field lbdiv2    as character initial ?
    field lbdiv3    as character initial ?
    field norol     as integer   initial ?
    field norol-dec as decimal   initial ? decimals 0
    field sig01     as character initial ?
    field sig02     as character initial ?
    field sig03     as character initial ?
    field sig04     as character initial ?
    field sig05     as character initial ?
    field sig06     as character initial ?
    field sig07     as character initial ?
    field sig08     as character initial ?
    field sig09     as character initial ?
    field tprol     as character initial ?

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.

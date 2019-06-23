/*------------------------------------------------------------------------
File        : apbet.i
Purpose     : 
Author(s)   : generation automatique le 08/08/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttApbet
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cddev       as character initial ?
    field cdeta       as integer   initial ?
    field dtapp       as date
    field dtdpr       as date
    field dtfpr       as date
    field dtrepdef    as date
    field dttrf       as date
    field dttrfrep    as date
    field fgrepdef    as logical   initial ?
    field fgtrfrep    as logical   initial ?
    field lbapp       as character initial ?
    field lbdiv       as character initial ?
    field lbdiv2      as character initial ?
    field lbdiv3      as character initial ?
    field moderep     as character initial ?
    field modetrait   as character initial ?
    field mtapp       as decimal   initial ? decimals 2
    field mtapp-dev   as decimal   initial ? decimals 2
    field mtapprecloc as decimal   initial ? decimals 2
    field mtarr       as decimal   initial ? decimals 4
    field mtarr-dev   as decimal   initial ? decimals 4
    field mtarrrecloc as decimal   initial ? decimals 2
    field noapp       as integer   initial ?
    field nobud       as int64     initial ?
    field nobud-dec   as decimal   initial ? decimals 0
    field nocpt       as integer   initial ?
    field nolot       as integer   initial ?
    field noscp       as integer   initial ?
    field oparr       as character initial ?
    field tpapp       as character initial ?
    field tptrx       as character initial ?

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.

/*------------------------------------------------------------------------
File        : apbet.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttApbet
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdcsy       as character  initial ? 
    field cddev       as character  initial ? 
    field cdeta       as integer    initial ? 
    field cdmsy       as character  initial ? 
    field dtapp       as date       initial ? 
    field dtcsy       as date       initial ? 
    field dtdpr       as date       initial ? 
    field dtfpr       as date       initial ? 
    field dtmsy       as date       initial ? 
    field DtRepDef    as date       initial ? 
    field dttrf       as date       initial ? 
    field DtTrfRep    as date       initial ? 
    field FgRepDef    as logical    initial ? 
    field FgTrfRep    as logical    initial ? 
    field hecsy       as integer    initial ? 
    field hemsy       as integer    initial ? 
    field lbapp       as character  initial ? 
    field lbdiv       as character  initial ? 
    field lbdiv2      as character  initial ? 
    field lbdiv3      as character  initial ? 
    field ModeRep     as character  initial ? 
    field ModeTrait   as character  initial ? 
    field mtapp       as decimal    initial ?  decimals 2
    field mtapp-dev   as decimal    initial ?  decimals 2
    field mtapprecloc as decimal    initial ?  decimals 2
    field mtarr       as decimal    initial ?  decimals 4
    field mtarr-dev   as decimal    initial ?  decimals 4
    field mtarrrecloc as decimal    initial ?  decimals 2
    field noapp       as integer    initial ? 
    field nobud       as int64      initial ? 
    field nobud-dec   as decimal    initial ?  decimals 0
    field nocpt       as integer    initial ? 
    field nolot       as integer    initial ? 
    field noscp       as integer    initial ? 
    field oparr       as character  initial ? 
    field tpapp       as character  initial ? 
    field tptrx       as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.

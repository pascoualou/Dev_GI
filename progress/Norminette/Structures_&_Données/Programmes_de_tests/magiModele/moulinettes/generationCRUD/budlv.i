/*------------------------------------------------------------------------
File        : budlv.i
Purpose     : Ventilation des dépenses locatives des Budgets Locatifs
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttBudlv
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdcle     as character  initial ? 
    field cdcsy     as character  initial ? 
    field cddev     as character  initial ? 
    field cdfisc    as character  initial ? 
    field cdmsy     as character  initial ? 
    field cdrub     as integer    initial ? 
    field cdsrb     as integer    initial ? 
    field dtcsy     as date       initial ? 
    field dtmsy     as date       initial ? 
    field fgavt     as logical    initial ? 
    field fgquit    as logical    initial ? 
    field hecsy     as integer    initial ? 
    field hemsy     as integer    initial ? 
    field lbdiv     as character  initial ? 
    field lbdiv2    as character  initial ? 
    field lbdiv3    as character  initial ? 
    field lbocc     as character  initial ? 
    field mtbud     as decimal    initial ?  decimals 2
    field mtbud-dev as decimal    initial ?  decimals 2
    field mtfac     as decimal    initial ?  decimals 2
    field mtfac-dev as decimal    initial ?  decimals 2
    field nbtotim   as integer    initial ? 
    field nbtotmdt  as integer    initial ? 
    field noavt     as integer    initial ? 
    field nobud     as int64      initial ? 
    field nolot     as integer    initial ? 
    field nomdt     as integer    initial ? 
    field noocc     as integer    initial ? 
    field tantieme  as integer    initial ? 
    field tpbud     as character  initial ? 
    field tpocc     as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.

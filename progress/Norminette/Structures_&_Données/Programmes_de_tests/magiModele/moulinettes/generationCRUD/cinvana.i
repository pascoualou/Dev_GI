/*------------------------------------------------------------------------
File        : cinvana.i
Purpose     : ventilation ana inventaire
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCinvana
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field ana-cd     as character  initial ? 
    field ana1-cd    as character  initial ? 
    field ana2-cd    as character  initial ? 
    field ana3-cd    as character  initial ? 
    field ana4-cd    as character  initial ? 
    field dev-cd     as character  initial ? 
    field etab-cd    as integer    initial ? 
    field invest-num as character  initial ? 
    field lib        as character  initial ? 
    field mt         as decimal    initial ?  decimals 2
    field mt-EURO    as decimal    initial ?  decimals 2
    field mtdev      as decimal    initial ?  decimals 2
    field num-int    as integer    initial ? 
    field pos        as integer    initial ? 
    field pourc      as decimal    initial ?  decimals 2
    field recno-reg  as integer    initial ? 
    field repart-ana as character  initial ? 
    field sens       as logical    initial ? 
    field soc-cd     as integer    initial ? 
    field typeventil as logical    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.

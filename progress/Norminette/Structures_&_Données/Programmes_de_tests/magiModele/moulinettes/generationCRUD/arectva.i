/*------------------------------------------------------------------------
File        : arectva.i
Purpose     : TVA a payer
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttArectva
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdivers        as character  initial ? 
    field date_decla     as date       initial ? 
    field fg-valid       as logical    initial ? 
    field mttva          as decimal    initial ?  decimals 2
    field mttva-EURO     as decimal    initial ?  decimals 2
    field mttva-reg      as decimal    initial ?  decimals 2
    field mttva-reg-EURO as decimal    initial ?  decimals 2
    field siren          as character  initial ? 
    field soc-cd         as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.

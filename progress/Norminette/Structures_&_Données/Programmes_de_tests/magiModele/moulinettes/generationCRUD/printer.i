/*------------------------------------------------------------------------
File        : printer.i
Purpose     : Fichier Imprimante (G.I.)
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttPrinter
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field fg-AppSv      as logical    initial ? 
    field fg-chqbanal   as logical    initial ? 
    field printer-fam   as character  initial ? 
    field printer-field as character  initial ? 
    field printer-name  as character  initial ? 
    field printer-order as integer    initial ? 
    field printer-prog  as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.

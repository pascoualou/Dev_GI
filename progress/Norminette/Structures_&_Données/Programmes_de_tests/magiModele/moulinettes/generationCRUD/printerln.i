/*------------------------------------------------------------------------
File        : printerln.i
Purpose     : Fichier Imprimante (Sequences d'echapements)
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttPrinterln
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field printer-code     as character  initial ? 
    field printer-fam      as character  initial ? 
    field printer-id       as character  initial ? 
    field printer-order    as integer    initial ? 
    field printer-police   as character  initial ? 
    field printer-sequence as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.

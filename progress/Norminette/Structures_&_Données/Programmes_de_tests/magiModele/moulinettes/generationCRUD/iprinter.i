/*------------------------------------------------------------------------
File        : iprinter.i
Purpose     : Liste des differentes imprimantes installees
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttIprinter
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cmdunix   as character  initial ? 
    field commande  as character  initial ? 
    field nom       as character  initial ? 
    field parametre as character  initial ? 
    field paramunix as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.

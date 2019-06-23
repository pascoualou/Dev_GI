/*------------------------------------------------------------------------
File        : cnumrem.i
Purpose     : Fichier de gestion des numeros de remise
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCnumrem
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field dadeb        as date       initial ? 
    field dafin        as date       initial ? 
    field etab-cd      as integer    initial ? 
    field piece-compta as integer    initial ? 
    field soc-cd       as integer    initial ? 
    field type-remise  as logical    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.

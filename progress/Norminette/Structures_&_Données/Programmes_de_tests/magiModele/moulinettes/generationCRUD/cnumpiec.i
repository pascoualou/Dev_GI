/*------------------------------------------------------------------------
File        : cnumpiec.i
Purpose     : Fichier de gestion des numeros de pieces interne
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCnumpiec
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field etab-cd      as integer    initial ? 
    field jou-cd       as character  initial ? 
    field piece-compta as integer    initial ? 
    field piece-int    as integer    initial ? 
    field prd-cd       as integer    initial ? 
    field prd-num      as integer    initial ? 
    field soc-cd       as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.

/*------------------------------------------------------------------------
File        : cbon.i
Purpose     : Fichier de gestion des bon a payer
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCbon
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field bonapaye    as logical    initial ? 
    field commentaire as character  initial ? 
    field datbap      as date       initial ? 
    field etab-cd     as integer    initial ? 
    field jour-cd     as character  initial ? 
    field nom         as character  initial ? 
    field piec-num    as integer    initial ? 
    field scenario    as character  initial ? 
    field soc-cd      as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.

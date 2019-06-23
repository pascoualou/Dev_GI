/*------------------------------------------------------------------------
File        : ilock.i
Purpose     : permet de simuler un lock fichier
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttIlock
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field clesup   as character  initial ? 
    field datelock as date       initial ? 
    field etab-cd  as integer    initial ? 
    field gi-ttyid as character  initial ? 
    field id-user  as character  initial ? 
    field nomfic   as character  initial ? 
    field soc-cd   as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.

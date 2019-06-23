/*------------------------------------------------------------------------
File        : ilibnatjou.i
Purpose     : Libelle nature journal.
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttIlibnatjou
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field achat      as logical    initial ? 
    field ana        as logical    initial ? 
    field anouveau   as logical    initial ? 
    field etab-cd    as integer    initial ? 
    field extra-cpta as logical    initial ? 
    field lib        as character  initial ? 
    field natjou-cd  as integer    initial ? 
    field od         as logical    initial ? 
    field soc-cd     as integer    initial ? 
    field treso      as logical    initial ? 
    field vente      as logical    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.

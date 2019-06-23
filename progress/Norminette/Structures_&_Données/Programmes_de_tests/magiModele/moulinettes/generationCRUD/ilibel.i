/*------------------------------------------------------------------------
File        : ilibel.i
Purpose     : Table de libelles
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttIlibel
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field activite-cd as integer    initial ? 
    field etab-cd     as integer    initial ? 
    field libel-cd    as integer    initial ? 
    field libel-lib   as character  initial ? 
    field liblang-cd  as integer    initial ? 
    field soc-cd      as integer    initial ? 
    field taille-maxi as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.

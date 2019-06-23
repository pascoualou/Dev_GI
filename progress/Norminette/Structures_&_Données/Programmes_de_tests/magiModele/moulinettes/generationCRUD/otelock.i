/*------------------------------------------------------------------------
File        : otelock.i
Purpose     : Mise a jour batch
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttOtelock
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field crowid    as character  initial ? 
    field dacre     as date       initial ? 
    field etab-cd   as integer    initial ? 
    field heurcre   as integer    initial ? 
    field nom-champ as character  initial ? 
    field nom-fich  as character  initial ? 
    field paramc    as character  initial ? 
    field recno     as recid      initial ? 
    field soc-cd    as integer    initial ? 
    field valeur    as decimal    initial ?  decimals 3
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
